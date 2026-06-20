// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthApiModel _$AuthApiModelFromJson(Map<String, dynamic> json) => AuthApiModel(
      id: json['_id'] as String?,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String?,
      role: json['role'] as String? ?? 'user',
      accountStatus: json['accountStatus'] as String? ?? 'active',
      imageUrl: json['imageUrl'] as String?,
      vehicleModel: json['vehicleModel'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      numberPlate: json['numberPlate'] as String?,
      licenseNumber: json['licenseNumber'] as String?,
      isAvailable: json['isAvailable'] as bool?,
      location: AuthApiModel._locationFromJson(json['location']),
      vehicleType: json['vehicleType'] as String?,
      tripCount: (json['tripCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AuthApiModelToJson(AuthApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'phone': instance.phone,
      'password': instance.password,
      'role': instance.role,
      'accountStatus': instance.accountStatus,
      'imageUrl': instance.imageUrl,
      'vehicleModel': instance.vehicleModel,
      'vehicleColor': instance.vehicleColor,
      'numberPlate': instance.numberPlate,
      'licenseNumber': instance.licenseNumber,
      'isAvailable': instance.isAvailable,
      'location': AuthApiModel._locationToJson(instance.location),
      'vehicleType': instance.vehicleType,
      'tripCount': instance.tripCount,
    };
