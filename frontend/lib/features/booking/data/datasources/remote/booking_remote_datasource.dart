import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/services/storage/token_service.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/api/api_endpoints.dart';
import '../booking_datasource.dart';

// Provider setup for Riverpod
final bookingRemoteDataSourceProvider = Provider<BookingRemoteDataSource>((ref) {
  return BookingRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class BookingRemoteDataSource implements IBookingRemoteDataSource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  BookingRemoteDataSource({
    required ApiClient apiClient,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  @override
  Future<dynamic> createBooking(dynamic bookingPayload) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.post(
      ApiEndpoints.baseBookings,
      data: bookingPayload,
      options: Options(
        headers: {
          if (token != null) "Authorization": "Bearer $token",
        },
      ),
    );

    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception(response.data['message'] ?? "Failed to create booking");
  }

  @override
  Future<dynamic> estimatePrice(dynamic payload) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.post(
      ApiEndpoints.estimateBookingPrice,
      data: payload,
      options: Options(
        headers: {
          if (token != null)
            "Authorization": "Bearer $token",
        },
      ),
    );

    if (response.data['success'] == true) {
      return response.data['data'];
    }

    throw Exception(
      response.data['message'] ??
          "Failed to estimate price",
    );
  }

  @override
  Future<List<dynamic>> getMyBookings() async {
    final token = _tokenService.getToken();

    final response = await _apiClient.get(
      ApiEndpoints.baseBookings,
      options: Options(
        headers: {
          if (token != null) "Authorization": "Bearer $token",
        },
      ),
    );

    if (response.data['success'] == true) {
      return response.data['data'] as List<dynamic>;
    }
    throw Exception(response.data['message'] ?? "Failed to fetch bookings");
  }

  @override
  Future<dynamic> getBookingById(String bookingId) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.get(
      ApiEndpoints.getBookingByIdUrl(bookingId),
      options: Options(
        headers: {
          if (token != null) "Authorization": "Bearer $token",
        },
      ),
    );

    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception(response.data['message'] ?? "Failed to fetch booking details");
  }

  @override
  Future<dynamic> cancelBooking(String bookingId) async {
    final token = _tokenService.getToken();

    final response = await _apiClient.patch(
      ApiEndpoints.getCancelBookingUrl(bookingId),
      options: Options(
        headers: {
          if (token != null) "Authorization": "Bearer $token",
        },
      ),
    );

    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception(response.data['message'] ?? "Failed to cancel booking");
  }

  @override
  Future<dynamic> getDriverStats() async {
    final token = _tokenService.getToken();

    final response = await _apiClient.get(
      ApiEndpoints.driverStats,
      options: Options(
        headers: {
          if (token != null)
            "Authorization": "Bearer $token",
        },
      ),
    );

    if (response.data['success'] == true) {
      return response.data['data'];
    }

    throw Exception(
      response.data['message'] ??
          "Failed to fetch driver stats",
    );
  }

  @override
  Future<List<dynamic>> getDriverMyBookings() async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.driverMyBookings,
      options: Options(headers: {
        if (token != null) "Authorization": "Bearer $token",
      }),
    );
    if (response.data['success'] == true) {
      return response.data['data'] as List<dynamic>;
    }
    throw Exception(response.data['message'] ?? "Failed to fetch driver bookings");
  }

  @override
  Future<dynamic> driverAcceptBooking(String bookingId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.patch(
      ApiEndpoints.driverAcceptBooking(bookingId),
      options: Options(headers: {
        if (token != null) "Authorization": "Bearer $token",
      }),
    );
    if (response.data['success'] == true) return response.data['data'];
    throw Exception(response.data['message'] ?? "Failed to accept booking");
  }

  @override
  Future<dynamic> driverStartTrip(String bookingId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.patch(
      ApiEndpoints.driverStartTrip(bookingId),
      options: Options(headers: {
        if (token != null) "Authorization": "Bearer $token",
      }),
    );
    if (response.data['success'] == true) return response.data['data'];
    throw Exception(response.data['message'] ?? "Failed to start trip");
  }

  Future<void> driverGoodsPickedUp(String bookingId) async {
    final token = _tokenService.getToken();
    await _apiClient.post(
      ApiEndpoints.driverGoodsPickedUp(bookingId),
      options: Options(headers: {
        if (token != null) "Authorization": "Bearer $token",
      }),
    );
  }

  @override
  Future<void> driverArrivedAtPickup(String bookingId) async {
    final token = _tokenService.getToken();
    await _apiClient.post(
      ApiEndpoints.driverArrivedAtPickup(bookingId),
      options: Options(headers: {
        if (token != null) "Authorization": "Bearer $token",
      }),
    );
  }

  @override
  Future<dynamic> driverCompleteTrip(String bookingId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.patch(
      ApiEndpoints.driverCompleteTrip(bookingId),
      options: Options(headers: {
        if (token != null) "Authorization": "Bearer $token",
      }),
    );
    if (response.data['success'] == true) return response.data['data'];
    throw Exception(response.data['message'] ?? "Failed to complete trip");
  }

  @override
  Future<dynamic> driverCancelBooking(String bookingId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.patch(
      ApiEndpoints.driverCancelBooking(bookingId),
      options: Options(headers: {
        if (token != null) "Authorization": "Bearer $token",
      }),
    );
    if (response.data['success'] == true) return response.data['data'];
    throw Exception(response.data['message'] ?? "Failed to cancel booking");
  }

  @override
  Future<dynamic> uploadProofOfDelivery(
      String bookingId,
      String imagePath,
      ) async {
    final token = _tokenService.getToken();

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imagePath,
      ),
    });

    final response = await _apiClient.post(
      ApiEndpoints.uploadProofOfDelivery(
        bookingId,
      ),
      data: formData,
      options: Options(
        headers: {
          if (token != null)
            "Authorization": "Bearer $token",
        },
      ),
    );

    if (response.data['success'] == true) {
      return response.data['data'];
    }

    throw Exception(
      response.data['message'] ??
          "Failed to upload proof",
    );
  }

  @override
  Future<void> removeFromHistory(String bookingId) async {
    final token = _tokenService.getToken();

    await _apiClient.delete(
      ApiEndpoints.deleteBookingHistory(bookingId),
      options: Options(
        headers: {
          if (token != null) "Authorization": "Bearer $token",
        },
      ),
    );
  }
}