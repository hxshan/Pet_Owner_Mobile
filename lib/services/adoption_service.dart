import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/consts/api_consts.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_pet_model.dart';

class AdoptionService {
  final Dio _dio = DioClient().dio;

  // ─────────────────────────────────────────────────────────────────────────
  // 1. Browse available pets with optional filters
  //    GET /public/adoption/pets
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<AdoptionPet>> fetchPets({
    String? species,
    String? gender,
    String? size,
    String? energyLevel,
    bool? goodWithKids,
    bool? goodWithPets,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };
    if (species != null && species.isNotEmpty) queryParams['species'] = species;
    if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;
    if (size != null && size.isNotEmpty) queryParams['size'] = size;
    if (energyLevel != null && energyLevel.isNotEmpty) {
      queryParams['energyLevel'] = energyLevel;
    }
    if (goodWithKids != null) queryParams['goodWithKids'] = goodWithKids;
    if (goodWithPets != null) queryParams['goodWithPets'] = goodWithPets;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _dio.get(
      '/public/adoption/pets',
      queryParameters: queryParams,
    );

    final data = response.data;
    List<dynamic> petsJson = [];

    if (data is Map) {
      if (data['pets'] is List) {
        petsJson = data['pets'] as List;
      } else if (data['data'] is Map && data['data']['pets'] is List) {
        petsJson = data['data']['pets'] as List;
      } else if (data['data'] is List) {
        petsJson = data['data'] as List;
      }
    } else if (data is List) {
      petsJson = data;
    }

    return petsJson
        .map((e) => AdoptionPet.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. ML-powered recommendations
  //    POST /public/adoption/recommendations
  // ─────────────────────────────────────────────────────────────────────────
  Future<RecommendationResult> getRecommendations({
    String? preferredSpecies,
    String? preferredGender,
    String? preferredSize,
    String livingType = 'House',
    bool hasChildren = false,
    bool hasOtherPets = false,
    String activityLevel = 'Moderate',
    String experienceLevel = 'First-time',
    required String description,
    String? color, // ← optional color hard pre-filter
  }) async {
    // Species is now optional — send empty string if not specified
    final String speciesValue =
        (preferredSpecies != null && preferredSpecies.isNotEmpty)
        ? preferredSpecies
        : '';

    final body = {
      'modelPrefs': {
        'preferred_type': speciesValue,
        if (preferredGender != null && preferredGender.isNotEmpty)
          'preferred_gender': preferredGender,
        if (preferredSize != null && preferredSize.isNotEmpty)
          'preferred_size': preferredSize,
      },
      'lifestyle': {
        'livingType': livingType,
        'hasChildren': hasChildren,
        'hasOtherPets': hasOtherPets,
        'activityLevel': activityLevel,
        'experienceLevel': experienceLevel,
      },
      'description': description,
      if (color != null && color.isNotEmpty) 'color': color, // ← NEW
      'modelVersion': 'v4',
    };

    final response = await _dio.post(
      '/public/adoption/recommendations',
      data: body,
    );

    final data = response.data as Map<String, dynamic>;
    final List<dynamic> rawRecs = data['recommendations'] as List? ?? [];
    final List<AdoptionPet> pets = rawRecs
        .map((e) => AdoptionPet.fromJson(e as Map<String, dynamic>))
        .toList();

    final int total = (data['totalCandidates'] as int?) ?? pets.length;

    return RecommendationResult(
      pets: pets,
      totalCandidates: total,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. Submit adoption application  (requires user JWT)
  //    POST /adoption-applications
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> submitApplication({
    required String petId,
    required String livingType,
    required bool hasChildren,
    required bool hasOtherPets,
    required String activityLevel,
    required String experienceLevel,
    required String workSchedule,
    required String reasonForAdoption,
    String? additionalNotes,
    List<int>? childrenAges,
    String? otherPetsDetails,
  }) async {
    final body = <String, dynamic>{
      'petId': petId,
      'livingType': livingType,
      'hasChildren': hasChildren,
      'hasOtherPets': hasOtherPets,
      'activityLevel': activityLevel,
      'experienceLevel': experienceLevel,
      'workSchedule': workSchedule,
      'reasonForAdoption': reasonForAdoption,
    };

    if (additionalNotes != null && additionalNotes.isNotEmpty) {
      body['additionalNotes'] = additionalNotes;
    }
    if (hasChildren && childrenAges != null && childrenAges.isNotEmpty) {
      body['childrenAges'] = childrenAges;
    }
    if (hasOtherPets && otherPetsDetails != null && otherPetsDetails.isNotEmpty) {
      body['otherPetsDetails'] = otherPetsDetails;
    }

    await _dio.post(
      '/adoption-applications',
      data: body,
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. Get logged-in user's applications  (requires user JWT)
  //    GET /adoption-applications/my-applications
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<AdoptionApplication>> getMyApplications({String? status}) async {
    final Map<String, dynamic> queryParams = {};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final response = await _dio.get(
      '/adoption-applications/my-applications',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      options: Options(extra: {'requiresAuth': true}),
    );

    final data = response.data;
    List<dynamic> appsJson = [];

    if (data is Map) {
      if (data['applications'] is List) {
        appsJson = data['applications'] as List;
      } else if (data['data'] is List) {
        appsJson = data['data'] as List;
      }
    } else if (data is List) {
      appsJson = data;
    }

    return appsJson
        .map((e) => AdoptionApplication.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5. Withdraw a pending application  (requires user JWT)
  //    PATCH /adoption-applications/:id/withdraw
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> withdrawApplication(String applicationId) async {
    await _dio.patch(
      '/adoption-applications/$applicationId/withdraw',
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 6. Extract structured pet filters from free-text using OpenRouter LLM
  //    Model: openai/gpt-4o-mini  (~$0.00003 per query — practically free)
  //    Set openRouterApiKey in lib/consts/api_consts.dart
  // ─────────────────────────────────────────────────────────────────────────
  Future<ExtractedFilters> extractFiltersFromText(String userText) async {
    // Return empty if key not configured yet
    if (openRouterApiKey == 'YOUR_OPENROUTER_KEY_HERE' ||
        openRouterApiKey.trim().isEmpty) {
      return ExtractedFilters.empty();
    }

    final llmDio = Dio(
      BaseOptions(
        baseUrl: 'https://openrouter.ai/api/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Authorization': 'Bearer $openRouterApiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'pet-adoption-app',
        },
      ),
    );

    const systemPrompt = '''
You are a pet adoption preference extractor.
Read the user text and return ONLY a valid JSON object — no explanation, no markdown.

Return this exact format (all fields optional, use null if not mentioned):
{
  "species": "Dog" | "Cat" | "Rabbit" | "Bird" | "Other" | null,
  "gender": "Male" | "Female" | null,
  "size": "Small" | "Medium" | "Large" | null,
  "energyLevel": "Low" | "Moderate" | "High" | "Very High" | null,
  "goodWithKids": true | false | null,
  "goodWithPets": true | false | null,
  "livingType": "Apartment" | "House" | "Condo" | "Farm" | "Other" | null,
  "color": "Black" | "Brown" | "Golden" | "Yellow" | "Cream" | "Gray" | "White" | null,
  "detectedKeywords": ["word1", "word2"]
}

Extraction rules:
- "calm", "quiet", "lazy", "relaxed", "low energy" → energyLevel: "Low"
- "active", "playful", "energetic", "loves runs" → energyLevel: "High"
- "very playful", "super energetic", "very active", "extremely active", "high energy", "needs lots of exercise" → energyLevel: "Very High"
- "apartment", "flat", "small place" → livingType: "Apartment"
- "house", "garden", "yard" → livingType: "House"
- "kids", "children", "toddler", "baby" → goodWithKids: true
- "other pets", "have a dog", "have a cat" → goodWithPets: true
- "small", "tiny", "lap dog" → size: "Small"
- "big", "large", "large breed" → size: "Large"
- "black", "dark" → color: "Black"
- "brown", "chocolate" → color: "Brown"
- "golden", "gold", "orange-ish" → color: "Golden"
- "yellow" → color: "Yellow"
- "cream", "beige", "off-white" → color: "Cream"
- "gray", "grey", "silver" → color: "Gray"
- "white", "snow white" → color: "White"
- detectedKeywords: short list of key words you detected
Return ONLY the JSON object.''';

    final response = await llmDio.post(
      '/chat/completions',
      data: {
        'model': openRouterModel,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userText},
        ],
        'max_tokens': 300,
        'temperature': 0.1,
      },
    );

    final content =
        response.data['choices'][0]['message']['content'] as String? ?? '';

    // Strip markdown code fences if LLM wraps with ```json
    final cleaned = content
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) {
        return ExtractedFilters.fromJson(decoded);
      }
    } catch (_) {
      // If JSON parse fails, return empty (falls back to plain description)
    }

    return ExtractedFilters.empty();
  }
}

// ── ExtractedFilters model ────────────────────────────────────────────────────
/// Holds structured filters extracted by the LLM from the user's free text.
class ExtractedFilters {
  final String? species;
  final String? gender;
  final String? size;
  final String? energyLevel;
  final bool? goodWithKids;
  final bool? goodWithPets;
  final String? livingType;
  final String? color; // one of: Black | Brown | Golden | Yellow | Cream | Gray | White
  final List<String> detectedKeywords;

  const ExtractedFilters({
    this.species,
    this.gender,
    this.size,
    this.energyLevel,
    this.goodWithKids,
    this.goodWithPets,
    this.livingType,
    this.color,
    this.detectedKeywords = const [],
  });

  factory ExtractedFilters.empty() => const ExtractedFilters();

  factory ExtractedFilters.fromJson(Map<String, dynamic> json) {
    return ExtractedFilters(
      species: json['species'] as String?,
      gender: json['gender'] as String?,
      size: json['size'] as String?,
      energyLevel: json['energyLevel'] as String?,
      goodWithKids: json['goodWithKids'] as bool?,
      goodWithPets: json['goodWithPets'] as bool?,
      livingType: json['livingType'] as String?,
      color: json['color'] as String?,
      detectedKeywords: (json['detectedKeywords'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Human-readable chip labels for the detected filters
  List<String> get chipLabels {
    final labels = <String>[];
    if (species != null) labels.add(species!);
    if (gender != null) labels.add(gender!);
    if (size != null) labels.add('$size Size');
    if (energyLevel != null) labels.add('$energyLevel Energy');
    if (goodWithKids == true) labels.add('Good With Kids');
    if (goodWithPets == true) labels.add('Pet-Friendly');
    if (livingType != null) labels.add(livingType!);
    if (color != null) labels.add('$color Color');
    return labels;
  }

  bool get isEmpty => chipLabels.isEmpty;
}
