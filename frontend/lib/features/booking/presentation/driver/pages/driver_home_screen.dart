import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../config/routes/route_names.dart';
import '../../../../../core/services/storage/user_session_service.dart';
import '../../../../../core/utils/snackbar_utils.dart';
import '../../../../auth/presentation/view_model/auth_view_model.dart';
import '../../../data/datasources/remote/booking_remote_datasource.dart';
import '../state/driver_booking_state.dart';
import '../view_model/driver_booking_view_model.dart';
import '../view_model/driver_view_model.dart';
import '../../../../../core/services/socket/socket_service.dart';
import '../widgets/driver_booking_request_card.dart';
import 'dart:async';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  MapLibreMapController? _mapController;

  LatLng _driverLocation = const LatLng(27.7172, 85.3240);

  bool _locationReady = false;

  bool isOnline = false;
  SocketService? _socketService;
  bool _bookingListenerRegistered = false;

  bool _hasIncomingRequest = false;

  BuildContext? _dialogContext;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final status = await Permission.location.request();
    if (!status.isGranted) return;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      _driverLocation = LatLng(position.latitude, position.longitude);
      _locationReady = true;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_driverLocation, 14),
    );
  }

  void _connectDriverSocket() {
    final session = ref.read(userSessionServiceProvider);
    final driverId = session.getCurrentUserId();

    if (driverId == null) return;

    _socketService ??= ref.read(socketServiceProvider);

    if (!_socketService!.isConnected) {
      _socketService!.connect(driverId, "driver");

      Future.delayed(const Duration(seconds: 2), () {
        ref.read(driverBookingViewModelProvider.notifier).fetchMyBookings();
      });
    }

    _socketService!.off('newBooking');
    // _socketService!.on('newBooking', (data) {
    //   if (mounted) _showBookingPopup(data);
    // });

    _socketService!.on('newBooking', (data) {
      if (!mounted) return;

      setState(() {
        _hasIncomingRequest = true;
      });

      _showBookingPopup(data);
    });

    _socketService!.off('bookingCancelled');
    _socketService!.on('bookingCancelled', (data) {
      ref.read(driverBookingViewModelProvider.notifier).fetchMyBookings();

      if (_dialogContext != null) {
        Navigator.of(_dialogContext!).pop();
        _dialogContext = null;
      }

      SnackbarUtils.showInfo(context, 'Booking was cancelled by the user.');
    });

    _socketService!.off('bookingCancelledByUser');
    _socketService!.on('bookingCancelledByUser', (data) {
      ref.read(driverBookingViewModelProvider.notifier).fetchMyBookings();

      if (mounted) {
        SnackbarUtils.showError(context, 'User cancelled the booking.');
      }

      // Make driver available again and go back to home
      ref.read(authViewModelProvider.notifier).updateAvailability(true);

      if (mounted) {
        context.go(RouteNames.driverHome);
      }
    });
    _bookingListenerRegistered = true;
  }

  void _showBookingPopup(dynamic booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        _dialogContext = dialogContext;
        return DriverBookingRequestCard(
          booking: booking,
          onAccept: () async {
            setState(() {
              _hasIncomingRequest = false;
            });
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
              _dialogContext = null;
            }

            // Call the accept API
            final bookingId = booking['_id'] as String?;
            if (bookingId != null) {
              try {
                final remote = ref.read(bookingRemoteDataSourceProvider);
                await remote.driverAcceptBooking(bookingId);
              } catch (e) {
                if (mounted) {
                  SnackbarUtils.showError(context, 'Failed to accept booking');
                }
                return;
              }
            }

            if (mounted) {
              context.go(RouteNames.driverBookings);
            }
          },
          onDecline: () {
            setState(() {
              _hasIncomingRequest = false;
            });
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
              _dialogContext = null;
            }
          },
        );
      },
    );

    Future.delayed(const Duration(seconds: 30), () {
      if (_dialogContext != null) {
        Navigator.of(_dialogContext!).pop();
        _dialogContext = null;
      }
    });
  }

  @override
  void dispose() {
    _socketService?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.read(userSessionServiceProvider);
    final driverState = ref.watch(driverViewModelProvider);
    final username = session.getCurrentUserName() ?? 'Driver';
    final numberPlate = session.getNumberPlate() ?? 'N/A';

    final avatarLetter = username.isNotEmpty ? username[0].toUpperCase() : 'D';

    final mapTilerKey = dotenv.env['MAPTILER_API_KEY'] ?? '';

    return Scaffold(
      body: Stack(
        children: [
          // MAP
          MapLibreMap(
            styleString:
                'https://api.maptiler.com/maps/streets-v2/style.json?key=$mapTilerKey',
            initialCameraPosition: CameraPosition(
              target: _driverLocation,
              zoom: 14,
            ),
            myLocationEnabled:  _locationReady,
            myLocationTrackingMode: MyLocationTrackingMode.tracking,
            compassEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;

              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(_driverLocation, 14),
              );
            },
          ),

          // HEADER
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                top: 55,
                left: 16,
                right: 16,
                bottom: 14,
              ),
              color: const Color(0xFF264987),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF5D84D6),
                    child: Text(
                      avatarLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $username',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          'Number Plate: $numberPlate',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    children: [
                      Switch(
                        value: isOnline,
                        activeColor: Colors.green,
                        onChanged: (value) async {
                          if (value) {
                            final locationUpdated = await ref
                                .read(authViewModelProvider.notifier)
                                .updateDriverLocation(
                                  latitude: _driverLocation.latitude,
                                  longitude: _driverLocation.longitude,
                                );

                            if (!locationUpdated) {
                              return;
                            }

                            final available = await ref
                                .read(authViewModelProvider.notifier)
                                .updateAvailability(true);

                            if (!available) {
                              return;
                            }

                            setState(() {
                              isOnline = true;
                            });

                            _connectDriverSocket();

                            ref.read(driverViewModelProvider.notifier).getDriverStats();
                          } else {
                            await ref
                                .read(authViewModelProvider.notifier)
                                .updateAvailability(false);

                            setState(() {
                              isOnline = false;
                              _bookingListenerRegistered = false;
                            });

                            _socketService?.disconnect();
                          }
                        },
                      ),

                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // STATUS CARD
          Positioned(
            top: 145,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.black54,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnline ? "You're Online" : "You're Offline",
                          style: TextStyle(
                            color: isOnline ? Colors.green : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          !isOnline
                              ? "Go online to receive requests."
                              : _hasIncomingRequest
                              ? "Please respond to the incoming request."
                              : "No requests right now",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BOTTOM PANEL
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // REQUEST CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFDDEBFF),
                          child: Icon(
                            Icons.access_time,
                            color: Color(0xFF264987),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                !isOnline
                                    ? "Go online to receive requests."
                                    : _hasIncomingRequest
                                    ? "Incoming request!"
                                    : "No requests right now",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                // isOnline
                                    // ? "We'll notify you when a new request arrives."
                                    // : "You won't get delivery requests while offline.",
                                !isOnline
                                    ? "You won't get delivery requests while offline."
                                    : _hasIncomingRequest
                                    ? "Please respond to the incoming request."
                                    : "We'll notify you when a new request arrives.",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          "TODAY'S EARNING",
                          "NRP ${driverState.todayEarning}",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          "TOTAL EARNING",
                          "NRP ${driverState.totalEarning}",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          "TODAY'S DELIVERY",
                          "${driverState.todayDelivery} Completed",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          "TOTAL DELIVERY",
                          "${driverState.totalDelivery} Completed",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
