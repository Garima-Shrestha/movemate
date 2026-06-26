import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/remote/booking_remote_datasource.dart';
import '../../../data/models/booking_api_model.dart';
import '../state/driver_booking_state.dart';

final driverBookingViewModelProvider =
NotifierProvider<DriverBookingViewModel, DriverBookingState>(
        () => DriverBookingViewModel());

class DriverBookingViewModel extends Notifier<DriverBookingState> {
  late final BookingRemoteDataSource _remote;

  @override
  DriverBookingState build() {
    _remote = ref.read(bookingRemoteDataSourceProvider);
    Future.microtask(() => fetchMyBookings());
    return const DriverBookingState();
  }

  Future<void> fetchMyBookings() async {
    state = state.copyWith(status: DriverBookingStatus.loading, errorMessage: null, successMessage: null);
    try {
      final rawList = await _remote.getDriverMyBookings();
      final bookings = rawList
          .map((json) => BookingApiModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
      state = state.copyWith(status: DriverBookingStatus.loaded, bookings: bookings);
    } catch (e) {
      state = state.copyWith(status: DriverBookingStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> startTrip(String bookingId) async {
    try {
      await _remote.driverStartTrip(bookingId);
      state = state.copyWith(successMessage: "Trip started", activeBookingId: bookingId);
      await fetchMyBookings();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> arrivedAtPickup(String bookingId) async {
    try {
      await _remote.driverArrivedAtPickup(bookingId);
      state = state.copyWith(successMessage: "Arrived at pickup");
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> goodsPickedUp(String bookingId) async {
    try {
      await _remote.driverGoodsPickedUp(bookingId);
      state = state.copyWith(successMessage: "Goods picked up");
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> completeTrip(String bookingId) async {
    try {
      await _remote.driverCompleteTrip(bookingId);
      state = state.copyWith(successMessage: "Trip completed", activeBookingId: null, tripStage: 'heading_to_pickup');
      await fetchMyBookings();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _remote.driverCancelBooking(bookingId);
      state = state.copyWith(successMessage: "Booking cancelled", tripStage: 'heading_to_pickup');
      await fetchMyBookings();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> completeTripWithProof(
      String bookingId,
      String imagePath,
      ) async {
    try {
      await _remote.uploadProofOfDelivery(
        bookingId,
        imagePath,
      );

      await _remote.driverCompleteTrip(
        bookingId,
      );

      state = state.copyWith(
        successMessage: "Trip completed",
        activeBookingId: null,
      );

      await fetchMyBookings();
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
      );
    }
  }

  void updateTripStage(String stage) {
    state = state.copyWith(tripStage: stage);
  }
}