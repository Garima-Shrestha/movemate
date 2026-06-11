import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/booking_entity.dart';

abstract interface class IBookingRepository {
  Future<Either<Failure, BookingEntity>> createBooking(BookingEntity booking);
  Future<Either<Failure, Map<String, dynamic>>> estimatePrice(Map<String, dynamic> payload);
  Future<Either<Failure, List<BookingEntity>>> getMyBookings();
  Future<Either<Failure, BookingEntity>> getBookingById(String bookingId);
  Future<Either<Failure, BookingEntity>> cancelBooking(String bookingId);

  // Driver
  Future<Either<Failure, Map<String, dynamic>>> getDriverStats();
}