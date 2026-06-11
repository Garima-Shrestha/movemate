import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/app_usecase.dart';
import '../../data/repositories/booking_repository.dart';
import '../repositories/booking_repository.dart';

final estimatePriceUsecaseProvider =
Provider<EstimatePriceUsecase>((ref) {
  return EstimatePriceUsecase(
    bookingRepository: ref.read(
      bookingRepositoryProvider,
    ),
  );
});

class EstimatePriceParams extends Equatable {
  final Map<String, dynamic> payload;

  const EstimatePriceParams({
    required this.payload,
  });

  @override
  List<Object?> get props => [payload];
}

class EstimatePriceUsecase
    implements UsecaseWithParams<
        Map<String, dynamic>,
        EstimatePriceParams> {
  final IBookingRepository _bookingRepository;

  EstimatePriceUsecase({
    required IBookingRepository bookingRepository,
  }) : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      EstimatePriceParams params,
      ) {
    return _bookingRepository.estimatePrice(
      params.payload,
    );
  }
}