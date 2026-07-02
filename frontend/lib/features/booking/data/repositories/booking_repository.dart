import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/connectivity/network_info.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_datasource.dart';
import '../datasources/local/booking_local_datasource.dart';
import '../datasources/remote/booking_remote_datasource.dart';
import '../models/booking_api_model.dart';
import '../models/booking_hive_model.dart';

final bookingRepositoryProvider = Provider<IBookingRepository>((ref) {
  final bookingLocalDataSource = ref.read(bookingLocalDataSourceProvider);
  final bookingRemoteDataSource = ref.read(bookingRemoteDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return BookingRepository(
    bookingLocalDataSource: bookingLocalDataSource,
    bookingRemoteDataSource: bookingRemoteDataSource,
    networkInfo: networkInfo,
  );
});

class BookingRepository implements IBookingRepository {
  final IBookingLocalDataSource _bookingLocalDataSource;
  final IBookingRemoteDataSource _bookingRemoteDataSource;
  final NetworkInfo _networkInfo;

  BookingRepository({
    required IBookingLocalDataSource bookingLocalDataSource,
    required IBookingRemoteDataSource bookingRemoteDataSource,
    required NetworkInfo networkInfo,
  })  : _bookingLocalDataSource = bookingLocalDataSource,
        _bookingRemoteDataSource = bookingRemoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, BookingEntity>> createBooking(BookingEntity booking) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = BookingApiModel.fromEntity(booking);
        final payload = {
          'vehicleType': apiModel.vehicleType,
          'goodsTypes': apiModel.goodsTypes,
          'pickupLocation': apiModel.pickupLocation,
          'dropLocation': apiModel.dropLocation,
          'pickupAddress': apiModel.pickupAddress,
          'dropAddress': apiModel.dropAddress,
        };
        final responseMap = await _bookingRemoteDataSource.createBooking(payload);
        final createdEntity = BookingApiModel.fromJson(responseMap).toEntity();

        await _bookingLocalDataSource.cacheCurrentBooking(
          BookingHiveModel.fromEntity(createdEntity),
        );

        return Right(createdEntity);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to create booking',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        ApiFailure(message: "An active internet connection is required to request vehicle matching"),
      );
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getMyBookings() async {
    if (await _networkInfo.isConnected) {
      try {
        final rawJsonList = await _bookingRemoteDataSource.getMyBookings();

        // Loop through the list of maps and parse them into clean UI Entities
        final List<BookingEntity> historyList = rawJsonList
            .map((json) {
          try {
            return BookingApiModel.fromJson(json as Map<String, dynamic>).toEntity();
          } catch (e) {
            return null;
          }
        })
            .whereType<BookingEntity>()
            .toList();

        return Right(historyList);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch booking history',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline fallback: Return the active running trip inside an array if they are disconnected
      try {
        final cachedTrip = await _bookingLocalDataSource.getCachedBooking();
        if (cachedTrip != null) {
          return Right([cachedTrip.toEntity()]);
        }
        return const Left(
          LocalDatabaseFailure(message: "No internet connection and no cached ongoing trips found"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> getBookingById(String bookingId) async {
    if (await _networkInfo.isConnected) {
      try {
        final responseMap = await _bookingRemoteDataSource.getBookingById(bookingId);
        final bookingEntity = BookingApiModel.fromJson(responseMap).toEntity();

        // Overwrite the local cache with the newest state (e.g. tracking updates or status switches)
        await _bookingLocalDataSource.cacheCurrentBooking(
          BookingHiveModel.fromEntity(bookingEntity),
        );

        return Right(bookingEntity);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch live booking details',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Offline tracking lookup: Pull the last known state directly from our local Hive database
      try {
        final cachedTrip = await _bookingLocalDataSource.getCachedBooking();
        if (cachedTrip != null && cachedTrip.bookingId == bookingId) {
          return Right(cachedTrip.toEntity());
        }
        return const Left(LocalDatabaseFailure(message: "Connection offline. Requested trip data unavailable"));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> cancelBooking(String bookingId) async {
    if (await _networkInfo.isConnected) {
      try {
        final responseMap = await _bookingRemoteDataSource.cancelBooking(bookingId);
        final updatedEntity = BookingApiModel.fromJson(responseMap).toEntity();

        // The booking is officially broken or completed; wipe out our active screen cache safely
        await _bookingLocalDataSource.clearCachedBooking();

        return Right(updatedEntity);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to process trip cancellation',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(
        ApiFailure(message: "Cancellation requests can only be registered while your device is online"),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> estimatePrice(
      Map<String, dynamic> payload,
      ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result =
        await _bookingRemoteDataSource.estimatePrice(
          payload,
        );

        return Right(
          Map<String, dynamic>.from(result),
        );
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ??
                'Failed to estimate booking price',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(
          ApiFailure(
            message: e.toString(),
          ),
        );
      }
    } else {
      return const Left(
        ApiFailure(
          message:
          "Internet connection required for price estimation",
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeFromHistory(
      String bookingId,
      ) async {
    if (await _networkInfo.isConnected) {
      try {
        await _bookingRemoteDataSource.removeFromHistory(
          bookingId,
        );

        return const Right(null);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
            e.response?.data['message'] ??
                'Failed to remove booking',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(
          ApiFailure(message: e.toString()),
        );
      }
    } else {
      return const Left(
        ApiFailure(
          message: "Internet connection required",
        ),
      );
    }
  }

  //Driver
  @override
  Future<Either<Failure, Map<String, dynamic>>> getDriverStats() async {
    if (await _networkInfo.isConnected) {
      try {
        final result =
        await _bookingRemoteDataSource.getDriverStats();

        return Right(
          Map<String, dynamic>.from(result),
        );
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ??
                'Failed to fetch driver stats',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(
          ApiFailure(message: e.toString()),
        );
      }
    } else {
      return const Left(
        ApiFailure(
          message: "Internet connection required",
        ),
      );
    }
  }
}