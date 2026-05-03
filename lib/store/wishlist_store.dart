import 'package:flutter/foundation.dart';
import 'package:pet_owner_mobile/models/ecommerce/product_model.dart';

/// Fully local wishlist store — no backend calls.
/// Lives inside [EcommerceShell] so it survives page navigation within the
/// ecommerce section.
class WishlistStore extends ChangeNotifier {
  WishlistStore();

  final Set<String> _ids = {};
  final List<Product> _products = [];

  // Always "loaded" since there is no async fetch.
  bool get isLoaded => true;
  bool get isLoading => false;

  List<Product> get products => List.unmodifiable(_products);

  bool contains(String productId) => _ids.contains(productId);

  /// No-op — kept so callers don't need changes.
  Future<void> loadOnce() async {}

  /// No-op — kept so RefreshIndicator works without crashing.
  Future<void> refresh() async {}

  /// Toggle a product in/out of the local wishlist.
  ///
  /// Pass [product] when *adding* so the wishlist screen can display it.
  /// When *removing*, only the id is needed — [product] may be null.
  Future<void> toggle(String productId, {Product? product}) async {
    if (_ids.contains(productId)) {
      _ids.remove(productId);
      _products.removeWhere((p) => p.id == productId);
    } else {
      _ids.add(productId);
      if (product != null && !_products.any((p) => p.id == productId)) {
        _products.add(product);
      }
    }
    notifyListeners();
  }
}