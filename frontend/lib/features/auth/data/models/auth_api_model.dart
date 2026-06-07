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


  AuthApiModel({
    this.id,
    required this.username,
    required this.email,
    required this.phone,
    this.password,
    this.role = 'user',
    this.accountStatus = 'active',
    this.imageUrl,
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
    );
  }

  // List parsing utility helper
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}