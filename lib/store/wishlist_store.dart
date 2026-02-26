import 'package:flutter/foundation.dart';
import 'package:pet_owner_mobile/models/ecommerce/product_model.dart';
import 'package:pet_owner_mobile/services/ecommerce_service.dart';

class WishlistStore extends ChangeNotifier {
  final EcommerceService _service;

  WishlistStore(this._service);

  final Set<String> _ids = {};
  final List<Product> _products = [];

  bool _loaded = false;
  bool _loading = false;

  bool get isLoaded => _loaded;
  bool get isLoading => _loading;

  List<Product> get products => List.unmodifiable(_products);

  bool contains(String productId) => _ids.contains(productId);

  Future<void> loadOnce() async {
    if (_loaded || _loading) return;
    await refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();

    try {
      final wl = await _service.getMyWishlist();

      _products
        ..clear()
        ..addAll(wl.products);

      _ids
        ..clear()
        ..addAll(wl.products.map((p) => p.id));

      _loaded = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(String productId) async {
    final wasFav = _ids.contains(productId);

    // optimistic update (both ids + products)
    if (wasFav) {
      _ids.remove(productId);
      _products.removeWhere((p) => p.id == productId);
    } else {
      _ids.add(productId);
      // If you want instant add without refresh: you need the Product object.
      // Usually we just refresh after adding, because we don't have product details here.
    }
    notifyListeners();

    try {
      if (wasFav) {
        await _service.removeFromWishlist(productId: productId);
      } else {
        await _service.addToWishlist(productId: productId);
        // bring full product details in
        await refresh();
      }
    } catch (e) {
      // rollback by re-syncing from server (safest)
      await refresh();
      rethrow;
    }
  }
}