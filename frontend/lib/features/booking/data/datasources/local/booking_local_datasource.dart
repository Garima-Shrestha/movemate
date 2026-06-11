import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/hive/hive_services.dart';
import '../../models/booking_hive_model.dart';
import '../booking_datasource.dart';


final bookingLocalDataSourceProvider = Provider<BookingLocalDataSource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return BookingLocalDataSource(hiveService: hiveService);
});

class BookingLocalDataSource implements IBookingLocalDataSource {
  final HiveService _hiveService;

  BookingLocalDataSource({
    required HiveService hiveService,
  }) : _hiveService = hiveService;

  @override
  Future<void> cacheCurrentBooking(BookingHiveModel model) async {
    try {
      await _hiveService.cacheCurrentBooking(model);
    } catch (e) {
      // Fail silently or log error depending on your logging style
      rethrow;
    }
  }

  @override
  Future<BookingHiveModel?> getCachedBooking() async {
    try {
      return _hiveService.getCachedBooking();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCachedBooking() async {
    try {
      await _hiveService.clearCachedBooking();
    } catch (e) {
      rethrow;
    }
  }
}