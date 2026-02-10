import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/consts/api_consts.dart';
import 'package:pet_owner_mobile/utils/secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: backendUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth = options.extra['requiresAuth'] == true;

          if (requiresAuth) {
            final token = await SecureStorage.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
        onError: (DioException e, handler) {
          final message =
              e.response?.data is Map && e.response?.data['message'] != null
              ? e.response?.data['message']
              : 'Something went wrong';

          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: message,
              type: e.type,
              response: e.response,
            ),
          );
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
}
