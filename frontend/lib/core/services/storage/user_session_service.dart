import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Shared Prefs Provider (To be overridden in main.dart during app initialization)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// User Session Service Provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService(prefs: ref.read(sharedPreferencesProvider));
});

class UserSessionService {
  final SharedPreferences _prefs;

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Keys for storing data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhoneNumber = 'user_phone_number';
  static const String _keyUserRole = 'user_role';
  static const String _keyAccountStatus = 'account_status';
  static const String _keyUserImageUrl = 'user_image_url';

  // Driver logistics specific keys
  static const String _keyVehicleModel = 'vehicle_model';
  static const String _keyVehicleColor = 'vehicle_color';
  static const String _keyNumberPlate = 'number_plate';
  static const String _keyLicenseNumber = 'license_number';
  static const String _keyIsAvailable = 'is_available';

  // Store user/driver session data dynamically
  Future<void> saveUserSession({
    required String userId,
    required String username,
    required String email,
    required String phoneNumber,
    required String role,
    required String accountStatus,
    String? imageUrl,
    String? vehicleModel,
    String? vehicleColor,
    String? numberPlate,
    String? licenseNumber,
    bool? isAvailable,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserName, username);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserPhoneNumber, phoneNumber);
    await _prefs.setString(_keyUserRole, role);
    await _prefs.setString(_keyAccountStatus, accountStatus);

    // Optional user avatar
    if (imageUrl != null) {
      await _prefs.setString(_keyUserImageUrl, imageUrl);
    } else {
      await _prefs.remove(_keyUserImageUrl);
    }

    // Driver specific specs serialization
    if (vehicleModel != null) await _prefs.setString(_keyVehicleModel, vehicleModel);
    if (vehicleColor != null) await _prefs.setString(_keyVehicleColor, vehicleColor);
    if (numberPlate != null) await _prefs.setString(_keyNumberPlate, numberPlate);
    if (licenseNumber != null) await _prefs.setString(_keyLicenseNumber, licenseNumber);
    if (isAvailable != null) await _prefs.setBool(_keyIsAvailable, isAvailable);
  }

  // Clear User Sessions Data completely on sign out
  Future<void> clearUserSession() async {
    final Set<String> keys = {
      _keyIsLoggedIn,
      _keyUserId,
      _keyUserName,
      _keyUserEmail,
      _keyUserPhoneNumber,
      _keyUserRole,
      _keyAccountStatus,
      _keyUserImageUrl,
      _keyVehicleModel,
      _keyVehicleColor,
      _keyNumberPlate,
      _keyLicenseNumber,
      _keyIsAvailable,
    };

    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  // Check if user has an active session configuration
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Getters
  String? getCurrentUserId() => _prefs.getString(_keyUserId);
  String? getCurrentUserName() => _prefs.getString(_keyUserName);
  String? getCurrentUserEmail() => _prefs.getString(_keyUserEmail);
  String? getCurrentUserPhoneNumber() => _prefs.getString(_keyUserPhoneNumber);
  String? getCurrentUserRole() => _prefs.getString(_keyUserRole);
  String? getAccountStatus() => _prefs.getString(_keyAccountStatus);
  String? getCurrentUserImageUrl() => _prefs.getString(_keyUserImageUrl);

  // Driver specifics getters
  String? getVehicleModel() => _prefs.getString(_keyVehicleModel);
  String? getVehicleColor() => _prefs.getString(_keyVehicleColor);
  String? getNumberPlate() => _prefs.getString(_keyNumberPlate);
  String? getLicenseNumber() => _prefs.getString(_keyLicenseNumber);
  bool? getIsAvailable() => _prefs.getBool(_keyIsAvailable);
}