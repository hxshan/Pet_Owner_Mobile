import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/consts/api_consts.dart';

class DiagnosisService {
  final Dio _dio = DioClient().dio;

  /// Dedicated Dio instance for CNN — longer timeout because inference on a
  /// cold-started cloud service can take 30-60 s.
  static final Dio _cnnDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  // Legacy route (kept for reference)
  Future<Map<String, dynamic>> predictSymptomChecker(Map<String, dynamic> payload) async {
    final url = '$diagnosisBackendUrl/predict-xgb/symptom-checker';
    final response = await _dio.post(url, data: payload);
    return response.data as Map<String, dynamic>;
  }

  /// New v2 route — payload uses individual symptom flags (0/1) and string fields.
  Future<Map<String, dynamic>> predictSymptomCheckerV2(Map<String, dynamic> payload) async {
    final url = '$diagnosisBackendUrl/predict-xgb-v2';
    final response = await _dio.post(url, data: payload);
    return response.data as Map<String, dynamic>;
  }

  /// CNN skin-condition route — sends the image as multipart/form-data.
  /// Returns { predicted_class, confidence, top_k: [{class, prob}] }
  Future<Map<String, dynamic>> predictCnn(File imageFile, {int topK = 3}) async {
    final url = '$diagnosisBackendUrl/predict-cnn?top_k=$topK';
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    });
    // Use _cnnDio (90 s receive timeout) — inference can be slow on cold start
    final response = await _cnnDio.post(url, data: formData);
    return response.data as Map<String, dynamic>;
  }
}
