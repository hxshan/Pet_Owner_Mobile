import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/consts/api_consts.dart';

class DiagnosisService {
  final Dio _dio = DioClient().dio;


  Future<Map<String, dynamic>> predictSymptomChecker(Map<String, dynamic> payload) async {
    final url = '$diagnosisBackendUrl/predict-xgb/symptom-checker';
    final response = await _dio.post(url, data: payload);
    return response.data as Map<String, dynamic>;
  }
}
