import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/consts/api_consts.dart';

class DiagnosisService {
  final Dio _dio = DioClient().dio;

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
}
