class HiveTableConstant {
  HiveTableConstant._();

  // Database name
  static const String dbName= 'movemate_db';

  // Table name
  // User
  static const int authTypeId = 0;
  static const String authTable = 'user_table';

  // Recent Search Locations (Galli Maps History)
  static const int recentPlaceTypeId = 1;
  static const String recentPlaceTable = 'recent_place_table';

  // Cached Bookings (To remember active user trips)
  static const int cachedBookingTypeId = 2;
  static const String cachedBookingTable = 'cached_booking_table';
}