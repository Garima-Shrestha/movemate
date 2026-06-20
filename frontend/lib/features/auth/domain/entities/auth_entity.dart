import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String username;
  final String email;
  final String phone;
  final String? password;
  final String role;
  final String accountStatus;
  final String? imageUrl;

  // Driver only fields
  final String? vehicleModel;
  final String? vehicleColor;
  final String? numberPlate;
  final String? licenseNumber;
  final bool? isAvailable;
  final List<double>? location; // [longitude, latitude]
  final String? vehicleType;
  final int? tripCount;

  const AuthEntity({
    this.authId,
    required this.username,
    required this.email,
    required this.phone,
    this.password,
    this.role = 'user',
    this.accountStatus = 'active',
    this.imageUrl,
    this.vehicleModel,
    this.vehicleColor,
    this.numberPlate,
    this.licenseNumber,
    this.isAvailable,
    this.location,
    this.vehicleType,
    this.tripCount,
  });

  @override
  List<Object?> get props => [
    authId,
    username,
    email,
    phone,
    password,
    role,
    accountStatus,
    imageUrl,
    vehicleModel,
    vehicleColor,
    numberPlate,
    licenseNumber,
    isAvailable,
    location,
    vehicleType,
    tripCount,
  ];
}