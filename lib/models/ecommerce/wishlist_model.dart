import 'package:pet_owner_mobile/models/ecommerce/product_model.dart';

class Wishlist {
  final String id;
  final List<Product> products;

  Wishlist({required this.id, required this.products});

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    final productsJson = (json['products'] as List?) ?? [];
    return Wishlist(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      products: productsJson
          .whereType<Map>()
          .map((p) => Product.fromJson(Map<String, dynamic>.from(p)))
          .toList(),
    );
  }
}