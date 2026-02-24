import 'package:flutter/widgets.dart';
import 'wishlist_store.dart';

class WishlistScope extends InheritedNotifier<WishlistStore> {
  const WishlistScope({
    super.key,
    required WishlistStore notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static WishlistStore of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<WishlistScope>();
    assert(scope != null, 'WishlistScope not found in widget tree');
    return scope!.notifier!;
  }
}