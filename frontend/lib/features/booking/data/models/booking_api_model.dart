import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../auth/data/models/auth_api_model.dart';
import '../../../auth/domain/entities/auth_entity.dart';
import '../../domain/entities/booking_entity.dart';

part 'booking_api_model.g.dart';

@JsonSerializable()
class BookingApiModel {
  @JsonKey(name: '_id')
  final String? id;

  // Storing as dynamic because Mongoose can return an ID or an Object
  final dynamic userId;
  final dynamic driverId;

  final String vehicleType;
  final List<String> goodsTypes;
  final String status;
  final int? price;
  final double? distance;
  final String? cancelledBy;

  final Map<String, dynamic>? pickupLocation;
  final Map<String, dynamic>? dropLocation;
  final String? pickupAddress;
  final String? dropAddress;

  final String? proofOfDeliveryImage;
  final DateTime? proofUploadedAt;

  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? acceptedAt;
  final int? estimatedArrival;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingApiModel({
    this.id,
    this.userId,
    this.driverId,
    required this.vehicleType,
    required this.goodsTypes,
    this.status = 'pending',
    this.price,
    this.distance,
    this.cancelledBy,
    this.pickupLocation,
    this.dropLocation,
    this.pickupAddress,
    this.dropAddress,
    this.proofOfDeliveryImage,
    this.proofUploadedAt,
    this.startedAt,
    this.completedAt,
    this.acceptedAt,
    this.estimatedArrival,
    this.createdAt,
    this.updatedAt,
  });

  // Codegen JSON Serialization methods
  factory BookingApiModel.fromJson(Map<String, dynamic> json) =>
      _$BookingApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingApiModelToJson(this);

  // Convert API Data Model to Domain Layer Entity
  BookingEntity toEntity() {
    return BookingEntity(
      bookingId: id,

      // Helper to handle Mongoose populated objects
      user: userId is Map<String, dynamic>
          ? AuthEntity(
        authId: userId['_id'] as String?,
        username: userId['username'] as String? ?? '',
        email: userId['email'] as String? ?? '',
        phone: userId['phone'] as String? ?? '',
        role: userId['role'] as String? ?? 'user',
        accountStatus: userId['accountStatus'] as String? ?? 'active',
      )
          : null,

      driver: driverId is Map<String, dynamic>
          ? AuthEntity(
        authId: driverId['_id'] as String?,
        username: driverId['username'] as String? ?? '',
        email: driverId['email'] as String? ?? '',
        phone: driverId['phone'] as String? ?? '',
        role: driverId['role'] as String? ?? 'driver',
        accountStatus: driverId['accountStatus'] as String? ?? 'active',
        vehicleModel: driverId['vehicleModel'] as String?,
        vehicleColor: driverId['vehicleColor'] as String?,
        numberPlate: driverId['numberPlate'] as String?,
        vehicleType: driverId['vehicleType'] as String?,
        tripCount: driverId['tripCount'] as int?,
      )
          : null,

      // user: null, // Note: You would map the 'userId' object here if populated
      // driver: null, // Note: You would map the 'driverId' object here if populated
      vehicleType: vehicleType,
      goodsTypes: goodsTypes,
      status: status,
      price: price,
      distance: distance,
      cancelledBy: cancelledBy,
      pickupCoordinates: (pickupLocation?['coordinates'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ?? [],
      dropCoordinates: (dropLocation?['coordinates'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ?? [],
      pickupAddress: pickupAddress ?? '',
      dropAddress: dropAddress ?? '',
      proofOfDeliveryImage: proofOfDeliveryImage,
      proofUploadedAt: proofUploadedAt,
      startedAt: startedAt,
      completedAt: completedAt,
      acceptedAt: acceptedAt,
      estimatedArrival: estimatedArrival,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Convert Domain Layer Entity to API Data Model
  factory BookingApiModel.fromEntity(BookingEntity entity) {
    return BookingApiModel(
      id: entity.bookingId,
      vehicleType: entity.vehicleType,
      goodsTypes: entity.goodsTypes,
      status: entity.status,
      price: entity.price,
      distance: entity.distance?.toDouble(),
      cancelledBy: entity.cancelledBy,
      pickupLocation: {'type': 'Point', 'coordinates': entity.pickupCoordinates},
      dropLocation: {'type': 'Point', 'coordinates': entity.dropCoordinates},
      pickupAddress: entity.pickupAddress,
      dropAddress: entity.dropAddress,
      proofOfDeliveryImage: entity.proofOfDeliveryImage,
      proofUploadedAt: entity.proofUploadedAt,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      acceptedAt: entity.acceptedAt,
      estimatedArrival: entity.estimatedArrival,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // List parsing utility helper
  static List<BookingEntity> toEntityList(List<BookingApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}