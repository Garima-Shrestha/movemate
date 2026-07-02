import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/app_usecase.dart';
import '../../data/repositories/booking_repository.dart';
import '../repositories/booking_repository.dart';

final removeBookingHistoryUsecaseProvider =
Provider<RemoveBookingHistoryUsecase>((ref) {
  return RemoveBookingHistoryUsecase(
    bookingRepository: ref.read(
      bookingRepositoryProvider,
    ),
  );
});

class RemoveBookingHistoryParams extends Equatable {
  final String bookingId;

  const RemoveBookingHistoryParams({
    required this.bookingId,
  });

  @override
  List<Object?> get props => [bookingId];
}

class RemoveBookingHistoryUsecase
    implements UsecaseWithParams<void, RemoveBookingHistoryParams> {
  final IBookingRepository _bookingRepository;

  RemoveBookingHistoryUsecase({
    required IBookingRepository bookingRepository,
  }) : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, void>> call(
      RemoveBookingHistoryParams params,
      ) {
    return _bookingRepository.removeFromHistory(
      params.bookingId,
    );
  }
}