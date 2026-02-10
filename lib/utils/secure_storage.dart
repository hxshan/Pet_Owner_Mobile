import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<void> saveData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: 'auth_token');
  }

  static Future<String?> getData(String key) async {
    return _storage.read(key: key);
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
