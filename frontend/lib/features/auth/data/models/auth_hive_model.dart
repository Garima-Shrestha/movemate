import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/hive_table_contant.dart';
import '../../domain/entities/auth_entity.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String phone;
  @HiveField(4)
  final String? password;
  @HiveField(5)
  final String role;
  @HiveField(6)
  final String accountStatus;
  @HiveField(7)
  final String? imageUrl;

  // Driver only fields
  @HiveField(8)
  final String? vehicleModel;
  @HiveField(9)
  final String? vehicleColor;
  @HiveField(10)
  final String? numberPlate;
  @HiveField(11)
  final String? licenseNumber;
  @HiveField(12)
  final bool? isAvailable;
  @HiveField(13)
  final List<double>? location;
  @HiveField(14)
  final String? vehicleType;
  @HiveField(15)
  final int? tripCount;


  // Constructor
  AuthHiveModel({
    String? authId,
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
  }) : authId = authId ?? const Uuid().v4();

  // From Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      username: entity.username,
      email: entity.email,
      phone: entity.phone,
      password: entity.password,
      role: entity.role,
      accountStatus: entity.accountStatus,
      imageUrl: entity.imageUrl,
      vehicleModel: entity.vehicleModel,
      vehicleColor: entity.vehicleColor,
      numberPlate: entity.numberPlate,
      licenseNumber: entity.licenseNumber,
      isAvailable: entity.isAvailable,
      location: entity.location,
      vehicleType: entity.vehicleType,
      tripCount: entity.tripCount,
    );
  }

  // To Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      username: username,
      email: email,
      phone: phone,
      password: password,
      role: role,
      accountStatus: accountStatus,
      imageUrl: imageUrl,
      vehicleModel: vehicleModel,
      vehicleColor: vehicleColor,
      numberPlate: numberPlate,
      licenseNumber: licenseNumber,
      isAvailable: isAvailable,
      location: location,
      vehicleType: vehicleType,
      tripCount: tripCount,
    );
  }

  // To Entity List
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}