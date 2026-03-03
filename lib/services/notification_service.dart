import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';

class NotificationService {
  final Dio _dio = DioClient().dio;

  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    final res = await _dio.get(
      '/notifications',
      options: Options(extra: {'requiresAuth': true}),
    );

    final list = (res.data['notifications'] as List?) ?? [];
    return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  Future<void> markAsRead(String id) async {
    await _dio.post(
      '/notifications/$id/read',
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<void> markAllAsRead() async {
    await _dio.post(
      '/notifications/all/read',
      options: Options(extra: {'requiresAuth': true}),
    );
  }
}