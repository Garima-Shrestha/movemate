import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../../../config/routes/route_names.dart';
import '../../../../../core/services/socket/socket_service.dart';
import '../../../../../core/utils/snackbar_utils.dart';
import '../../../../booking/data/datasources/remote/booking_remote_datasource.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../view_model/booking_user_view_model.dart';

class DriverFoundScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookingData;

  const DriverFoundScreen({super.key, required this.bookingData});

  @override
  ConsumerState<DriverFoundScreen> createState() => _DriverFoundScreenState();
}

class _DriverFoundScreenState extends ConsumerState<DriverFoundScreen> {
  String _vehicleTypeTitle() {
    final type = (widget.bookingData['vehicleType'] ?? 'Vehicle').toString();

    return type[0].toUpperCase() + type.substring(1);
  }

  String _getVehicleImage() {
    switch ((widget.bookingData['vehicleType'] ?? '')
        .toString()
        .toLowerCase()) {
      case 'pickup':
        return 'assets/images/pickup.png';

      case 'truck':
        return 'assets/images/truck.png';

      case 'tempo':
      default:
        return 'assets/images/tempo.png';
    }
  }

  MapLibreMapController? _mapController;
  bool _markerImageLoaded = false;

  LatLng? _pickupLatLng;
  LatLng? _dropLatLng;

  // Parsed from bookingData
  late String _bookingId;
  late String _pickupAddress;
  late String _dropAddress;
  late double _distanceKm;
  late int _price;
  late int _eta; // minutes
  late List<String> _goodsTypes;

  // Driver info — from populated driverId object
  late String _driverName;
  late String _driverPhone;
  late String _vehicleModel;
  late String _numberPlate;
  late String _vehicleColor;
  late int _tripCount;

  // Status tracking
  late String _bookingStatus;
  bool _isCancelling = false;
  bool _driverArrived = false;

  late final SocketService _socket;

  @override
  void initState() {
    super.initState();

    _socket = ref.read(socketServiceProvider);
    _parseBookingData();
    final savedSubStage = ref.read(bookingUserViewModelProvider).tripSubStage;
    if (savedSubStage != 'accepted') {
      _bookingStatus = savedSubStage;
    }
    _listenToSocket();
  }

  void _parseBookingData() {
    final d = widget.bookingData;

    _bookingId = d['_id'] ?? d['id'] ?? '';
    final savedSubStage = ref.read(bookingUserViewModelProvider).tripSubStage;
    _bookingStatus = savedSubStage != 'accepted' ? savedSubStage : (d['status'] ?? 'accepted');
    _pickupAddress = d['pickupAddress'] ?? '';
    _dropAddress = d['dropAddress'] ?? '';
    _distanceKm = (d['distance'] as num?)?.toDouble() ?? 0.0;
    _price = (d['price'] as num?)?.toInt() ?? 0;
    _eta = (d['estimatedArrival'] as num?)?.toInt() ?? 0;
    _goodsTypes = List<String>.from(d['goodsTypes'] ?? []);

    // driverId can be a populated object or just an ID string
    final driver = d['driverId'];

    if (driver is Map) {
      _driverName = driver['username'] ?? 'Driver';
      _driverPhone = driver['phone'] ?? '';
      _vehicleModel = driver['vehicleModel'] ?? '';
      _numberPlate = driver['numberPlate'] ?? '';
      _vehicleColor = driver['vehicleColor'] ?? '';
    } else {
      _driverName = 'Driver';
      _driverPhone = '';
      _vehicleModel = '';
      _numberPlate = '';
      _vehicleColor = '';
    }

    // tripCount is extra field we'll fetch or use from data
    _tripCount = (d['tripCount'] as num?)?.toInt() ?? 0;

    final pickupCoords = d['pickupLocation']?['coordinates'];
    if (pickupCoords != null && pickupCoords.length == 2) {
      _pickupLatLng = LatLng(
        (pickupCoords[1] as num).toDouble(),
        (pickupCoords[0] as num).toDouble(),
      );
    }

    final dropCoords = d['dropLocation']?['coordinates'];
    if (dropCoords != null && dropCoords.length == 2) {
      _dropLatLng = LatLng(
        (dropCoords[1] as num).toDouble(),
        (dropCoords[0] as num).toDouble(),
      );
    }
  }

  void _listenToSocket() {
    final socket = _socket;

    // Trip started by driver
    socket.off('tripStarted');
    socket.on('tripStarted', (data) async {
      if (!mounted) return;

      setState(() => _bookingStatus = 'ongoing');
      ref.read(bookingUserViewModelProvider.notifier).updateTripSubStage('ongoing');

      final coords = data['driverLocation']?['coordinates'];

      if (coords != null && coords.length == 2) {
        final driverLatLng = LatLng(coords[1], coords[0]);

        await _mapController?.clearSymbols();

        await _mapController?.addSymbol(
          SymbolOptions(
            geometry: driverLatLng,
            iconImage: "vehicle_marker",
            iconSize: 0.4,
          ),
        );

        // Keep pickup and drop circles visible during trip too
        if (_pickupLatLng != null) {
          await _mapController?.addCircle(
            CircleOptions(
              geometry: _pickupLatLng!,
              circleRadius: 8,
              circleColor: "#1A68EE",
              circleStrokeColor: "#FFFFFF",
              circleStrokeWidth: 2,
            ),
          );
        }

        if (_dropLatLng != null) {
          await _mapController?.addCircle(
            CircleOptions(
              geometry: _dropLatLng!,
              circleRadius: 8,
              circleColor: "#FF7A00",
              circleStrokeColor: "#FFFFFF",
              circleStrokeWidth: 2,
            ),
          );
        }


        final screenHeight = MediaQuery.of(context).size.height;
        final bottomPadding = screenHeight * 0.45;

        if (_pickupLatLng != null && _dropLatLng != null) {
          final minLat = [_pickupLatLng!.latitude, _dropLatLng!.latitude].reduce((a, b) => a < b ? a : b);
          final maxLat = [_pickupLatLng!.latitude, _dropLatLng!.latitude].reduce((a, b) => a > b ? a : b);
          final minLng = [_pickupLatLng!.longitude, _dropLatLng!.longitude].reduce((a, b) => a < b ? a : b);
          final maxLng = [_pickupLatLng!.longitude, _dropLatLng!.longitude].reduce((a, b) => a > b ? a : b);

          // Ensure minimum span so nearby markers don't get cut off
          const minSpan = 0.002;
          final latSpan = (maxLat - minLat) < minSpan ? minSpan : (maxLat - minLat);
          final lngSpan = (maxLng - minLng) < minSpan ? minSpan : (maxLng - minLng);
          final centerLat = (minLat + maxLat) / 2;
          final centerLng = (minLng + maxLng) / 2;

          await _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(centerLat - latSpan / 2, centerLng - lngSpan / 2),
                northeast: LatLng(centerLat + latSpan / 2, centerLng + lngSpan / 2),
              ),
              left: 60,
              top: 120,
              right: 60,
              bottom: MediaQuery.of(context).size.height * 0.30,
            ),
          );
        }
      }

      SnackbarUtils.showInfo(context, 'Driver has started the trip!');
    });

    // Trip completed
    socket.off('tripCompleted');
    socket.on('tripCompleted', (data) {
      if (!mounted) return;
      ref.read(bookingUserViewModelProvider.notifier).updateTripSubStage('accepted');
      context.go(
        RouteNames.deliveryCompleted,
        extra: {
          ...Map<String, dynamic>.from(data is Map ? data : {}),
          // Pass current booking info as fallback in case data is incomplete
          'pickupAddress': _pickupAddress,
          'dropAddress': _dropAddress,
          'distance': _distanceKm,
          'price': _price,
          'vehicleType': widget.bookingData['vehicleType'],
          'driverId': widget.bookingData['driverId'],
        },
      );
    });

    // Driver cancelled
    socket.off('bookingCancelled');
    socket.on('bookingCancelled', (data) {

      if (!mounted) return;
      SnackbarUtils.showError(context, 'Driver cancelled the booking.');
      ref.read(bookingUserViewModelProvider.notifier).updateTripSubStage('accepted');
      context.go(RouteNames.userHome);
    });

    // Driver picked up goods, heading to dropoff
    socket.off('goodsPickedUp');
    socket.on('goodsPickedUp', (data) {
      if (!mounted) return;

      setState(() {
        _bookingStatus = 'heading_to_dropoff';
      });
      ref.read(bookingUserViewModelProvider.notifier).updateTripSubStage('heading_to_dropoff');
      SnackbarUtils.showInfo(context, 'Driver has picked up your goods!');
    });

    // Driver arrived at pickup
    socket.on('arrivedAtPickup', (data) {
      if (!mounted) return;

      setState(() {
        _driverArrived = true;
        _bookingStatus = 'arrived';
      });
      ref.read(bookingUserViewModelProvider.notifier).updateTripSubStage('arrived');
      SnackbarUtils.showSuccess(context, 'Driver has arrived at pickup point!');
    });

    // Booking reopened (driver cancelled accepted booking)
    socket.off('bookingReopened');
    socket.on('bookingReopened', (data) {
      if (!mounted) return;

      SnackbarUtils.showWarning(
        context,
        'Driver cancelled. Looking for another driver...',
      );

      context.go(
        RouteNames.driverSearching,
        extra: Map<String, dynamic>.from(data),
      );
    });
  }

  Future<void> _cancelBooking() async {
    setState(() => _isCancelling = true);
    try {
      final remote = ref.read(bookingRemoteDataSourceProvider);
      await remote.cancelBooking(_bookingId);
      if (mounted) {
        SnackbarUtils.showSuccess(context, 'Booking cancelled.');
        context.go(RouteNames.userHome);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, e.toString());
        setState(() => _isCancelling = false);
      }
    }
  }

  void _showCancelConfirm() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 6),

                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFFF4A3D),
                  child: Icon(Icons.close, color: Colors.white),
                ),

                const SizedBox(height: 24),

                Text(
                  _bookingStatus == 'ongoing'
                      ? "Cancel Ongoing Trip?"
                      : "Cancel Booking?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFF4A3D),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _bookingStatus == 'ongoing'
                      ? "The driver is on the way to pick up your goods.\nAre you sure you want to cancel?"
                      : "Your driver is already assigned.\nCancelling now will stop this booking.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF4D4D4D),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF44336),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const FittedBox(
                          child: Text(
                            "Continue Ride",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _cancelBooking();
                        },
                        child: const Text(
                          "Cancel Booking",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDropoffEta() {
    // Estimate dropoff ETA based on distance and average city speed (30 km/h)
    if (_distanceKm <= 0) return 'On the way';
    final etaMinutes = (_distanceKm / 30 * 60).round();
    final now = DateTime.now();
    final dropoffTime = now.add(Duration(minutes: etaMinutes));
    final hour = dropoffTime.hour;
    final minute = dropoffTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return 'Drop-off by $displayHour:$minute $period';
  }

  Future<void> _loadVehicleMarker() async {
    if (_mapController == null) return;

    precacheImage(AssetImage(_getVehicleImage()), context);

    final bytes = await rootBundle.load(_getVehicleImage());

    await _mapController!.addImage(
      'vehicle_marker',
      bytes.buffer.asUint8List(),
    );

    _markerImageLoaded = true;
  }

  Future<void> _callDriver() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: SizedBox(
            height: 220,
            child: Column(
              children: [

                const SizedBox(height: 20),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Open With',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);

                    final uri = Uri.parse('tel:$_driverPhone');
                    await launchUrl(uri);
                  },
                  child: Column(
                    children: [

                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.call,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Phone',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Text(
                      'Just once',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF727272),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 52),
                      width: 1,
                      height: 14,
                      color: const Color(0xFFD0D0D0),
                    ),

                    const Text(
                      'Always',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF727272),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _socket.off('tripStarted');
    _socket.off('tripCompleted');
    _socket.off('bookingCancelled');
    _socket.off('bookingReopened');
    _socket.off('arrivedAtPickup');
    _socket.off('goodsPickedUp');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapTilerKey = dotenv.env['MAPTILER_API_KEY'] ?? '';
    final statusText = _bookingStatus == 'ongoing'
        ? 'Trip in Progress'
        : 'Driver is on the way';

    return Scaffold(
      body: Stack(
        children: [
          // ── MAP ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.50,
            child: MapLibreMap(
              styleString:
                  'https://api.maptiler.com/maps/streets-v2/style.json?key=$mapTilerKey',
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  (_pickupLatLng?.latitude ?? 27.7172) - 0.008,
                  (_pickupLatLng?.longitude ?? 85.3240),
                ),
                zoom: 13,
              ),
              myLocationEnabled: true,
              compassEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
                },

              onStyleLoadedCallback: () async {
                await _loadVehicleMarker();
                final driverCoords = widget.bookingData['driverLocation']?['coordinates'];

                if (_bookingStatus == 'ongoing' &&
                    driverCoords != null &&
                    driverCoords.length == 2) {
                  await _mapController?.addSymbol(
                    SymbolOptions(
                      geometry: LatLng(driverCoords[1], driverCoords[0]),
                      iconImage: "vehicle_marker",
                      iconSize: 0.4,
                    ),
                  );
                }

                if (_pickupLatLng != null) {
                  await _mapController?.addCircle(
                    CircleOptions(
                      geometry: _pickupLatLng!,
                      circleRadius: 8,
                      circleColor: "#1A68EE",
                      circleStrokeColor: "#FFFFFF",
                      circleStrokeWidth: 2,
                    ),
                  );
                }

                if (_dropLatLng != null) {
                  await _mapController?.addCircle(
                    CircleOptions(
                      geometry: _dropLatLng!,
                      circleRadius: 8,
                      circleColor: "#FF7A00",
                      circleStrokeColor: "#FFFFFF",
                      circleStrokeWidth: 2,
                    ),
                  );
                }


                final screenHeight = MediaQuery.of(context).size.height;
                  final bottomPadding = screenHeight * 0.45;
                if (_pickupLatLng != null && _dropLatLng != null) {
                  final minLat = [_pickupLatLng!.latitude, _dropLatLng!.latitude].reduce((a, b) => a < b ? a : b);
                  final maxLat = [_pickupLatLng!.latitude, _dropLatLng!.latitude].reduce((a, b) => a > b ? a : b);
                  final minLng = [_pickupLatLng!.longitude, _dropLatLng!.longitude].reduce((a, b) => a < b ? a : b);
                  final maxLng = [_pickupLatLng!.longitude, _dropLatLng!.longitude].reduce((a, b) => a > b ? a : b);

                  // Ensure minimum span so nearby markers don't get cut off
                  const minSpan = 0.003;
                  final latSpan = (maxLat - minLat) < minSpan ? minSpan : (maxLat - minLat);
                  final lngSpan = (maxLng - minLng) < minSpan ? minSpan : (maxLng - minLng);
                  final centerLat = (minLat + maxLat) / 2;
                  final centerLng = (minLng + maxLng) / 2;

                  await _mapController?.animateCamera(
                    CameraUpdate.newLatLngBounds(
                      LatLngBounds(
                        southwest: LatLng(centerLat - latSpan / 2, centerLng - lngSpan / 2),
                        northeast: LatLng(centerLat + latSpan / 2, centerLng + lngSpan / 2),
                      ),
                      left: 60,
                      top: 120,
                      right: 60,
                      bottom: MediaQuery.of(context).size.height * 0.30,
                    ),
                  );
                }
              },
            ),
          ),


          // TOP BANNER: only in accepted state
          if (_bookingStatus == 'accepted')

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(
                  top: 35,
                  left: 16,
                  right: 16,
                  bottom: 14,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 28),
                      child: const Text(
                        'Booking Confirmed!',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

          // BOTTOM SHEET
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              // padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  _bookingStatus == 'heading_to_dropoff'
                      ? Column(
                    children: [
                      const Text(
                        'On the way',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getDropoffEta(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  )
                      : Text(
                    _bookingStatus == 'arrived'
                        ? 'At your location'
                        : _bookingStatus == 'ongoing'
                        ? 'Arriving in $_eta min'
                        : _eta > 0
                        ? 'Arriving in $_eta min'
                        : '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: 409,
                    height: 37,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7FDE0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 18),
                          const Icon(
                            Icons.check,
                            size: 22,
                            color: Color(0xFF034C00),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _bookingStatus == 'arrived'
                                ? 'Driver Has Arrived At Pickup Point'
                                : _bookingStatus == 'heading_to_dropoff'
                                ? 'Driver Heading To Dropoff'
                                : _bookingStatus == 'ongoing'
                                ? 'Driver On The Way To Pickup Location'
                                : 'Driver Accepted Your Request',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF034C00),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 29),

                  // DRIVER ROW
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: const Color(0xFF1E3A8A),
                            child: Text(
                              _driverName.isNotEmpty
                                  ? _driverName[0].toUpperCase()
                                  : 'D',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Positioned(
                            right: -1,
                            bottom: 2,
                            child: Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0CDB05),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _driverName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF000000),
                              ),
                            ),
                            Text(
                              '$_tripCount trips',
                              style: const TextStyle(
                                color: Color(0xFF585858),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Call button
                      GestureDetector(
                        onTap: _callDriver,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD2E0FF),
                            ),
                            child: const Icon(
                              Icons.phone_in_talk_outlined,
                              size: 23,
                              color: Color(0xFF1E68F0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // VEHICLE ROW
                  SizedBox(
                    height: 85,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFEF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            _getVehicleImage(),
                            width: 72,
                            height: 72,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(
                                  _vehicleColor.isNotEmpty
                                      ? '${_vehicleTypeTitle()} • $_vehicleColor'
                                      : _vehicleTypeTitle(),
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                if (_vehicleColor.isNotEmpty)
                                  Text(
                                    _vehicleModel,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Color(0xFF4A4A4A),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 128,
                            height: 51,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Color(0xFF818181),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'PLATE',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF848383),
                                    ),
                                  ),
                                  Text(
                                    _numberPlate,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ROUTE BOX
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF134AE9),
                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Container(
                              width: 2,
                              height: 46,
                              color: const Color(0xFFB7B7B7),
                            ),

                            const SizedBox(height: 5),

                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF97316),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pick-up',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF848484),
                                ),
                              ),
                              Text(
                                _pickupAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 19,
                                  color: Color(0xFF000000),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Drop-off',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF848484),
                                ),
                              ),
                              Text(
                                _dropAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 19,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 17),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_distanceKm.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  color: Color(0xFF565656),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 0),
                              Text(
                                'NRP $_price',
                                style: const TextStyle(
                                  color: Color(0xFF2255E5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // CANCEL BUTTON
                  // Show until driver arrives at pickup, hide after
                  if (_bookingStatus != 'completed' && _bookingStatus != 'arrived' && _bookingStatus != 'heading_to_dropoff')
                    SizedBox(
                      width: 217,
                      child: OutlinedButton(
                        onPressed: _isCancelling ? null : _showCancelConfirm,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFFFF),
                          side: const BorderSide(
                            color: Color(0xFFD71717),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(217, 53),
                          padding: EdgeInsets.zero,
                        ),
                        child: _isCancelling
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Cancel Request',
                                style: TextStyle(
                                  color: Color(0xFFD71717),
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),

          Positioned(
            top: 60,
            left: 18,
            child: GestureDetector(
              onTap: () => context.go(RouteNames.userHome),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
