import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/app_usecase.dart';
import '../../data/repositories/booking_repository.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

final createBookingUsecaseProvider = Provider<CreateBookingUsecase>((ref) {
  return CreateBookingUsecase(bookingRepository: ref.read(bookingRepositoryProvider));
});

class CreateBookingParams extends Equatable {
  final String vehicleType;
  final List<double> pickupCoordinates;
  final List<double> dropCoordinates;
  final List<String> goodsTypes;
  final String pickupAddress;
  final String dropAddress;

  const CreateBookingParams({
    required this.vehicleType,
    required this.pickupCoordinates,
    required this.dropCoordinates,
    required this.goodsTypes,
    required this.pickupAddress,
    required this.dropAddress,
  });

  @override
  List<Object?> get props => [vehicleType, pickupCoordinates, dropCoordinates, goodsTypes, pickupAddress, dropAddress,];
}

class CreateBookingUsecase implements UsecaseWithParams<BookingEntity, CreateBookingParams> {
  final IBookingRepository _bookingRepository;

  CreateBookingUsecase({required IBookingRepository bookingRepository})
      : _bookingRepository = bookingRepository;

  @override
  Future<Either<Failure, BookingEntity>> call(CreateBookingParams params) {
    final entity = BookingEntity(
      vehicleType: params.vehicleType,
      pickupCoordinates: params.pickupCoordinates,
      dropCoordinates: params.dropCoordinates,
      goodsTypes: params.goodsTypes,
      pickupAddress: params.pickupAddress,
      dropAddress: params.dropAddress,
    );
    return _bookingRepository.createBooking(entity);
  }
}