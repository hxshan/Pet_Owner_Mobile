import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:pet_owner_mobile/core/dio_client.dart';

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final _storage = const FlutterSecureStorage();

  /// Call at app start — NO permission prompt.
  Future<void> initSilent() async {
    // Listen token refresh (won’t fire unless token exists)
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _storage.write(key: "fcm_token", value: newToken);

      // if logged in, register refreshed token
      final jwt = await _storage.read(key: "token"); // adjust key if needed
      if (jwt != null) {
        await registerTokenToBackend(newToken);
      }
    });

    // Try to read an existing token without prompting permission.
    // On iOS, token may be null until permission is granted.
    final token = await _messaging.getToken();
    if (token != null) {
      await _storage.write(key: "fcm_token", value: token);
    }
  }

  /// Call from Dashboard (or after login) to request permission + register token.
  Future<bool> requestPermissionAndRegister() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!granted) return false;

    // iOS foreground presentation options (safe to call on Android too)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    if (token == null) return false;

    await _storage.write(key: "fcm_token", value: token);

    // Only register if user is logged in (JWT exists)
    final jwt = await _storage.read(key: "token"); // adjust key if needed
    if (jwt != null) {
      await registerTokenToBackend(token);
    }

    return true;
  }

  Future<void> registerTokenToBackend(String token) async {
    final dio = DioClient().dio;
    await dio.post(
      "/devices/register",
      data: {"token": token, "platform": Platform.isIOS ? "ios" : "android"},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<void> unregisterTokenFromBackend(String token) async {
    final dio = DioClient().dio;
    await dio.post(
      "/devices/unregister",
      data: {"token": token},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<String?> getStoredToken() async {
    return _storage.read(key: "fcm_token");
  }
}
