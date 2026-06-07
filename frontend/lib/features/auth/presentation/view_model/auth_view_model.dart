import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';import '../../../../core/services/storage/user_session_service.dart';

import '../../domain/entities/auth_entity.dart';

import '../../domain/usecase/change_password_usecase.dart';
import '../../domain/usecase/get_current_user_usecase.dart';
import '../../domain/usecase/login_usecase.dart';
import '../../domain/usecase/logout_usecase.dart';
import '../../domain/usecase/register_usecase.dart';
import '../../domain/usecase/update_profile_usecase.dart';
import '../state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
      () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;


  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);

    // Automatically verify active sessions on startup
    Future.microtask(() => _init());
    return const AuthState();
  }

  Future<void> _init() async {
    final result = await _getCurrentUserUsecase.call();
    result.fold(
          (failure) => state = state.copyWith(status: AuthStatus.unauthenticated),
          (authEntity) => state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: authEntity,
      ),
    );
  }



  // Register
  Future<void> register({
    required String username,
    required String email,
    required String phone,
    required String password,
    required String role,

    String? vehicleModel,
    String? vehicleColor,
    String? numberPlate,
    String? licenseNumber,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(seconds: 2));

    final params = RegisterUsecaseParams(
      username: username,
      email: email,
      phone: phone,
      password: password,
      role: role,
    );

    final result = await _registerUsecase.call(params);

    result.fold(
          (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
          (isRegistered) {
        state = state.copyWith(status: AuthStatus.registered);
      },
    );
  }

  // Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(seconds: 2));

    final params = LoginUsecaseParams(email: email, password: password);
    final result = await _loginUsecase.call(params);
    result.fold(
          (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
          (authEntity) async {
            final sessionService = ref.read(userSessionServiceProvider);
            await sessionService.saveUserSession(
              userId: authEntity.authId ?? '',
              username: authEntity.username ?? '',
              email: authEntity.email ?? '',
              phoneNumber: authEntity.phone ?? '',
              role: authEntity.role ?? 'user',
              accountStatus: authEntity.accountStatus ?? 'active',

              vehicleModel: authEntity.vehicleModel,
              vehicleColor: authEntity.vehicleColor,
              numberPlate: authEntity.numberPlate,
              licenseNumber: authEntity.licenseNumber,
              isAvailable: authEntity.isAvailable,
              licenseImageUrl: authEntity.licenseImageUrl,
              verificationStatus: authEntity.verificationStatus,
              verificationNote: authEntity.verificationNote,
            );

        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
        },
    );
  }


  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}