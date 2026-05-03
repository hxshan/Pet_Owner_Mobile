import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/models/auth/login_request.dart';
import 'package:pet_owner_mobile/models/auth/login_response.dart';
import 'package:pet_owner_mobile/services/push_service.dart';
import 'package:pet_owner_mobile/utils/secure_storage.dart';
import 'package:pet_owner_mobile/services/profile_service.dart';

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

    // Register FCM token to backend — best-effort, never block login
    try {
      final fcmToken =
          await PushService.instance.getStoredToken() ??
          await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        await PushService.instance.registerTokenToBackend(fcmToken);
      }
    } catch (_) {
      // FCM registration failure must not prevent the user from logging in
    }

    return loginResponse;
  }

  Future<void> logout() async {
    // Best-effort: unregister FCM token from backend.
    // If the token is expired or the call fails for any reason, we still
    // complete the local logout — never block the user from logging out.
    try {
      final fcmToken = await PushService.instance.getStoredToken();
      if (fcmToken != null) {
        await PushService.instance.unregisterTokenFromBackend(fcmToken);
      }
    } catch (e) {
      print('FCM unregister skipped (token likely expired): $e');
    }

    // Always clear local data regardless of the backend call above.
    try {
      await ProfileService().clearCachedProfile();
    } catch (_) {}

    await _storage.deleteAll();

    print('User logged out successfully.');
  }
}
