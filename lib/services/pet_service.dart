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
    required String gender,
    File? image,
  }) async {
    // Backend requires a real dob for diet plan generation.
    // If no explicit dob is supplied, approximate it from the age in years.
    final DateTime effectiveDob = dob ?? _dobFromAgeYears(age);

    final response = await _dio.post(
      '/pet',
      data: {
        'name': name,
        'breed': breed,
        'species': animalType,
        'dob': effectiveDob.toIso8601String(),
        'age': int.tryParse(age.trim()) ?? 0,
        'weightHistory': [
          {
            'weight': double.tryParse(weight) ?? 0,
            'date': DateTime.now().toIso8601String(),
          },
        ],
        'color': color,
        'health': health,
        'lifeStatus': lifeStatus,
        'gender': gender,
      },
      options: Options(
        contentType: 'application/json',
        extra: {'requiresAuth': true},
      ),
    );

    return response.data;
  }

  /// Converts an age string like "3" into an approximate DateTime by
  /// subtracting that many years from today's date.
  DateTime _dobFromAgeYears(String age) {
    final years = int.tryParse(age.trim()) ?? 0;
    final now = DateTime.now();
    return DateTime(now.year - years, now.month, now.day);
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

  /// GET /pet/events/upcoming — returns upcoming appointments and
  /// vaccination reminders (due / overdue) for all of the owner's pets.
  Future<List<Map<String, dynamic>>> getUpcomingEvents() async {
    try {
      final response = await _dio.get(
        '/pet/events/upcoming',
        options: Options(extra: {'requiresAuth': true}),
      );
      final data = response.data;
      if (data == null || data['events'] == null) return [];
      return List<Map<String, dynamic>>.from(data['events']);
    } catch (e) {
      print('Error fetching upcoming events: $e');
      return [];
    }
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
