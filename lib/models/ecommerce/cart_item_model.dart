import 'package:pet_owner_mobile/models/ecommerce/product_model.dart';

class CartItem {
  final String id;
  final Product product;
  final int qty;

  CartItem({
    required this.id,
    required this.product,
    required this.qty,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      product: Product.fromJson(Map<String, dynamic>.from(json['product'] ?? {})),
      qty: (json['qty'] is num) ? (json['qty'] as num).toInt() : 1,
    );
  }
}