import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/auth_entity.dart';

part 'auth_api_model.g.dart';

@JsonSerializable()
class AuthApiModel {
  @JsonKey(name: '_id')
  final String? id;
  final String username;
  final String email;
  final String phone;
  final String? password;
  final String role;
  final String accountStatus;
  final String? imageUrl;

  // Driver specific logistics fields
  final String? vehicleModel;
  final String? vehicleColor;
  final String? numberPlate;
  final String? licenseNumber;
  final bool? isAvailable;
  @JsonKey(
    fromJson: _locationFromJson,
    toJson: _locationToJson,
  )
  final List<double>? location; // [longitude, latitude]
  final String? vehicleType;
  final int? tripCount;


  static List<double>? _locationFromJson(dynamic json) {
    if (json == null) return null;

    if (json is Map<String, dynamic>) {
      final coordinates = json['coordinates'];

      if (coordinates is List) {
        return coordinates
            .map((e) => (e as num).toDouble())
            .toList();
      }
    }

    return null;
  }

  static dynamic _locationToJson(List<double>? location) {
    if (location == null) return null;

    return {
      'type': 'Point',
      'coordinates': location,
    };
  }

  AuthApiModel({
    this.id,
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

  // Codegen JSON Serialization methods
  factory AuthApiModel.fromJson(Map<String, dynamic> json) =>
      _$AuthApiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthApiModelToJson(this);

  // Convert API Data Model to Domain Layer Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
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

  // Convert Domain Layer Entity to API Data Model
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
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

  // List parsing utility helper
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}