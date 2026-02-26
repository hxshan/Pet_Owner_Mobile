import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/models/user_model.dart';
import 'package:pet_owner_mobile/utils/secure_storage.dart';

class ProfileService {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// GET Pet Owner profile
  Future<User> getPetOwnerProfile() async {
    try {
      final response = await _dio.get(
        '/user/pet-owner/profile',
        options: Options(extra: {'requiresAuth': true}),
      );

      final data = response.data;
      final userJson = (data['user'] as Map<String, dynamic>);

      return User.fromJson(userJson);
    } on DioException catch (e) {
      throw Exception(_readableDioError(e));
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// PATCH Pet Owner profile
  /// Allowed: firstname, lastname, email, phone, address
  /// Also updates local storage 'first_name' if firstname changed
  Future<Map<String, dynamic>> updatePetOwnerProfile({
    required String firstname,
    required String lastname,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      // Read old first name from secure storage (for comparison)
      final oldFirstName = await _storage.read(key: 'first_name');

      final response = await _dio.patch(
        '/user/pet-owner/profile',
        data: {
          'firstname': firstname,
          'lastname': lastname,
          'email': email,
          'phone': phone,
          'address': address,
        },
        options: Options(extra: {'requiresAuth': true}),
      );

      // Update local storage first_name if changed
      if (oldFirstName == null || oldFirstName != firstname) {
        await SecureStorage.saveData('first_name', firstname);
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_readableDioError(e));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// PATCH Change password (ALL roles)
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.patch(
        '/user/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
        options: Options(extra: {'requiresAuth': true}),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_readableDioError(e));
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // Nice error messages
  String _readableDioError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    // If backend returns { message: "..." }
    if (data is Map && data['message'] != null) {
      return '($status) ${data['message']}';
    }

    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please try again.';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server took too long to respond. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection.';
    }

    return 'Request failed${status != null ? " ($status)" : ""}: ${e.message}';
  }
}
