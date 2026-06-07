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

  const AuthEntity({
    this.authId,
    required this.username,
    required this.email,
    required this.phone,
    this.password,
    this.role = 'user',
    this.accountStatus = 'active',
    this.imageUrl,
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
  ];
}