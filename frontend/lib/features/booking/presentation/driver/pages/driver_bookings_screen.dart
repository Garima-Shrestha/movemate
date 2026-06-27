import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../config/routes/route_names.dart';
import '../../../../../core/utils/snackbar_utils.dart';
import '../../../../auth/presentation/view_model/auth_view_model.dart';
import '../view_model/driver_booking_view_model.dart';
import '../state/driver_booking_state.dart';
import '../../../domain/entities/booking_entity.dart';
import '../widgets/driver_cancel_pickup_dialog.dart';
import '../../../../../core/services/socket/socket_service.dart';

class DriverBookingsScreen extends ConsumerStatefulWidget {
  const DriverBookingsScreen({super.key});

  @override
  ConsumerState<DriverBookingsScreen> createState() =>
      _DriverBookingsScreenState();
}

class _DriverBookingsScreenState extends ConsumerState<DriverBookingsScreen> {
  late final SocketService _socket;

  @override
  void initState() {
    super.initState();
    Future.microtask(
            () => ref.read(driverBookingViewModelProvider.notifier).fetchMyBookings());
    _listenToSocket();
  }

  void _listenToSocket() {
    _socket = ref.read(socketServiceProvider);

    _socket.off('bookingCancelledByUser');
    _socket.on('bookingCancelledByUser', (data) {
      print("BOOKING CANCELLED BY USER - DRIVER BOOKINGS SCREEN");
      if (!mounted) return;

      ref.read(driverBookingViewModelProvider.notifier).fetchMyBookings();
      SnackbarUtils.showError(context, 'User cancelled the booking.');
    });
  }

  @override
  void dispose() {
    _socket.off('bookingCancelledByUser');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(driverBookingViewModelProvider);

    ref.listen<DriverBookingState>(driverBookingViewModelProvider, (prev, next) {
      if (next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
      if (next.successMessage != null) {
        SnackbarUtils.showSuccess(context, next.successMessage!);
      }
    });

    final activeBookings = state.bookings
        .where((b) => b.status == 'accepted' || b.status == 'ongoing')
        .toList();
    final pastBookings = state.bookings
        .where((b) => b.status == 'completed' || b.status == 'cancelled')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(driverBookingViewModelProvider.notifier).fetchMyBookings(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) {
                context.go(RouteNames.login, extra: 'driver');
              }
            },
          ),
        ],
      ),
      body: state.status == DriverBookingStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () =>
            ref.read(driverBookingViewModelProvider.notifier).fetchMyBookings(),
        child: state.bookings.isEmpty
            ? const Center(
          child: Text(
            'No bookings yet.',
            style: TextStyle(color: Colors.black54),
          ),
        )
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (activeBookings.isNotEmpty) ...[
              const Text(
                'Active Jobs',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...activeBookings.map(
                    (b) => _BookingCard(
                  booking: b,
                  // accepted: Start Trip and Cancel
                  onStart: b.status == 'accepted' && b.bookingId != null
                      ? () => ref
                      .read(driverBookingViewModelProvider.notifier)
                      .startTrip(b.bookingId!)
                      : null,
                  // ongoing: View Trip and Cancel
                  onViewTrip: b.status == 'ongoing'
                      ? () {
                    context.push(
                      RouteNames.driverTrip,
                      extra: {
                        'bookingId': b.bookingId,
                        'pickupAddress': b.pickupAddress,
                        'dropAddress': b.dropAddress,
                        'pickupCoordinates': b.pickupCoordinates,
                        'dropCoordinates': b.dropCoordinates,
                        'distance': b.distance,
                        'tripStage': b.status == 'ongoing' ? 'heading_to_pickup' : 'heading_to_pickup',
                      },
                    );
                  }
                      : null,
                  // cancel shown for both accepted and ongoing
                  onCancel: b.bookingId != null
                      ? () => _showCancelDialog(b.bookingId!)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (pastBookings.isNotEmpty) ...[
              const Text(
                'Past Bookings',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...pastBookings.map(
                    (b) => _BookingCard(booking: b),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(String bookingId) {
    showDialog(
      context: context,
      builder: (dialogContext) => DriverCancelPickupDialog(
        onContinue: () => Navigator.of(dialogContext).pop(),
        onCancel: () {
          Navigator.of(dialogContext).pop();
          ref
              .read(driverBookingViewModelProvider.notifier)
              .cancelBooking(bookingId);
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback? onStart;
  final VoidCallback? onViewTrip;
  final VoidCallback? onCancel;

  const _BookingCard({
    required this.booking,
    this.onStart,
    this.onViewTrip,
    this.onCancel,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return const Color(0xFF059500);
      case 'ongoing':  return const Color(0xFF1A33D6);
      case 'completed': return Colors.grey;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'accepted':  return const Color(0xFFD6FCD8);
      case 'ongoing':   return const Color(0xFFDDE3FF);
      case 'completed': return const Color(0xFFEEEEEE);
      case 'cancelled': return const Color(0xFFFFE0E0);
      default: return const Color(0xFFFFF3CD);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBg(booking.status),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              booking.status[0].toUpperCase() + booking.status.substring(1),
              style: TextStyle(
                color: _statusColor(booking.status),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Pickup address
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Pick-up',
                  style: TextStyle(fontSize: 13, color: Color(0xFF848484))),
            ],
          ),
          const SizedBox(height: 2),
          Text(booking.pickupAddress,
              style: const TextStyle(fontSize: 16, color: Colors.black)),

          const SizedBox(height: 10),

          // Drop address
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Drop-off',
                  style: TextStyle(fontSize: 13, color: Color(0xFF848484))),
            ],
          ),
          const SizedBox(height: 2),
          Text(booking.dropAddress,
              style: const TextStyle(fontSize: 16, color: Colors.black54)),

          const SizedBox(height: 12),

          // Goods + price
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  children: booking.goodsTypes
                      .map((g) => Chip(
                    label: Text(g,
                        style: const TextStyle(fontSize: 11)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                  ))
                      .toList(),
                ),
              ),
              Text(
                'NRP ${booking.price ?? 0}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          if (onStart != null ||
              onViewTrip != null ||
              onCancel != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                // Stage 1: accepted → Start Trip button
                if (onStart != null)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A33D6),
                      ),
                      onPressed: onStart,
                      child: const Text(
                        'Start Trip',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                // Stage 2+: ongoing → View Trip button
                if (onViewTrip != null)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A33D6),
                      ),
                      onPressed: onViewTrip,
                      child: const Text(
                        'View Trip',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),

                // Cancel always shown for active bookings
                if (onCancel != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFC10707)),
                      ),
                      onPressed: () => onCancel?.call(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFFC50000)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}