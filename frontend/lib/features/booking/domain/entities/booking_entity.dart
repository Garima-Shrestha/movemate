import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/auth_entity.dart';

class BookingEntity extends Equatable {
  final String? bookingId;
  final AuthEntity? user;
  final AuthEntity? driver;
  final String vehicleType;
  final List<double> pickupCoordinates;
  final List<double> dropCoordinates;
  final double? distance;
  final int? price;
  final String status;
  final List<String> goodsTypes;
  final String? cancelledBy;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? acceptedAt;
  final int? estimatedArrival;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String pickupAddress;
  final String dropAddress;
  final String? proofOfDeliveryImage;
  final DateTime? proofUploadedAt;


  const BookingEntity({
    this.bookingId,
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
  });

  @override
  List<Object?> get props => [
    bookingId,
    user,
    driver,
    vehicleType,
    pickupCoordinates,
    dropCoordinates,
    distance,
    price,
    status,
    goodsTypes,
    pickupAddress,
    dropAddress,
    proofOfDeliveryImage,
    proofUploadedAt,
    cancelledBy,
    startedAt,
    completedAt,
    acceptedAt,
    estimatedArrival,
    createdAt,
    updatedAt,
  ];
}