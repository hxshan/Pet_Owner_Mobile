import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:pet_owner_mobile/core/dio_client.dart';
import 'package:pet_owner_mobile/models/ecommerce/address_model.dart';
import 'package:pet_owner_mobile/models/ecommerce/cart_model.dart';
import 'package:pet_owner_mobile/models/ecommerce/order_model.dart';
import 'package:pet_owner_mobile/models/ecommerce/product_model.dart';
import 'package:pet_owner_mobile/models/ecommerce/wishlist_model.dart';

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
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
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

  // ADDRESSES
  Future<List<Map<String, dynamic>>> listMyAddresses() async {
    final res = await _dio.get(
      '/ecommerce/addresses',
      options: Options(extra: {'requiresAuth': true}),
    );
    final list = (res.data['addresses'] as List?) ?? [];
    return List<Map<String, dynamic>>.from(list);
  }

  Future<List<Address>> listMyAddressModels() async {
    final res = await _dio.get(
      '/ecommerce/addresses',
      options: Options(extra: {'requiresAuth': true}),
    );

    final data = res.data;
    final list = (data is Map ? (data['addresses'] as List?) : null) ?? [];
    return list
        .whereType<Map>()
        .map((a) => Address.fromJson(Map<String, dynamic>.from(a)))
        .toList();
  }

  Future<Address> createAddress(Address address) async {
    final res = await _dio.post(
      '/ecommerce/addresses',
      data: address.toCreateJson(),
      options: Options(
        contentType: 'application/json',
        extra: {'requiresAuth': true},
      ),
    );

    final data = res.data;
    if (data is! Map || data['address'] is! Map) {
      throw Exception('Unexpected createAddress response');
    }

    return Address.fromJson(Map<String, dynamic>.from(data['address']));
  }

  Future<Address> updateAddress({
    required String id,
    required Address address,
  }) async {
    final res = await _dio.patch(
      '/ecommerce/addresses/$id',
      data: address.toUpdateJson(),
      options: Options(
        contentType: 'application/json',
        extra: {'requiresAuth': true},
      ),
    );

    final data = res.data;
    if (data is! Map || data['address'] is! Map) {
      throw Exception('Unexpected updateAddress response');
    }

    return Address.fromJson(Map<String, dynamic>.from(data['address']));
  }

  Future<void> deleteAddress({required String id}) async {
    final res = await _dio.delete(
      '/ecommerce/addresses/$id',
      options: Options(extra: {'requiresAuth': true}),
    );

    if ((res.statusCode ?? 0) >= 400) {
      throw Exception('Failed to delete address');
    }
  }

  Future<Address> setDefaultAddress({required String id}) async {
    final res = await _dio.post(
      '/ecommerce/addresses/$id/default',
      options: Options(extra: {'requiresAuth': true}),
    );

    final data = res.data;
    if (data is! Map || data['address'] is! Map) {
      throw Exception('Unexpected setDefaultAddress response');
    }

    return Address.fromJson(Map<String, dynamic>.from(data['address']));
  }

  // Wishlist
  Future<Wishlist> getMyWishlist() async {
    final res = await _dio.get(
      '/ecommerce/wishlist',
      options: Options(extra: {'requiresAuth': true}),
    );

    final data = res.data;
    if (data is! Map || data['wishlist'] is! Map) {
      throw Exception('Unexpected wishlist response');
    }

    return Wishlist.fromJson(Map<String, dynamic>.from(data['wishlist']));
  }

  Future<void> addToWishlist({required String productId}) async {
    final res = await _dio.post(
      '/ecommerce/wishlist',
      data: {'productId': productId},
      options: Options(
        contentType: 'application/json',
        extra: {'requiresAuth': true},
      ),
    );

    if ((res.statusCode ?? 0) >= 400) {
      throw Exception('Failed to add to wishlist');
    }
  }

  Future<void> removeFromWishlist({required String productId}) async {
    final res = await _dio.delete(
      '/ecommerce/wishlist/$productId',
      options: Options(extra: {'requiresAuth': true}),
    );

    if ((res.statusCode ?? 0) >= 400) {
      throw Exception('Failed to remove from wishlist');
    }
  }

  // ORDERS
  Future<Map<String, dynamic>> createOrder({
    required String addressId,
    String paymentMethod = 'COD',
    String note = '',
  }) async {
    final res = await _dio.post(
      '/ecommerce/orders',
      data: {
        'addressId': addressId,
        'paymentMethod': paymentMethod,
        'note': note,
      },
      options: Options(
        contentType: 'application/json',
        extra: {'requiresAuth': true},
      ),
    );
    return Map<String, dynamic>.from(res.data['order']);
  }

  Future<Map<String, dynamic>> listMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _dio.get(
      '/ecommerce/orders',
      queryParameters: {'page': page, 'limit': limit},
      options: Options(extra: {'requiresAuth': true}),
    );

    final data = res.data;
    if (data is! Map) {
      throw Exception('Unexpected orders response');
    }
    return Map<String, dynamic>.from(data);
  }

  Future<Order> getMyOrderById(String id) async {
    final res = await _dio.get(
      '/ecommerce/orders/$id',
      options: Options(extra: {'requiresAuth': true}),
    );

    final data = res.data;
    if (data is! Map || data['order'] is! Map) {
      throw Exception('Unexpected order details response');
    }

    return Order.fromJson(Map<String, dynamic>.from(data['order']));
  }
}
