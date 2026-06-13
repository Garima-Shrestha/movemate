// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingApiModel _$BookingApiModelFromJson(Map<String, dynamic> json) =>
    BookingApiModel(
      id: json['_id'] as String?,
      userId: json['userId'],
      driverId: json['driverId'],
      vehicleType: json['vehicleType'] as String,
      goodsTypes: (json['goodsTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: json['status'] as String? ?? 'pending',
      price: (json['price'] as num?)?.toInt(),
      distance: (json['distance'] as num?)?.toDouble(),
      cancelledBy: json['cancelledBy'] as String?,
      pickupLocation: json['pickupLocation'] as Map<String, dynamic>?,
      dropLocation: json['dropLocation'] as Map<String, dynamic>?,
      pickupAddress: json['pickupAddress'] as String?,
      dropAddress: json['dropAddress'] as String?,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      estimatedArrival: (json['estimatedArrival'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BookingApiModelToJson(BookingApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'driverId': instance.driverId,
      'vehicleType': instance.vehicleType,
      'goodsTypes': instance.goodsTypes,
      'status': instance.status,
      'price': instance.price,
      'distance': instance.distance,
      'cancelledBy': instance.cancelledBy,
      'pickupLocation': instance.pickupLocation,
      'dropLocation': instance.dropLocation,
      'pickupAddress': instance.pickupAddress,
      'dropAddress': instance.dropAddress,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'estimatedArrival': instance.estimatedArrival,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
