import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../../config/routes/route_names.dart';
import '../../../../../core/services/socket/socket_service.dart';
import '../../../domain/entities/booking_entity.dart';
import '../view_model/booking_user_view_model.dart';

class BookingHistoryDetailScreen extends ConsumerStatefulWidget {
  final BookingEntity booking;

  const BookingHistoryDetailScreen({super.key, required this.booking});

  @override
  ConsumerState<BookingHistoryDetailScreen> createState() =>
      _BookingHistoryDetailScreenState();
}

class _BookingHistoryDetailScreenState
    extends ConsumerState<BookingHistoryDetailScreen> {
  MapLibreMapController? _mapController;
  bool _markerImageLoaded = false;

  String get _status => widget.booking.status;

  // bool get _isOngoing => _status == 'ongoing';
  bool get _isOngoing {
    final s = _status.toLowerCase().trim();

    return s == 'ongoing' ||
        s == 'accepted' ||
        s == 'arrived' ||
        s == 'heading_to_dropoff';
  }
  bool get _isCompleted => _status == 'completed';
  bool get _isCancelled => _status == 'cancelled';

  // helpers

  String _vehicleImage() {
    switch (widget.booking.vehicleType.toLowerCase()) {
      case 'pickup':
        return 'assets/images/pickup.png';
      case 'truck':
        return 'assets/images/truck.png';
      default:
        return 'assets/images/tempo.png';
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final nepal = dt.toUtc().add(const Duration(hours: 5, minutes: 45));
    final dayName = days[nepal.weekday - 1];
    return '$dayName, ${nepal.day.toString().padLeft(2, '0')} ${months[nepal.month]} ${nepal.year}';
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final nepal = dt.toUtc().add(const Duration(hours: 5, minutes: 45));
    final h = nepal.hour > 12
        ? nepal.hour - 12
        : (nepal.hour == 0 ? 12 : nepal.hour);
    final m = nepal.minute.toString().padLeft(2, '0');
    final period = nepal.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String _formatDuration() {
    final start = widget.booking.startedAt;
    final end = widget.booking.completedAt;
    if (start == null || end == null) {
      return _isCancelled ? '0 min' : '--';
    }
    final diff = end.difference(start);
    if (diff.inSeconds < 60) return '${diff.inSeconds} sec';
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h > 0) return '$h hr $m min';
    return '$m min';
  }

  String _statusLabel() {
    if (_isOngoing) return 'Ongoing';
    if (_isCompleted) return 'Completed';
    if (_isCancelled) {
      return widget.booking.cancelledBy == 'driver'
          ? 'Driver Cancelled'
          : 'You Cancelled';
    }
    return _status;
  }

  Color _statusColor() {
    if (_isOngoing) return const Color(0xFF00D719);
    if (_isCompleted) return const Color(0xFF00D719);
    return const Color(0xFFD50202);
  }

  String get _proofImageUrl {
    final path = widget.booking.proofOfDeliveryImage ?? '';
    if (path.isEmpty) return '';
    return '${dotenv.env['API_BASE_URL'] ?? ''}$path';
  }

  // Pickup ETA: actual acceptedAt time
  // Drop ETA: if completed → actual completedAt; if ongoing → estimate from now
  String _pickupTime() => _formatTime(widget.booking.acceptedAt ?? widget.booking.createdAt);

  String _dropTime() {
    if (_isCompleted) return _formatTime(widget.booking.completedAt);
    // Estimate
    final dist = widget.booking.distance ?? 0;
    if (dist <= 0) return '--';
    final eta = (dist / 30 * 60).round();
    final est = DateTime.now().add(Duration(minutes: eta));
    return _formatTime(est);
  }

  // map

  LatLng? get _pickupLatLng {
    final c = widget.booking.pickupCoordinates;
    if (c.length == 2) return LatLng(c[1], c[0]);
    return null;
  }

  LatLng? get _dropLatLng {
    final c = widget.booking.dropCoordinates;
    if (c.length == 2) return LatLng(c[1], c[0]);
    return null;
  }

  Future<void> _loadVehicleMarker() async {
    if (_mapController == null || _markerImageLoaded) return;
    final bytes = await rootBundle.load(_vehicleImage());
    await _mapController!.addImage(
      'vehicle_marker',
      bytes.buffer.asUint8List(),
    );
    _markerImageLoaded = true;
  }

  Future<void> _onStyleLoaded() async {
    await _loadVehicleMarker();

    if (_pickupLatLng != null) {
      await _mapController?.addCircle(CircleOptions(
        geometry: _pickupLatLng!,
        circleRadius: 8,
        circleColor: '#2563EB',
        circleStrokeColor: '#FFFFFF',
        circleStrokeWidth: 2,
      ));
    }

    if (_dropLatLng != null) {
      await _mapController?.addCircle(CircleOptions(
        geometry: _dropLatLng!,
        circleRadius: 8,
        circleColor: '#F97316',
        circleStrokeColor: '#FFFFFF',
        circleStrokeWidth: 2,
      ));
    }

    // For ongoing, show driver marker if we have live location
    if (_isOngoing) {
      final driverLoc = ref.read(bookingUserViewModelProvider).driverLocation;
      if (driverLoc != null && driverLoc.length == 2) {
        await _mapController?.addSymbol(SymbolOptions(
          geometry: LatLng(driverLoc[0], driverLoc[1]),
          iconImage: 'vehicle_marker',
          iconSize: 0.4,
        ));
      }
    }

    if (_pickupLatLng != null && _dropLatLng != null) {
      final screenHeight = MediaQuery.of(context).size.height;
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              [_pickupLatLng!.latitude, _dropLatLng!.latitude]
                  .reduce((a, b) => a < b ? a : b),
              [_pickupLatLng!.longitude, _dropLatLng!.longitude]
                  .reduce((a, b) => a < b ? a : b),
            ),
            northeast: LatLng(
              [_pickupLatLng!.latitude, _dropLatLng!.latitude]
                  .reduce((a, b) => a > b ? a : b),
              [_pickupLatLng!.longitude, _dropLatLng!.longitude]
                  .reduce((a, b) => a > b ? a : b),
            ),
          ),
          left: 40,
          top: 40,
          right: 40,
          bottom: 40,
        ),
      );
    }
  }

  // rebook

  Future<void> _rebook() async {
    final b = widget.booking;

    // Navigate to booking details screen which then goes to driver searching
    context.push(RouteNames.bookingDetails, extra: {
      'pickupCoordinates': b.pickupCoordinates,
      'dropoffCoordinates': b.dropCoordinates,
      'pickupAddress': b.pickupAddress,
      'dropoffAddress': b.dropAddress,
      'goodsTypes': b.goodsTypes,
      'selectedVehicle': b.vehicleType,
    });
  }


  void _openActiveTrip() {
    final b = widget.booking;
    context.push(RouteNames.driverFound, extra: {
      '_id': b.bookingId,
      'status': b.status.toLowerCase(),
      'pickupAddress': b.pickupAddress,
      'dropAddress': b.dropAddress,
      'distance': b.distance,
      'price': b.price,
      'vehicleType': b.vehicleType,
      'goodsTypes': b.goodsTypes,
      'estimatedArrival': b.estimatedArrival,
      'pickupLocation': {'coordinates': b.pickupCoordinates},
      'dropLocation': {'coordinates': b.dropCoordinates},
      'driverId': b.driver != null ? {
        'username': b.driver!.username,
        'phone': b.driver!.phone,
        'vehicleModel': b.driver!.vehicleModel ?? '',
        'numberPlate': b.driver!.numberPlate ?? '',
        'vehicleColor': b.driver!.vehicleColor ?? '',
      } : null,
      'tripCount': b.driver?.tripCount ?? 0,
    });
  }


  // build
  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final driver = b.driver;
    final driverName = driver?.username ?? 'Driver';
    final vehicleModel = driver?.vehicleModel ?? '';
    final vehicleColor = driver?.vehicleColor ?? '';
    final numberPlate = driver?.numberPlate ?? '';

    final distance = b.distance ?? 0.0;
    final price = b.price ?? 0;

    // Date header: use acceptedAt or createdAt
    final headerDate = _formatDate(b.acceptedAt ?? b.createdAt);
    final headerTime = _formatTime(b.acceptedAt ?? b.createdAt);

    final mapTilerKey = dotenv.env['MAPTILER_API_KEY'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // TOP BAR
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back_ios,
                          size: 25, color: Colors.black),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            headerDate,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            headerTime,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF373737),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 36), // balance back arrow
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // MAP or PROOF IMAGE
              // Center(
              //   child: GestureDetector(
              //     onTap: _isOngoing ? _openActiveTrip : null,
              //     child: ClipRRect(
              //       borderRadius: BorderRadius.circular(10),
              //       child: SizedBox(
              //         width: 403,
              //         height: 194,
              //         child: _isCompleted
              //             ? _buildProofImage()
              //             : _buildMap(mapTilerKey),
              //       ),
              //     ),
              //   ),
              // ),


              Center(
                child: SizedBox(
                  width: 403,
                  height: 194,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 403,
                          height: 194,
                          child: _isCompleted
                              ? _buildProofImage()
                              : _buildMap(mapTilerKey),
                        ),
                      ),

                      if (_isOngoing)
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              // onTap: _openActiveTrip,
                              onTap: () {
                                _openActiveTrip();
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // STATUS
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          'Delivery • ${_statusLabel()}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: _statusColor(),
                          ),
                        ),
                        const Spacer(),
                        Image.asset(_vehicleImage(), width: 32, height: 32),
                      ],
                    ),

                    const SizedBox(height: 7),

                    // ROUTE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 4),
                              Container(
                                width: 8,
                                height: 13,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 1.5,
                                height: 23,
                                color: const Color(0xFFB7B7B7),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF97316),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.pickupAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF000000),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                b.dropAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Pickup / drop times
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _pickupTime(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF434343),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _dropTime(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF434343),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 23),

                    // DURATION / DISTANCE
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          _metricCell(
                            iconWidget: Image.asset('assets/images/time.png', width: 16, height: 16),
                            label: 'Duration',
                            value: _formatDuration(),
                          ),
                          const SizedBox(width: 139),
                          _metricCell(
                            iconWidget: Image.asset('assets/images/map.png', width: 16, height: 16),
                            label: 'Distance',
                            value: '${distance.toStringAsFixed(1)} km',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 21),

                    // DRIVER CARD
                    Container(
                      padding: const EdgeInsets.all(14),
                      height: 105,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE9E9E9),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: const Color(0xFF1E3A8A),
                            child: Text(
                              driverName.isNotEmpty
                                  ? driverName[0].toUpperCase()
                                  : 'D',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 21),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driverName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                if (vehicleColor.isNotEmpty || vehicleModel.isNotEmpty)
                                  Text(
                                    [
                                      if (vehicleColor.isNotEmpty) vehicleColor,
                                      if (vehicleModel.isNotEmpty) vehicleModel,
                                    ].join(' • '),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF585858),
                                    ),
                                  ),
                                if (numberPlate.isNotEmpty)
                                  Text(
                                    numberPlate,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF585858),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // PRICE CARD
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        border: const Border(
                          top: BorderSide(
                            color: Color(0xFF000000),
                            width: 0.5,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'I paid',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 11),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Fare',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF000000),
                                ),
                              ),
                              Text(
                                'NRP $price',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset('assets/images/cash.png', width: 16, height: 16),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Total paid',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                // Completed: paid; ongoing/cancelled: 0
                                _isCompleted ? 'NRP $price' : 'NRP 0',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ACTIONS (completed & cancelled only)
                    if (!_isOngoing) ...[
                      const SizedBox(height: 20),

                      // Re-Book
                      Center(
                        child: SizedBox(
                          width: 260,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _rebook,
                            child: const Text(
                              'Re-Book',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Remove from history
                      Center(
                        child: SizedBox(
                          width: 260,
                          height: 54,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFF8FAFC),
                              side: const BorderSide(
                                color: Color(0xFFD71717),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => _confirmRemove(context),
                            child: const Text(
                              'Remove from history',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD71717),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // sub-widgets

  Widget _buildMap(String mapTilerKey) {
    return MapLibreMap(
      styleString:
      'https://api.maptiler.com/maps/bright/style.json?key=$mapTilerKey',
      initialCameraPosition: CameraPosition(
        target: _pickupLatLng ?? const LatLng(27.7172, 85.3240),
        zoom: 13,
      ),
      zoomGesturesEnabled: false,
      scrollGesturesEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      compassEnabled: false,
      onMapCreated: (c) => _mapController = c,
      onStyleLoadedCallback: _onStyleLoaded,
    );
  }

  Widget _buildProofImage() {
    final url = _proofImageUrl;
    if (url.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Text('No proof image',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Text('Image unavailable',
              style: TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }

  Widget _metricCell({
    IconData? icon,
    Widget? iconWidget,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            iconWidget ??
                Icon(icon, size: 16, color: const Color(0xFF434343)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF434343),
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),
        Row(
          children: [
            // offset to align with label text (icon width + gap)
            const SizedBox(width: 21),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // void _confirmRemove(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  //       title: const Text('Remove from history?'),
  //       content: const Text(
  //           'This booking will be removed from your history list.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel',
  //               style: TextStyle(color: Colors.black)),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             ref.read(bookingUserViewModelProvider.notifier)
  //                 .removeFromHistory(widget.booking.bookingId ?? '');
  //             context.pop();
  //           },
  //           child: const Text('Remove',
  //               style: TextStyle(color: Color(0xFFD71717))),
  //         ),
  //       ],
  //     ),
  //   );
  // }


  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 430,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Cross Icon
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFF44336),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(height:25),

              // Title
              const Text(
                'Delete Request History?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF44336),
                ),
              ),

              const SizedBox(height: 7),

              // Description
              const Text(
                'Are you sure you want to remove this booking from your history? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF4D4D4D),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 29),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // Remove
                  SizedBox(
                    width: 112,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFF44336),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(
                            color: Color(0xFFFF8A3D),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();

                        ref
                            .read(bookingUserViewModelProvider.notifier)
                            .removeFromHistory(
                          widget.booking.bookingId ?? '',
                        );

                        context.pop();
                      },
                      child: const Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 50),

                  // Cancel
                  SizedBox(
                    width: 112,
                    height: 40,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: Colors.black,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}