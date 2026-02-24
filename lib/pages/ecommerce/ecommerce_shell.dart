import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/services/ecommerce_service.dart';
import 'package:pet_owner_mobile/store/wishlist_scope.dart';
import 'package:pet_owner_mobile/store/wishlist_store.dart';

class EcommerceShell extends StatefulWidget {
  final Widget child;
  const EcommerceShell({super.key, required this.child});

  @override
  State<EcommerceShell> createState() => _EcommerceShellState();
}

class _EcommerceShellState extends State<EcommerceShell> {
  late final WishlistStore _wishlistStore;

  @override
  void initState() {
    super.initState();
    _wishlistStore = WishlistStore(EcommerceService());
  }

  @override
  void dispose() {
    _wishlistStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WishlistScope(notifier: _wishlistStore, child: widget.child);
  }
}
