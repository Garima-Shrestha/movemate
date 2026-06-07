import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Configuration toggles for local environment execution
  static const bool isPhysicalDevice = true;
  static const String _ipAddress = '192.168.48.1';
  static const int _backendPort = 5050;

  // Base Dynamic URL Routing
  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_backendPort';
  static String get baseUrl => serverUrl;
  static String get mediaServerUrl => serverUrl;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ------------------- AUTH MODULE ROUTING -------------------
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String changePassword = '/api/auth/change-password';

  // ------------------- DRIVER MODULE ROUTING -------------------
  static const String getDriverProfile = '/api/driver/profile';
  static const String updateDriverProfile = '/api/driver/update-profile';
  static const String updateDriverLocation = '/api/driver/location';
  static const String updateDriverAvailability = '/api/driver/availability';
  static const String uploadDriverLicense = '/api/driver/upload-license';
  static const String getNearbyDrivers = '/api/driver/nearby';

  // ------------------- USER BOOKING MODULE ROUTING -------------------
  static const String baseBookings = '/api/bookings';

  static const String estimateBookingPrice = '$baseBookings/estimate';

  // Functions to insert the booking ID dynamically into the URL string
  static String getBookingByIdUrl(String id) => '$baseBookings/$id';
  static String getCancelBookingUrl(String id) => '$baseBookings/$id/cancel';


  // ------------------- DRIVER BOOKING WORKFLOWS -------------------
  static const String driverBookings = '/api/driver/bookings';
  static const String driverPendingBookings = '$driverBookings/pending';
  static const String driverMyBookings = '$driverBookings/my-bookings';

  static const String driverStats = '/api/driver/stats';

  // Functions to insert the booking ID dynamically into the driver action paths
  static String driverAcceptBookingUrl(String id) => '$driverBookings/$id/accept';
  static String driverStartTripUrl(String id) => '$driverBookings/$id/start';
  static String driverCompleteTripUrl(String id) => '$driverBookings/$id/complete';
  static String driverCancelBookingUrl(String id) => '$driverBookings/$id/cancel';
}