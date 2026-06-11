import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/app_usecase.dart';
import '../../data/repositories/booking_repository.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

final cancelBookingUsecaseProvider = Provider<CancelBookingUsecase>((ref) {
  return CancelBookingUsecase(bookingRepository: ref.read(bookingRepositoryProvider));
});

class CancelBookingParams extends Equatable {
  final String bookingId;

  const CancelBookingParams({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

class CancelBookingUsecase implements UsecaseWithParams<BookingEntity, CancelBookingParams> {
  final IBookingRepository _bookingRepository;

  CancelBookingUsecase({required IBookingRepository bookingRepository})
      : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, BookingEntity>> call(CancelBookingParams params) {
    return _bookingRepository.cancelBooking(params.bookingId);
  }
}