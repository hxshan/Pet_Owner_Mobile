import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';

class PetService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> createPet({
    required String name,
    required String breed,
    required String animalType,
    required DateTime dob,
    required String age,
    required String weight,
    required String color,
    required String health,
    required String lifeStatus,
    File? image,
  }) async {

    final response = await _dio.post(
      '/pet',
      data: {
        'name': name,
        'breed': breed,
        'species': animalType,
        'dob': dob.toIso8601String(),
        'age': age,
        'weightHistory': [
          {
            'weight': double.tryParse(weight) ?? 0,
            'date': DateTime.now().toIso8601String(),
          },
        ],
        'color': color,
        'health': health,
        'lifeStatus': lifeStatus,
        'gender': 'Unknown',
      },
      options: Options(
        contentType: 'application/json',
        extra: {'requiresAuth': true},
      ),
    );

    return response.data;
  }
}
