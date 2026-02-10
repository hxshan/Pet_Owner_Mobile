import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/models/auth/login_request.dart';
import 'package:pet_owner_mobile/models/auth/login_response.dart';
import 'package:pet_owner_mobile/utils/secure_storage.dart';

class AuthService {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Signup Pet Owner
  Future<Map<String, dynamic>> signupPetOwner({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String phone,
    required String nicNumber,
    required String address,
  }) async {
    final response = await _dio.post(
      '/auth/signup',
      data: {
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'password': password,
        'phone': phone,
        'nicNumber': nicNumber,
        'address': address,
      },
    );

    return response.data;
  }

  // Login Pet Owner
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post('/auth/login', data: request.toJson());

    final loginResponse = LoginResponse.fromJson(response.data);

    await SecureStorage.saveToken(loginResponse.token);
    await SecureStorage.saveData('first_name', loginResponse.user.firstname);

    return loginResponse;
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
