import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/data/models/auth_hive_model.dart';
import '../../../features/booking/data/models/booking_hive_model.dart';
import '../../constants/hive_table_contant.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  // Initialization
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
    await openBoxes();
  }

  // Register Adapter
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

    // Booking Adapter Register
    if (!Hive.isAdapterRegistered(HiveTableConstant.cachedBookingTypeId)) {
      Hive.registerAdapter(BookingHiveModelAdapter());
    }
  }

  // Open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    await Hive.openBox<BookingHiveModel>(HiveTableConstant.cachedBookingTable);
  }

  // Close Boxes
  Future<void> close() async {
    await Hive.close();
  }

  // ------------------- Auth Queries -------------------
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  // Register User / Driver
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  // Login
  Future<AuthHiveModel?> login(String email, String password) async {
    final users = _authBox.values.where(
          (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  // Logout
  Future<void> logoutUser() async {}

  // Get Current User / Driver profile details
  AuthHiveModel? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  // Verify if account identifier exists locally
  bool isEmailExists(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }

  // Update User Profile / Vehicle / Availability Data
  Future<void> updateUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
  }



  // ------------------- Booking Cache Queries -------------------
  // A clean getter to access the local booking storage anytime
  Box<BookingHiveModel> get _bookingBox =>
      Hive.box<BookingHiveModel>(HiveTableConstant.cachedBookingTable);

  // Cache an active trip state locally
  Future<void> cacheCurrentBooking(BookingHiveModel model) async {
    await _bookingBox.put('current_active_trip', model);
  }

  // Retrieve the saved active trip if the app restarts
  BookingHiveModel? getCachedBooking() {
    return _bookingBox.get('current_active_trip');
  }

  // Clear the cache once the trip is completed or cancelled
  Future<void> clearCachedBooking() async {
    await _bookingBox.delete('current_active_trip');
  }
}