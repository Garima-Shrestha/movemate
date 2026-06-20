import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/app_usecase.dart';
import '../../data/repositories/auth_repository.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  return RegisterUsecase(authRepository: ref.read(authRepositoryProvider));
});

class RegisterUsecaseParams extends Equatable {
  final String username;
  final String email;
  final String phone;
  final String password;
  final String role; // 'user' or 'driver'

  final String? vehicleModel;
  final String? vehicleColor;
  final String? numberPlate;
  final String? licenseNumber;
  final String? vehicleType;

  const RegisterUsecaseParams({
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,

    this.vehicleModel,
    this.vehicleColor,
    this.numberPlate,
    this.licenseNumber,
    this.vehicleType,
  });

  @override
  List<Object?> get props => [username, email, phone, password, role, vehicleModel, vehicleColor, numberPlate, licenseNumber, vehicleType,];
}

class RegisterUsecase implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository}) : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
      username: params.username,
      email: params.email,
      phone: params.phone,
      password: params.password,
      role: params.role,
      accountStatus: 'active', // Default setup status

      vehicleType: params.vehicleType,
      vehicleModel: params.vehicleModel,
      vehicleColor: params.vehicleColor,
      numberPlate: params.numberPlate,
      licenseNumber: params.licenseNumber,
    );
    return _authRepository.register(entity);
  }
}