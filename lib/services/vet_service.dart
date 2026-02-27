import 'package:dio/dio.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/models/vet/vet_model.dart';

class VetService {
  final Dio _dio = DioClient().dio;

  Future<List<VetModel>> searchVets({String? q, int page = 1, int limit = 20, double? lat, double? lng, int? radius}) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (lat != null && lng != null) {
      params['lat'] = lat.toString();
      params['lng'] = lng.toString();
      if (radius != null) params['radius'] = radius;
    }

    final response = await _dio.get('/vets', queryParameters: params);

    final data = response.data;
    if (data == null || data['vets'] == null) return [];

    final List vets = data['vets'];
    return vets.map((v) => _fromApi(v)).toList();
  }

  Future<VetModel?> getVetById(String vetId) async {
    final response = await _dio.get('/vets/$vetId');
    final data = response.data;
    if (data == null || data['vet'] == null) return null;
    final v = data['vet'];
    return _fromApi(v);
  }

  VetModel _fromApi(Map<String, dynamic> v) {
    final id = v['_id'] ?? v['id'] ?? '';
    final first = v['firstname'] ?? '';
    final last = v['lastname'] ?? '';
    final vetData = v['veterinarianData'] ?? {};
    final clinic = vetData['clinic'] ?? {};

    final name = (first + ' ' + last).trim();
    final specialization = vetData['specialization'] ?? '';
    final address = (clinic['name'] ?? vetData['clinicName'] ?? clinic['address'] ?? vetData['clinicAddress'] ?? '').toString();
    final phone = clinic['phone'] ?? '';
    // distance may be provided by the API (meters)
    String distanceStr = '';
    if (v.containsKey('distance') && v['distance'] != null) {
      try {
        final d = (v['distance'] is num) ? (v['distance'] as num).toDouble() : double.parse(v['distance'].toString());
        if (d >= 1000) {
          distanceStr = '${(d / 1000).toStringAsFixed(1)} km';
        } else {
          distanceStr = '${d.toInt()} m';
        }
      } catch (_) {}
    }

    return VetModel(
      id: id.toString(),
      name: name.isNotEmpty ? name : (clinic['name'] ?? 'Unknown'),
      imageUrl: '',
      specialization: specialization ?? '',
      rating: 4.5,
      reviewCount: 0,
      address: address,
  distance: distanceStr,
      openStatus: '',
      phone: phone ?? '',
      isOpen: true,
    );
  }
}
