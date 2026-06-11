import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/socket/socket_service.dart';
import '../../../domain/usecase/cancel_booking_usecase.dart';
import '../../../domain/usecase/create_booking_usecase.dart';
import '../../../domain/usecase/estimate_booking_usecase.dart';
import '../../../domain/usecase/get_booking_by_id_usecase.dart';
import '../../../domain/usecase/get_my_bookings_usecase.dart';
import '../state/booking_user_state.dart';

final bookingUserViewModelProvider = NotifierProvider<BookingUserViewModel, BookingUserState>(
      () => BookingUserViewModel(),
);

class BookingUserViewModel extends Notifier<BookingUserState> {
  late final CreateBookingUsecase _createBookingUsecase;
  late final EstimatePriceUsecase _estimatePriceUsecase;
  late final GetMyBookingsUsecase _getMyBookingsUsecase;
  late final GetBookingByIdUsecase _getBookingByIdUsecase;
  late final CancelBookingUsecase _cancelBookingUsecase;
  late final SocketService _socketService;

  @override
  BookingUserState build() {
    _createBookingUsecase = ref.read(createBookingUsecaseProvider);
    _estimatePriceUsecase = ref.read(estimatePriceUsecaseProvider);
    _getMyBookingsUsecase = ref.read(getMyBookingsUsecaseProvider);
    _getBookingByIdUsecase = ref.read(getBookingByIdUsecaseProvider);
    _cancelBookingUsecase = ref.read(cancelBookingUsecaseProvider);
    _socketService = ref.read(socketServiceProvider);

    // Automatically fetch booking history lists on component mounting
    Future.microtask(() => getMyBookingsHistory());

    // listen for driver location updates coming from backend
    _socketService.on('driverLocation', (data) {
      updateDriverLocation(
        (data['lat'] as num).toDouble(),
        (data['lng'] as num).toDouble(),
      );
    });


    return const BookingUserState();
  }

  // Create a New Booking Request (Request a Ride)
  Future<void> createBooking({
    required String vehicleType,
    required List<double> pickupCoordinates,
    required List<double> dropCoordinates,
    required List<String> goodsTypes,
    required String pickupAddress,
    required String dropAddress,
  }) async {
    state = state.copyWith(status: BookingUserStatus.loading);

    final params = CreateBookingParams(
      vehicleType: vehicleType,
      pickupCoordinates: pickupCoordinates,
      dropCoordinates: dropCoordinates,
      goodsTypes: goodsTypes,
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
    );

    final result = await _createBookingUsecase.call(params);

    result.fold(
          (failure) {
        state = state.copyWith(
          status: BookingUserStatus.error,
          errorMessage: failure.message,
        );
      },
          (createdBooking) {
        state = state.copyWith(
          status: BookingUserStatus.bookingCreated,
          activeBooking: createdBooking,
          errorMessage: null,
        );
        // Switch view status immediately to the pulse/searching animations screen
        startSearchingDriver();
      },
    );
  }

  // Helper status changer to handle searching animations cleanly
  void startSearchingDriver() {
    if (state.activeBooking != null) {
      state = state.copyWith(status: BookingUserStatus.searchingDriver);
    }
  }

  // Refresh / Fetch Live Updates for a Single Active Trip (Polled or Socket Triggered)
  Future<void> refreshActiveBookingStatus(String bookingId) async {
    final params = GetBookingByIdParams(bookingId: bookingId);
    final result = await _getBookingByIdUsecase.call(params);

    result.fold(
          (failure) {
        state = state.copyWith(
          status: BookingUserStatus.error,
          errorMessage: failure.message,
        );
      },
          (liveBooking) {
        // Evaluate incoming dynamic back-end lifecycle transitions
        BookingUserStatus targetStatus = state.status;

        switch (liveBooking.status) {
          case 'pending':
            targetStatus = BookingUserStatus.searchingDriver;
            break;
          case 'accepted':
            targetStatus = BookingUserStatus.driverAccepted;
            break;
          case 'ongoing':
            targetStatus = BookingUserStatus.tripOngoing;
            break;
          case 'completed':
            targetStatus = BookingUserStatus.tripCompleted;
            break;
          case 'cancelled':
            targetStatus = BookingUserStatus.bookingCancelled;
            break;
        }

        state = state.copyWith(
          status: targetStatus,
          activeBooking: liveBooking,
          errorMessage: null,
        );
      },
    );
  }

  // Get Complete User Booking Ride History Logs
  Future<void> getMyBookingsHistory() async {
    state = state.copyWith(status: BookingUserStatus.loading);

    final result = await _getMyBookingsUsecase.call();

    result.fold(
          (failure) {
        state = state.copyWith(
          status: BookingUserStatus.error,
          errorMessage: failure.message,
        );
      },
          (historyList) {
        state = state.copyWith(
          status: BookingUserStatus.historyLoaded,
          bookingsHistory: historyList,
          errorMessage: null,
        );
      },
    );
  }

  // Cancel Active Ride Booking
  Future<void> cancelBooking(String bookingId) async {
    state = state.copyWith(status: BookingUserStatus.loading);

    final params = CancelBookingParams(bookingId: bookingId);
    final result = await _cancelBookingUsecase.call(params);

    result.fold(
          (failure) {
        state = state.copyWith(
          status: BookingUserStatus.error,
          errorMessage: failure.message,
        );
      },
          (cancelledBooking) {
        state = state.copyWith(
          status: BookingUserStatus.bookingCancelled,
          activeBooking: cancelledBooking,
          errorMessage: null,
        );
      },
    );
  }

  void updateDriverLocation(double lat, double lng) {
    state = state.copyWith(
      driverLocation: [lat, lng],
    );
  }

  Future<void> estimatePrice({
    required List<double> pickupCoordinates,
    required List<double> dropCoordinates,
  }) async {
    final result = await _estimatePriceUsecase.call(
      EstimatePriceParams(
        payload: {
          "pickupLocation": {
            "type": "Point",
            "coordinates": pickupCoordinates,
          },
          "dropLocation": {
            "type": "Point",
            "coordinates": dropCoordinates,
          },
        },
      ),
    );

    result.fold(
          (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
        );
      },
          (data) {
        state = state.copyWith(
          estimatedDistance:
          (data['distance'] as num?)?.toDouble(),

          tempoPrice:
          data['tempo'] as int?,

          pickupPrice:
          data['pickup'] as int?,

          truckPrice:
          data['truck'] as int?,
        );
      },
    );
  }

  // State Management Utility Closures
  void clearActiveTrip() {
    state = state.copyWith(
      status: BookingUserStatus.initial,
      activeBooking: null,
      driverLocation: null,
      errorMessage: null,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}