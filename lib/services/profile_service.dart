import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';

class ProfileService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final resp = await _dio.get(
        '/user/profile',
        options: Options(extra: {'requiresAuth': true}),
      );

      return resp.data;
    } catch (e) {
      print('ProfileService.getProfile error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> payload) async {
    try {
      final resp = await _dio.put(
        '/user/profile',
        data: payload,
        options: Options(extra: {'requiresAuth': true}),
      );

      return resp.data;
    } catch (e) {
      print('ProfileService.updateProfile error: $e');
      rethrow;
    }
  }
}
