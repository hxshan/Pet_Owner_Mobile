import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/models/auth/signup_request.dart';
import 'package:pet_owner_mobile/models/auth/signup_response.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  // Signup Pet Owner
  Future<SignupResponse> signupPetOwner(SignupRequest request) async {
    try {
      final response = await _dio.post('/auth/signup', data: request.toJson());

      return SignupResponse.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Something went wrong';
      throw Exception(message);
    }
  }
}
