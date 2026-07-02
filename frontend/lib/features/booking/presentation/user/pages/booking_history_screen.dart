import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/booking_user_state.dart';
import '../view_model/booking_user_view_model.dart';
import '../../../domain/entities/booking_entity.dart';
import 'package:go_router/go_router.dart';
import '../../../../../config/routes/route_names.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState
    extends ConsumerState<BookingHistoryScreen> {

  // @override
  // void initState() {
  //   super.initState();
  //
  //   Future.microtask(() {
  //     ref.read(bookingUserViewModelProvider.notifier,).getMyBookingsHistory();
  //   });
  // }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final state = ref.read(bookingUserViewModelProvider);
      if (state.bookingsHistory.isEmpty) {
        ref.read(bookingUserViewModelProvider.notifier).getMyBookingsHistory();
      }
    });
  }

  String _vehicleImage(String type) {
    switch (type.toLowerCase()) {
      case 'pickup':
        return 'assets/images/pickup.png';
      case 'truck':
        return 'assets/images/truck.png';
      default:
        return 'assets/images/tempo.png';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final nepalTime = date.toUtc().add(
      const Duration(hours: 5, minutes: 45),
    );

    return '${nepalTime.day} ${months[nepalTime.month]}';
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '-';

    final nepalTime = date.toUtc().add(
      const Duration(hours: 5, minutes: 45),
    );

    final hour =
    nepalTime.hour > 12
        ? nepalTime.hour - 12
        : (nepalTime.hour == 0 ? 12 : nepalTime.hour);

    final minute =
    nepalTime.minute.toString().padLeft(2, '0');

    final period =
    nepalTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  Widget _bookingCard(BookingEntity booking) {
    final acceptedTime = booking.acceptedAt ?? booking.createdAt;

    return Container(
      margin: const EdgeInsets.only(
        left: 4,
        right: 3,
        bottom: 12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDF8),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Image.asset(
            _vehicleImage(booking.vehicleType),
            width: 65,
            height: 65,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (booking.status == 'ongoing')
                  const Text(
                    'Ongoing',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF00D819),
                    ),
                  ),

                if (booking.status == 'completed')
                  Text(
                    booking.pickupAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6A6A6A),
                    ),
                  ),

                if (booking.status == 'cancelled')
                  Text(
                    booking.cancelledBy == 'driver'
                        ? 'Driver cancelled'
                        : 'You cancelled',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFFD50202),
                    ),
                  ),

                Transform.translate(
                  offset: const Offset(0, -2),
                  child: Text(
                    booking.dropAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 0),

                Transform.translate(
                  offset: const Offset(0, 1),
                  child: Text(
                    _formatTime(acceptedTime),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 30, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'NRP ${booking.price ?? 0}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingUserViewModelProvider);
    final bookings = state.bookingsHistory;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),
              const Padding(
                padding: EdgeInsets.only(left: 14),
                child: Text(
                  'Booking History',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 20),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(bookingUserViewModelProvider.notifier)
                    .getMyBookingsHistory();
              },
              // child: state.status == BookingUserStatus.loading
              //     ? const Center(
              //   child: CircularProgressIndicator(),
              // )
              //     : ListView.builder(
              child: state.status == BookingUserStatus.loading && bookings.isEmpty
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : bookings.isEmpty && state.status == BookingUserStatus.error
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Failed to load bookings.',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => ref
                          .read(bookingUserViewModelProvider.notifier)
                          .getMyBookingsHistory(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
                  : bookings.isEmpty
                  ? const Center(
                child: Text('No bookings yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 15)),
              )
                  : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final currentDate = booking.createdAt ?? DateTime.now();

                    final showDate = index == 0 ||
                            _formatDate(bookings[index - 1]
                                  .createdAt ??
                                  DateTime.now(),
                            ) !=
                                _formatDate(
                                  currentDate,
                                );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDate)
                          Padding(
                            padding: EdgeInsets.only(
                              left: 16,
                              bottom: 12, // date and rectangle
                              top: index == 0 ? 0 : 24, // rectangle and next date
                            ),
                            child: Text(
                              _formatDate(currentDate),
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),

                        // _bookingCard(
                        //   booking,
                        // ),

                        GestureDetector(
                          onTap: () {
                            context.push(
                              RouteNames.bookingHistoryDetail,
                              extra: booking,
                            );
                          },
                          child: _bookingCard(
                            booking,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}