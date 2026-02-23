import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/models/ecommerce/product_model.dart';

class EcommerceService {
  final Dio _dio = DioClient().dio;

  // Get all products
  Future<Map<String, dynamic>> listProducts({
    String? search,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/ecommerce/products',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (category != null && category != 'All') 'category': category,
        'page': page,
        'limit': limit,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }

  // Get product details
  Future<Product> getProductById(String id) async {
    debugPrint("Inside getProductById: $id");
    final response = await _dio.get('/ecommerce/products/$id');

    final status = response.statusCode ?? 0;
    final data = response.data;

    // If your DioClient allows non-2xx, handle it here
    if (status < 200 || status >= 300) {
      final msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Failed to load product (HTTP $status)';
      throw Exception(msg);
    }

    if (data is! Map) {
      throw Exception('Unexpected response: not a JSON object');
    }

    final productJson = data['product'];
    if (productJson is! Map) {
      throw Exception(data['message']?.toString() ?? 'Product not found');
    }

    return Product.fromJson(Map<String, dynamic>.from(productJson));
  }
}
