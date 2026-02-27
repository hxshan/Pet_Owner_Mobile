import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';

class AppointmentService {
  final Dio _dio = DioClient().dio;

  /// Get available slots for a vet on a given date (YYYY-MM-DD)
  Future<List<Map<String, dynamic>>> getAvailableSlots(String vetId, String date) async {
    final response = await _dio.get('/appointments/vets/$vetId/available-slots', queryParameters: {'date': date});
    final data = response.data;
    if (data == null || data['slots'] == null) return [];
    final List slots = data['slots'];
    return List<Map<String, dynamic>>.from(slots);
  }

  /// Book an appointment (requires auth)
  Future<Map<String, dynamic>> bookAppointment({
    required String vetId,
    required String petId,
    required String startTimeIso,
    String? reason,
  }) async {
    final response = await _dio.post(
      '/appointments/vets/$vetId/book',
      data: {
        'petId': petId,
        'startTime': startTimeIso,
        if (reason != null) 'reason': reason,
      },
      options: Options(extra: {'requiresAuth': true}),
    );

    return response.data;
  }
}
