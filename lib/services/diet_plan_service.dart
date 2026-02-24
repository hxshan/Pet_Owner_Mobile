import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';

class DietPlanService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> generateDietPlan({
    required String petId,
    required double ageMonths,
    required double weightKg,
    required String activityLevel,
    required String disease,
    required String allergy,
  }) async {
    final res = await _dio.post(
      '/diet-plans/generate',
      data: {
        'petId': petId,
        'ageMonths': ageMonths,
        'weightKg': weightKg,
        'activityLevel': activityLevel,
        'disease': disease,
        'allergy': allergy,
      },
      options: Options(extra: {'requiresAuth': true}),
    );

    // backend returns: { plan: created }
    return (res.data['plan'] as Map).cast<String, dynamic>();
  }

  Future<List<Map<String, dynamic>>> getMyDietPlans({String? petId}) async {
    final res = await _dio.get(
      '/diet-plans',
      queryParameters: petId != null ? {'petId': petId} : null,
      options: Options(extra: {'requiresAuth': true}),
    );

    final plans = (res.data['plans'] as List?) ?? [];
    return plans.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  Future<Map<String, dynamic>> getDietPlanById(String id) async {
    final res = await _dio.get(
      '/diet-plans/$id',
      options: Options(extra: {'requiresAuth': true}),
    );

    return (res.data['plan'] as Map).cast<String, dynamic>();
  }
}