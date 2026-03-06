import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/models/pet_management/vaccination_model.dart';

class VaccinationService {
  final Dio _dio = DioClient().dio;

  /// Fetches all vaccinations for the logged-in pet owner.
  /// Calls GET /vaccination/owner with the auth token.
  Future<List<VaccinationModel>> fetchOwnerVaccinations() async {
    try {
      final response = await _dio.get(
        '/vaccination/owner',
        options: Options(extra: {'requiresAuth': true}),
      );

      final data = response.data;
      if (data == null || data['data'] == null) return [];

      final List raw = data['data'];
      return raw
          .map((e) => VaccinationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching vaccinations: $e');
      return [];
    }
  }
}
