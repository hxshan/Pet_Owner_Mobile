import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_center_model.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_pet_model.dart';

class AdoptionCenterService {
  final Dio _dio = DioClient().dio;

  /// Search for adoption centers with optional filters
  /// 
  /// Parameters:
  /// - [q]: Text search query for center name
  /// - [city]: Filter by city
  /// - [state]: Filter by state
  /// - [lat]: Latitude for proximity search
  /// - [lng]: Longitude for proximity search
  /// - [radius]: Search radius in meters (default 50000m = 50km)
  /// - [page]: Page number for pagination (default 1)
  /// - [limit]: Number of results per page (default 20)
  Future<List<AdoptionCenter>> searchCenters({
    String? q,
    String? city,
    String? state,
    double? lat,
    double? lng,
    int? radius,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };

    if (q != null && q.isNotEmpty) queryParams['search'] = q;
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (state != null && state.isNotEmpty) queryParams['state'] = state;
    
    // Add location-based search parameters
    if (lat != null && lng != null) {
      queryParams['lat'] = lat.toString();
      queryParams['lng'] = lng.toString();
      if (radius != null) queryParams['radius'] = radius;
    }

    final response = await _dio.get(
      '/public/adoption/adoption-centers',
      queryParameters: queryParams,
    );

    final data = response.data;
    List<dynamic> centersJson = [];

    if (data is Map) {
      if (data['data'] is List) {
        centersJson = data['data'] as List;
      } else if (data['centers'] is List) {
        centersJson = data['centers'] as List;
      }
    } else if (data is List) {
      centersJson = data;
    }

    return centersJson
        .map((e) => AdoptionCenter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get detailed information about a specific adoption center including their pets
  /// 
  /// Parameters:
  /// - [centerId]: The ID of the adoption center
  Future<AdoptionCenterDetails> getCenterDetails(String centerId) async {
    final response = await _dio.get(
      '/public/adoption/adoption-centers/$centerId',
    );

    final data = response.data;
    Map<String, dynamic> centerData = {};
    List<dynamic> petsData = [];

    if (data is Map) {
      if (data['data'] is Map) {
        centerData = data['data'] as Map<String, dynamic>;
        if (centerData['pets'] is List) {
          petsData = centerData['pets'] as List;
        }
      } else {
        centerData = Map<String, dynamic>.from(data);
        if (data['pets'] is List) {
          petsData = data['pets'] as List;
        }
      }
    }

    final center = AdoptionCenter.fromJson(centerData);
    final pets = petsData
        .map((e) => AdoptionPet.fromJson(e as Map<String, dynamic>))
        .toList();

    return AdoptionCenterDetails(center: center, pets: pets);
  }
}

/// Combined result containing center info and their available pets
class AdoptionCenterDetails {
  final AdoptionCenter center;
  final List<AdoptionPet> pets;

  AdoptionCenterDetails({
    required this.center,
    required this.pets,
  });
}
