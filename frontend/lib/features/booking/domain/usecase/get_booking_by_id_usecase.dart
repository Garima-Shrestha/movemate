import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/app_usecase.dart';
import '../../data/repositories/booking_repository.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

final getBookingByIdUsecaseProvider = Provider<GetBookingByIdUsecase>((ref) {
  return GetBookingByIdUsecase(bookingRepository: ref.read(bookingRepositoryProvider));
});

class GetBookingByIdParams extends Equatable {
  final String bookingId;

  const GetBookingByIdParams({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

class GetBookingByIdUsecase implements UsecaseWithParams<BookingEntity, GetBookingByIdParams> {
  final IBookingRepository _bookingRepository;

  GetBookingByIdUsecase({required IBookingRepository bookingRepository})
      : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, BookingEntity>> call(GetBookingByIdParams params) {
    return _bookingRepository.getBookingById(params.bookingId);
  }
}