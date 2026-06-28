import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking_entity.dart';

enum BookingUserStatus {
  initial,
  loading,
  bookingCreated,
  searchingDriver,
  driverAccepted,
  tripOngoing,
  tripCompleted,
  bookingCancelled,
  historyLoaded,
  error,
}

class BookingUserState extends Equatable {
  final BookingUserStatus status;
  final List<BookingEntity> bookingsHistory;
  final BookingEntity? activeBooking;
  final String? errorMessage;
  final List<double>? driverLocation;
  final double? estimatedDistance;
  final int? tempoPrice;
  final int? pickupPrice;
  final int? truckPrice;
  final String tripSubStage;

  const BookingUserState({
    this.status = BookingUserStatus.initial,
    this.bookingsHistory = const [],
    this.activeBooking,
    this.errorMessage,
    this.driverLocation,
    this.estimatedDistance,
    this.tempoPrice,
    this.pickupPrice,
    this.truckPrice,
    this.tripSubStage = 'accepted',
  });

  // copyWith method to handle immutable state updates safely
  BookingUserState copyWith({
    BookingUserStatus? status,
    List<BookingEntity>? bookingsHistory,
    BookingEntity? activeBooking,
    String? errorMessage,
    List<double>? driverLocation,
    double? estimatedDistance,
    int? tempoPrice,
    int? pickupPrice,
    int? truckPrice,
    String? tripSubStage,
  }) {
    return BookingUserState(
      status: status ?? this.status,
      bookingsHistory: bookingsHistory ?? this.bookingsHistory,
      activeBooking: activeBooking ?? this.activeBooking,
      errorMessage: errorMessage ?? this.errorMessage,
      driverLocation: driverLocation ?? this.driverLocation,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      tempoPrice: tempoPrice ?? this.tempoPrice,
      pickupPrice: pickupPrice ?? this.pickupPrice,
      truckPrice: truckPrice ?? this.truckPrice,
      tripSubStage: tripSubStage ?? this.tripSubStage,
    );
  }

  @override
  List<Object?> get props => [status, bookingsHistory, activeBooking, errorMessage, driverLocation, estimatedDistance, tempoPrice, pickupPrice, truckPrice, tripSubStage];
}