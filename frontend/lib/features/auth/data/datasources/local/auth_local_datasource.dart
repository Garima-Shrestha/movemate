import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/hive/hive_services.dart';
import '../../../../../core/services/storage/user_session_service.dart';
import '../../models/auth_hive_model.dart';
import '../auth_datasource.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDataSource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDataSource implements IAuthLocalDataSource {
  final HiveService _hiveService;
  final dynamic _userSessionService; // Replace dynamic with your explicit UserSessionService type

  AuthLocalDataSource({
    required HiveService hiveService,
    required dynamic userSessionService,
  })  : _hiveService = hiveService,
        _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      final userId = await _userSessionService.getCurrentUserId();
      if (userId == null) return null;

      return _hiveService.getCurrentUser(userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isEmailExists(String email) async {
    try {
      final exists = _hiveService.isEmailExists(email);
      return exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.login(email, password);

      // Save valid session data locally to disk
      if (user != null && user.authId != null) {
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          username: user.username,
          email: user.email,
          phoneNumber: user.phone,
          imageUrl: user.imageUrl,
        );
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _userSessionService.clearUserSession();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> register(AuthHiveModel model) async {
    try {
      await _hiveService.registerUser(model);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateProfile(AuthHiveModel model) async {
    try {
      await _hiveService.updateUser(model);

      if (model.authId != null) {
        await _userSessionService.saveUserSession(
          userId: model.authId!,
          username: model.username,
          email: model.email,
          phoneNumber: model.phone,
          imageUrl: model.imageUrl,
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}