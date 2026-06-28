import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/hive_table_contant.dart';
import '../../../auth/data/models/auth_hive_model.dart';
import '../../domain/entities/booking_entity.dart';

part 'booking_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.cachedBookingTypeId)
class BookingHiveModel extends HiveObject {
  @HiveField(0)
  final String? bookingId;

  @HiveField(1)
  final AuthHiveModel? user;

  @HiveField(2)
  final AuthHiveModel? driver;

  @HiveField(3)
  final String vehicleType;

  @HiveField(4)
  final List<double> pickupCoordinates;

  @HiveField(5)
  final List<double> dropCoordinates;

  @HiveField(6)
  final double? distance;

  @HiveField(7)
  final int? price;

  @HiveField(8)
  final String status;

  @HiveField(9)
  final List<String> goodsTypes;

  @HiveField(10)
  final String? cancelledBy;

  @HiveField(11)
  final DateTime? startedAt;

  @HiveField(12)
  final DateTime? completedAt;

  @HiveField(13)
  final DateTime? acceptedAt;

  @HiveField(14)
  final int? estimatedArrival;

  @HiveField(15)
  final DateTime? createdAt;

  @HiveField(16)
  final DateTime? updatedAt;

  @HiveField(17)
  final String pickupAddress;

  @HiveField(18)
  final String dropAddress;

  @HiveField(19)
  final String? proofOfDeliveryImage;

  @HiveField(20)
  final DateTime? proofUploadedAt;

  BookingHiveModel({
    String? bookingId,
    this.user,
    this.driver,
    required this.vehicleType,
    required this.pickupCoordinates,
    required this.dropCoordinates,
    this.distance,
    this.price,
    this.status = 'pending',
    required this.goodsTypes,
    required this.pickupAddress,
    required this.dropAddress,
    this.proofOfDeliveryImage,
    this.proofUploadedAt,
    this.cancelledBy,
    this.startedAt,
    this.completedAt,
    this.acceptedAt,
    this.estimatedArrival,
    this.createdAt,
    this.updatedAt,
  }) : bookingId = bookingId ?? const Uuid().v4();

  // From Entity
  factory BookingHiveModel.fromEntity(BookingEntity entity) {
    return BookingHiveModel(
      bookingId: entity.bookingId,
      user: entity.user != null ? AuthHiveModel.fromEntity(entity.user!) : null,
      driver: entity.driver != null ? AuthHiveModel.fromEntity(entity.driver!) : null,
      vehicleType: entity.vehicleType,
      pickupCoordinates: entity.pickupCoordinates,
      dropCoordinates: entity.dropCoordinates,
      distance: entity.distance,
      price: entity.price,
      status: entity.status,
      goodsTypes: entity.goodsTypes,
      pickupAddress: entity.pickupAddress,
      dropAddress: entity.dropAddress,
      proofOfDeliveryImage: entity.proofOfDeliveryImage,
      proofUploadedAt: entity.proofUploadedAt,
      cancelledBy: entity.cancelledBy,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      acceptedAt: entity.acceptedAt,
      estimatedArrival: entity.estimatedArrival,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // To Entity
  BookingEntity toEntity() {
    return BookingEntity(
      bookingId: bookingId,
      user: user?.toEntity(),
      driver: driver?.toEntity(),
      vehicleType: vehicleType,
      pickupCoordinates: pickupCoordinates,
      dropCoordinates: dropCoordinates,
      distance: distance,
      price: price,
      status: status,
      goodsTypes: goodsTypes,
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
      proofOfDeliveryImage: proofOfDeliveryImage,
      proofUploadedAt: proofUploadedAt,
      cancelledBy: cancelledBy,
      startedAt: startedAt,
      completedAt: completedAt,
      acceptedAt: acceptedAt,
      estimatedArrival: estimatedArrival,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // To Entity List
  static List<BookingEntity> toEntityList(List<BookingHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}