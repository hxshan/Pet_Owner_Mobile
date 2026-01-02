import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/models/auth/login_request.dart';
import 'package:pet_owner_mobile/models/auth/login_response.dart';
import 'package:pet_owner_mobile/models/auth/signup_request.dart';
import 'package:pet_owner_mobile/models/auth/signup_response.dart';

class AuthService {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Signup Pet Owner
  Future<SignupResponse> signupPetOwner(SignupRequest request) async {
    try {
      final response = await _dio.post('/auth/signup', data: request.toJson());

      return SignupResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Something went wrong';
      throw Exception(message);
    }
  }

  // Login Pet Owner
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/login', data: request.toJson());

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Login failed';
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    try {
      await _storage.deleteAll();
      print('User logged out successfully.');
    } catch (e) {
      print('Logout failed: $e');
      throw Exception('Failed to logout');
    }
  }
}
