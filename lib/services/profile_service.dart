import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/models/user_model.dart';
import 'package:pet_owner_mobile/utils/secure_storage.dart';

class ProfileService {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  User? _cachedUser;
  static const String _cacheKey = 'cached_profile_json';

  /// GET Pet Owner profile
  /// Fetch pet owner profile. Returns cached value when available unless
  /// `forceRefresh` is true. Cache is kept in-memory and persisted to secure storage.
  Future<User> getPetOwnerProfile({bool forceRefresh = false}) async {
    try {
      // Return in-memory cache if present and not forced
      if (!forceRefresh && _cachedUser != null) return _cachedUser!;

      // Try loading from secure storage
      if (!forceRefresh) {
        final cached = await _storage.read(key: _cacheKey);
        if (cached != null && cached.isNotEmpty) {
          try {
            final Map<String, dynamic> parsed = json.decode(cached) as Map<String, dynamic>;
            final user = User.fromJson(parsed);
            _cachedUser = user;
            return user;
          } catch (_) {
            // ignore parse errors and fall through to network fetch
          }
        }
      }

      final response = await _dio.get(
        '/user/pet-owner/profile',
        options: Options(extra: {'requiresAuth': true}),
      );

      final data = response.data;
      final userJson = (data['user'] as Map<String, dynamic>);

      final user = User.fromJson(userJson);
      // update caches
      _cachedUser = user;
      try {
        await _storage.write(key: _cacheKey, value: json.encode(userJson));
      } catch (_) {}

      return user;
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

      // If backend returned the updated user, update cache. Otherwise clear
      // cache so subsequent reads fetch fresh data.
      try {
        final resp = response.data as Map<String, dynamic>;
        if (resp.containsKey('user') && resp['user'] is Map) {
          final Map<String, dynamic> ujson = resp['user'].cast<String, dynamic>();
          final user = User.fromJson(ujson);
          _cachedUser = user;
          await _storage.write(key: _cacheKey, value: json.encode(ujson));
        } else {
          _cachedUser = null;
          await _storage.delete(key: _cacheKey);
        }
      } catch (_) {
        // ignore cache write errors
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

  /// Clear cached profile both in-memory and persisted
  Future<void> clearCachedProfile() async {
    try {
      _cachedUser = null;
      await _storage.delete(key: _cacheKey);
    } catch (_) {
      // ignore errors during cache clear
    }
  }
}
