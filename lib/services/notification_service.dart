import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/models/notification_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final Dio _dio = DioClient().dio;

  /// GET /api/v1/notifications
  Future<List<AppNotification>> fetchNotifications() async {
    final res = await _dio.get(
      '/notifications',
      options: Options(extra: {'requiresAuth': true}),
    );

    final data = res.data;
    final list = (data is Map && data['notifications'] is List)
        ? (data['notifications'] as List)
        : <dynamic>[];

    return list
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
  }

  /// POST /api/v1/notifications/{id}/read
  Future<void> markRead(String id) async {
    await _dio.post(
      '/notifications/$id/read',
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  /// POST /api/v1/notifications/all/read
  Future<void> markAllRead() async {
    await _dio.post(
      '/notifications/all/read',
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  /// Optional: friendly “time ago” helper for UI (if you still want the string)
  String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    final weeks = (diff.inDays / 7).floor();
    return '$weeks week${weeks == 1 ? '' : 's'} ago';
  }
}