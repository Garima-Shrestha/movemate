import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/connectivity/network_info.dart';
import '../datasources/auth_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth_api_model.dart';
import '../models/auth_hive_model.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';


// Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authLocalDataSource = ref.read(authLocalDataSourceProvider);
  final authRemoteDataSource = ref.read(authRemoteDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authLocalDataSource: authLocalDataSource,
    authRemoteDataSource: authRemoteDataSource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDataSource _authLocalDataSource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDataSource authLocalDataSource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
  })  : _authLocalDataSource = authLocalDataSource,
        _authRemoteDataSource = authRemoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(entity);
        await _authRemoteDataSource.register(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Registration failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final existingUser = await _authLocalDataSource.isEmailExists(entity.email);
        if (existingUser) {
          return const Left(
            LocalDatabaseFailure(message: "Email already registered locally"),
          );
        }

        final model = AuthHiveModel.fromEntity(entity);
        await _authLocalDataSource.register(model);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    if (await _networkInfo.isConnected) {
      try {
        final responseData = await _authRemoteDataSource.login(email, password);
        if (responseData != null) {
          final entity = responseData.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: "Invalid credentials"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _authLocalDataSource.login(email, password);
        if (model != null) {
          return Right(model.toEntity());
        }
        return const Left(LocalDatabaseFailure(message: 'Failed to find valid offline matching user session'));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authLocalDataSource.getCurrentUser();
      if (user != null) {
        return Right(user.toEntity());
      }
      return const Left(LocalDatabaseFailure(message: 'No user session cached locally'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authLocalDataSource.logout();
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: 'Failed to clear local user session'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}