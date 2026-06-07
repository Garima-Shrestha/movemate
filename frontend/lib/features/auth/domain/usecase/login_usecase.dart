import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/app_usecase.dart';
import '../../data/repositories/auth_repository.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(authRepository: ref.read(authRepositoryProvider));
});

class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;

  const LoginUsecaseParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginUsecase implements UsecaseWithParams<AuthEntity, LoginUsecaseParams> {
  final IAuthRepository _authRepository;

  LoginUsecase({required IAuthRepository authRepository}) : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginUsecaseParams params) {
    return _authRepository.login(params.email, params.password);
  }
}