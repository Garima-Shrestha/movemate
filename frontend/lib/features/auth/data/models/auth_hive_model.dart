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
    );
  }

  // To Entity List
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}