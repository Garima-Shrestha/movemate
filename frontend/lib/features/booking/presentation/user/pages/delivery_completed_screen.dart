import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../config/routes/route_names.dart';
import 'package:flutter/services.dart';

class DeliveryCompletedScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const DeliveryCompletedScreen({super.key, required this.bookingData});

  String _getVehicleType() {
    final type = (bookingData['vehicleType'] ?? 'Vehicle').toString();
    return type[0].toUpperCase() + type.substring(1);
  }

  String _formatDuration() {
    final startedAt = bookingData['startedAt'];
    final completedAt = bookingData['completedAt'];

    if (startedAt == null || completedAt == null) return '--';

    try {
      final start = DateTime.parse(startedAt.toString());
      final end = DateTime.parse(completedAt.toString());

      final diff = end.difference(start);

      if (diff.inSeconds < 60) {
        return '${diff.inSeconds} sec';
      }

      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;

      if (hours > 0) {
        return '$hours hr $minutes min';
      }

      return '$minutes min';
    } catch (_) {
      return '--';
    }
  }

  String _getVehicleImage() {
    switch ((bookingData['vehicleType'] ?? '').toString().toLowerCase()) {
      case 'pickup':
        return 'assets/images/pickup.png';
      case 'truck':
        return 'assets/images/truck.png';
      case 'tempo':
      default:
        return 'assets/images/tempo.png';
    }
  }


  @override
  Widget build(BuildContext context){
    final pickupAddress = bookingData['pickupAddress'] ?? '';
    final dropAddress = bookingData['dropAddress'] ?? '';
    final distance = (bookingData['distance'] as num?)?.toDouble() ?? 0.0;
    final price = (bookingData['price'] as num?)?.toInt() ?? 0;

    final driver = bookingData['driverId'];
    final driverName = driver is Map ? (driver['username'] ?? 'Driver') : 'Driver';
    final numberPlate = driver is Map ? (driver['numberPlate'] ?? '') : '';
    final vehicleModel = driver is Map ? (driver['vehicleModel'] ?? '') : '';
    final vehicleColor = driver is Map ? (driver['vehicleColor'] ?? '') : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
          child: Column(
            children: [

              // ── SUCCESS ICON ──
              Image.asset(
                'assets/images/confirm.png',
                width: 95,
                height: 95,
              ),
              const SizedBox(height: 15),

              const Text(
                'Delivery Completed!',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D8EA5),
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Your goods have been delivered successfully.\nThank you for using our service.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // ── STATS GRID ──
              SizedBox(
                width: 315,
                height: 154,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFA8A8A8),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        offset: const Offset(0, 6),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _statCell(
                            iconWidget: Image.asset(
                              'assets/images/cash.png',
                              width: 14,
                              height: 14,
                            ),
                            label: 'Fare Details',
                            value: 'NRP $price',
                            iconColor: const Color(0xFF1A68EE),
                          ),
                          _verticalDivider(),
                          _statCell(
                            iconWidget: Image.asset(
                              'assets/images/map.png',
                              width: 14,
                              height: 14,
                            ),
                            label: 'Travel Metrics',
                            value: '${distance.toStringAsFixed(1)} km',
                            iconColor: const Color(0xFF1A68EE),
                          ),
                        ],
                      ),
                      const Divider(
                        height: 24,
                        color: Color(0xFFC8C8C8),
                        thickness: 0.5,
                      ),
                      Row(
                        children: [
                          _statCell(
                            iconWidget: Image.asset(
                              'assets/images/time.png',
                              width: 14,
                              height: 14,
                            ),
                            label: 'Delivery Duration',
                            value: _formatDuration(),
                            iconColor: const Color(0xFF1A68EE),
                          ),
                          _verticalDivider(),
                          _statCell(
                            iconWidget: Image.asset(
                              _getVehicleImage(),
                              width: 31,
                              height: 31,
                              fit: BoxFit.contain,
                            ),
                            label: 'Vehicle Used',
                            value: _getVehicleType(),
                            iconColor: const Color(0xFF1A68EE),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 46),

              // ── ROUTE ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        Container(
                          width: 2,
                          height: 48,
                          color: const Color(0xFFB7B7B7),
                        ),
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
                    const SizedBox(width: 22),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PICK-UP',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            pickupAddress,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'DROP-OFF',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            dropAddress,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 27),

              // ── DRIVER CARD ──
              Container(
                width: 393,
                height: 106,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEEF7),
                  border: Border.all(
                    color: const Color(0xFF8E9FE6),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:0),
                          child: CircleAvatar(
                            radius: 29,
                            backgroundColor: const Color(0xFF1E3A8A),
                            child: Text(
                              driverName.isNotEmpty
                                  ? driverName[0].toUpperCase()
                                  : 'D',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driverName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  [
                                    if (numberPlate.isNotEmpty) numberPlate,
                                    if (vehicleModel.isNotEmpty) vehicleModel,
                                    if (vehicleColor.isNotEmpty) vehicleColor,
                                  ].join(' • '),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF585858),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    Positioned(
                      left: -1,
                      bottom: -1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06C300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── BACK TO HOME BUTTON ──
              Container(
                width: 230,
                height: 57,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2255E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => context.go(RouteNames.userHome),
                  child: const Text(
                    'Back to home',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

        Container(
          width: 230,
          height: 57,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF2255E5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                offset: const Offset(0, 4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                context.push(
                  RouteNames.userProofOfDelivery,
                  extra: bookingData,
                );
              },
              child: const Center(
                child: Text(
                  'Proof of delivery',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCell({
    IconData? icon,
    Widget? iconWidget,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              if (iconWidget != null)
                iconWidget
              else
                Icon(
                  icon,
                  size: 18,
                  color: iconColor,
                ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFFC8C8C8),
    );
  }
}