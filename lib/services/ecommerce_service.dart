import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/models/ecommerce/cart_model.dart';
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

  // Add Item to cart
  Future<void> addToCart({required String productId, required int qty}) async {
    final response = await _dio.post(
      '/ecommerce/cart',
      data: {'productId': productId, 'qty': qty},
      options: Options(
        contentType: 'application/json',
        extra: {'requiresAuth': true},
      ),
    );

    // optional: check message/success
    if ((response.statusCode ?? 0) >= 400) {
      throw Exception('Failed to add to cart');
    }
  }

  Future<Cart> getMyCart() async {
    final response = await _dio.get(
      '/ecommerce/cart',
      options: Options(extra: {'requiresAuth': true}),
    );

    final data = response.data;
    if (data is! Map || data['cart'] is! Map) {
      throw Exception('Unexpected cart response');
    }

    return Cart.fromJson(Map<String, dynamic>.from(data['cart']));
  }

  Future<void> updateCartItemQty({
    required String itemId,
    required int qty,
  }) async {
    await _dio.patch(
      '/ecommerce/cart/$itemId',
      data: {'qty': qty},
      options: Options(
        contentType: 'application/json',
        extra: {'requiresAuth': true},
      ),
    );
  }

  Future<void> removeCartItem({required String itemId}) async {
    await _dio.delete(
      '/ecommerce/cart/$itemId',
      options: Options(extra: {'requiresAuth': true}),
    );
  }
}
