import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/app_usecase.dart';
import '../../data/repositories/booking_repository.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

final getMyBookingsUsecaseProvider = Provider<GetMyBookingsUsecase>((ref) {
  return GetMyBookingsUsecase(bookingRepository: ref.read(bookingRepositoryProvider));
});

class GetMyBookingsUsecase implements UsecaseWithoutParams<List<BookingEntity>> {
  final IBookingRepository _bookingRepository;

  GetMyBookingsUsecase({required IBookingRepository bookingRepository})
      : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, List<BookingEntity>>> call() {
    return _bookingRepository.getMyBookings();
  }
}