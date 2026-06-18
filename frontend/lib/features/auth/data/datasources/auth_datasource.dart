import 'dart:io';
import '../models/auth_hive_model.dart';

abstract interface class IAuthLocalDataSource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<bool> isEmailExists(String email);
  Future<bool> updateProfile(AuthHiveModel model);
}

abstract interface class IAuthRemoteDataSource {
  Future<dynamic> register(dynamic user);
  Future<dynamic> login(String email, String password);
  Future<dynamic> getUserById(String authId);

  Future<bool> updateProfile({
    required dynamic user,
    File? profileImage,
  });

  Future<bool> changePassword(String oldPassword, String newPassword);

  //Driver
  Future<bool> updateAvailability(bool isAvailable);
  Future<bool> updateDriverLocation({
    required double latitude,
    required double longitude,
  });
}