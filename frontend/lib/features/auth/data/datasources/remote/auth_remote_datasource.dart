import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/api/api_client.dart';
import '../../../../../../core/services/storage/user_session_service.dart';
import '../../../../../core/api/api_endpoints.dart';
import '../auth_datasource.dart';
import '../../models/auth_api_model.dart';
import '../../../../../../core/services/storage/token_service.dart';

// Provider setup for Riverpod
final authRemoteDataSourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDataSource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService,
        _tokenService = tokenService;

  @override
  Future<AuthApiModel?> getUserById(String authId) async {
    final response = await _apiClient.get(
      ApiEndpoints.getDriverProfile,
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }
    return null;
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    // 1. SENDING DATA: We only send email and password to your Express API
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    // 2. RECEIVING DATA: If the credentials match, the backend returns the full driver profile
    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      // 3. CACHING DATA: Save the complete profile locally so the UI can use it instantly
      await _userSessionService.saveUserSession(
        userId: user.id ?? '',
        username: user.username,
        email: user.email,
        phoneNumber: user.phone,
        role: user.role,
        accountStatus: user.accountStatus,
        imageUrl: user.imageUrl,
      );

      // Save the authentication token for header interceptors
      final token = response.data['token'] as String?;
      if (token != null) {
        await _tokenService.saveToken(token);
      }

      return user;
    }
    return null;
  }

  @override
  Future<AuthApiModel> register(dynamic user) async {
    final AuthApiModel model = user is AuthApiModel ? user : AuthApiModel.fromEntity(user);

    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'username': model.username,
        'email': model.email,
        'phone': model.phone,
        'password': model.password,
        'role': model.role,
      },
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    }

    return model;
  }
}