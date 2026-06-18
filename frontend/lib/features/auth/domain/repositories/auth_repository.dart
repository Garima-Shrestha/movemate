import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, bool>> updateProfile({
    required AuthEntity entity,
    File? profileImage,
  });

  Future<Either<Failure, bool>> changePassword(String oldPassword, String newPassword);

  // Driver
  Future<Either<Failure, bool>> updateAvailability(bool isAvailable);
  Future<Either<Failure,bool>> updateDriverLocation({
    required double latitude,
    required double longitude,
  });
}