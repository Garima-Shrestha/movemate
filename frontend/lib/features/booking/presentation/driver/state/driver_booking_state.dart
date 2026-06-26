import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking_entity.dart';

enum DriverBookingStatus { initial, loading, loaded, error }

const Object _sentinel = Object();

class DriverBookingState extends Equatable {
  final DriverBookingStatus status;
  final List<BookingEntity> bookings;
  final String tripStage;
  final String? activeBookingId;  // set when trip is ongoing
  final String? errorMessage;
  final String? successMessage;

  const DriverBookingState({
    this.status = DriverBookingStatus.initial,
    this.bookings = const [],
    this.tripStage = 'heading_to_pickup',
    this.activeBookingId,
    this.errorMessage,
    this.successMessage,
  });

  DriverBookingState copyWith({
    DriverBookingStatus? status,
    List<BookingEntity>? bookings,
    String? tripStage,
    Object? activeBookingId = _sentinel,  // sentinel pattern
    String? errorMessage,
    String? successMessage,
  }) {
    return DriverBookingState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      tripStage: tripStage ?? this.tripStage,
      activeBookingId: activeBookingId == _sentinel
          ? this.activeBookingId
          : activeBookingId as String?,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, bookings, activeBookingId, errorMessage, successMessage];
}