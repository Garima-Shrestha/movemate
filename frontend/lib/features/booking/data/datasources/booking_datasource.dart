import '../models/booking_hive_model.dart';

abstract interface class IBookingLocalDataSource {
  Future<void> cacheCurrentBooking(BookingHiveModel model);
  Future<BookingHiveModel?> getCachedBooking();
  Future<void> clearCachedBooking();
}


abstract interface class IBookingRemoteDataSource {
  Future<dynamic> createBooking(dynamic bookingPayload);
  Future<dynamic> estimatePrice(dynamic payload);
  Future<List<dynamic>> getMyBookings();
  Future<dynamic> getBookingById(String bookingId);
  Future<dynamic> cancelBooking(String bookingId);
  Future<dynamic> uploadProofOfDelivery(String bookingId, String imagePath);
  Future<void> removeFromHistory(String bookingId);

  // Driver
  Future<dynamic> getDriverStats();
  Future<List<dynamic>> getDriverMyBookings();
  Future<dynamic> driverAcceptBooking(String bookingId);
  Future<dynamic> driverStartTrip(String bookingId);
  Future<void> driverArrivedAtPickup(String bookingId);
  Future<void> driverGoodsPickedUp(String bookingId);
  Future<dynamic> driverCompleteTrip(String bookingId);
  Future<dynamic> driverCancelBooking(String bookingId);
}