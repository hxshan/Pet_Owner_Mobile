import 'cart_item_model.dart';

class Cart {
  final String id;
  final List<CartItem> items;

  Cart({
    required this.id,
    required this.items,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? [];
    return Cart(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      items: rawItems
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  int get totalItems => items.fold(0, (sum, i) => sum + i.qty);
}