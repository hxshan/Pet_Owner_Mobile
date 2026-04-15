import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';

class PetService {
  final Dio _dio = DioClient().dio;

  // Create a new pet
  Future<Map<String, dynamic>> createPet({
    required String name,
    required String breed,
    required String animalType,
    DateTime? dob,
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
        if (dob != null) 'dob': dob.toIso8601String(),
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

  // Fetch pets of the logged-in user
  Future<List<Map<String, dynamic>>> getMyPets() async {
    try {
      final response = await _dio.get(
        '/pet/my',
        options: Options(extra: {'requiresAuth': true}),
      );

      if (response.data['success'] == true) {
        final List data = response.data['data'];

        return List<Map<String, dynamic>>.from(data);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching pets: $e');
      return [];
    }
  }

  // Fetch pet details by ID
  Future<Map<String, dynamic>> getPetById(String petId) async {
    final response = await _dio.get(
      '/pet/$petId',
      options: Options(extra: {'requiresAuth': true}),
    );

    return response.data['data'];
  }

  Future<void> deletePet(String petId) async {
    await _dio.delete(
      '/pet/$petId',
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  // Update an existing pet profile
  Future<Map<String, dynamic>> updatePet({
    required String petId,
    required String name,
    required String breed,
    required String species,
    required DateTime dob,
    required String gender,
    required String weight,
    required String color,
    required bool neutered,
  }) async {
    final response = await _dio.put(
      '/pet/$petId',
      data: {
        'name': name,
        'breed': breed,
        'species': species,
        'dob': dob.toIso8601String(),
        'gender': gender,
        'weight': double.tryParse(weight) ?? 0,
        'color': color,
        'neutered': neutered,
      },
      options: Options(
        contentType: 'application/json',
        extra: {'requiresAuth': true},
      ),
    );
    return response.data;
  }

  /// PUT /pet/:petId/profile-image — upload a pet profile image.
  /// Returns the new [profileImageUrl] from the response, or empty string.
  Future<String> uploadPetProfileImage({
    required String petId,
    required File imageFile,
  }) async {
    final formData = FormData.fromMap({
      'profileImage': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split(Platform.pathSeparator).last,
      ),
    });

    final response = await _dio.put(
      '/pet/$petId/profile-image',
      data: formData,
      options: Options(
        extra: {'requiresAuth': true},
        contentType: 'multipart/form-data',
      ),
    );

    final data = response.data;
    if (data is Map) {
      return (data['profileImageUrl'] ?? data['profileImage'] ?? '').toString();
    }
    return '';
  }
}
