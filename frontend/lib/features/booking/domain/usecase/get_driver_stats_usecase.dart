import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/app_usecase.dart';
import '../../data/repositories/booking_repository.dart';
import '../repositories/booking_repository.dart';

final getDriverStatsUsecaseProvider =
Provider<GetDriverStatsUsecase>((ref) {
  return GetDriverStatsUsecase(
    bookingRepository: ref.read(
      bookingRepositoryProvider,
    ),
  );
});

class GetDriverStatsUsecase
    implements UsecaseWithoutParams<Map<String, dynamic>> {
  final IBookingRepository _bookingRepository;

  GetDriverStatsUsecase({
    required IBookingRepository bookingRepository,
  }) : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call() {
    return _bookingRepository.getDriverStats();
  }
}