import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../view_model/driver_booking_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../core/services/socket/socket_service.dart';
import '../../../../../core/utils/snackbar_utils.dart';
import '../../../../../config/routes/route_names.dart';
import 'package:go_router/go_router.dart';


class DriverTripScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookingData;

  const DriverTripScreen({
    super.key,
    required this.bookingData,
  });

  @override
  ConsumerState<DriverTripScreen> createState() =>
      _DriverTripScreenState();
}

class _DriverTripScreenState
    extends ConsumerState<DriverTripScreen> {

  bool _locationReady = false;
  late String _tripStage;
  late final SocketService _socket;

  Future<void> _initLocation() async {
    final status = await Permission.location.request();

    if (!status.isGranted) return;

    if (!mounted) return;

    setState(() {
      _locationReady = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _tripStage = ref.read(driverBookingViewModelProvider).tripStage;
    _initLocation();
    _listenToSocket();
  }

  void _listenToSocket() {
    _socket = ref.read(socketServiceProvider);

    _socket.off('bookingCancelledByUser');
    _socket.on('bookingCancelledByUser', (data) {
      if (!mounted) return;

      SnackbarUtils.showError(context, 'User cancelled the booking.');
      context.go(RouteNames.driverHome);
    });
  }

  @override
  void dispose() {
    _socket.off('bookingCancelledByUser');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pickup = List<double>.from(widget.bookingData['pickupCoordinates']);
    final drop = List<double>.from(widget.bookingData['dropCoordinates']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Trip'),
      ),

      body: Stack(
        children: [

          MapLibreMap(
            styleString:
            'https://api.maptiler.com/maps/streets-v2/style.json?key=${dotenv.env['MAPTILER_API_KEY']}',

            initialCameraPosition: CameraPosition(
              target: LatLng(
                pickup[1],
                pickup[0],
              ),
              zoom: 14,
            ),

            myLocationEnabled: _locationReady,
            myLocationTrackingMode: MyLocationTrackingMode.tracking,
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Text(
                    widget.bookingData['pickupAddress'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.bookingData['dropAddress'],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${widget.bookingData['distance'] ?? 0} km',
                  ),

                  const SizedBox(height: 20),

                  // Stage label
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7FDE0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _tripStage == 'heading_to_pickup'
                          ? 'Heading to Pickup Location'
                          : _tripStage == 'arrived_at_pickup'
                          ? 'Arrived at Pickup Point'
                          : 'Heading to Dropoff',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF034C00),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stage 1: heading to pickup → show "Arrived at Pickup" button
                  if (_tripStage == 'heading_to_pickup')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          await ref
                              .read(driverBookingViewModelProvider.notifier)
                              .arrivedAtPickup(widget.bookingData['bookingId']);
                          if (mounted) {
                            setState(() => _tripStage = 'arrived_at_pickup');
                            ref.read(driverBookingViewModelProvider.notifier).updateTripStage('arrived_at_pickup');
                          }
                        },
                        child: const Text(
                          'ARRIVED AT PICKUP',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),

                  // Stage 2: arrived at pickup → show "Goods Picked Up" button
                  if (_tripStage == 'arrived_at_pickup')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          await ref
                              .read(driverBookingViewModelProvider.notifier)
                              .goodsPickedUp(widget.bookingData['bookingId']);
                          if (mounted) {
                            setState(() => _tripStage = 'heading_to_dropoff');
                            ref.read(driverBookingViewModelProvider.notifier).updateTripStage('heading_to_dropoff');
                          }
                        },
                        child: const Text(
                          'HEADING TO DROPOFF',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  // Stage 3: heading to dropoff → show "Complete Trip" button
                  if (_tripStage == 'heading_to_dropoff')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          context.push(
                            RouteNames.driverProofOfDelivery,
                            extra: widget.bookingData,
                          );
                        },
                        child: const Text(
                          'COMPLETE TRIP',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}