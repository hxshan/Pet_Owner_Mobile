import 'package:flutter/widgets.dart';
import 'adoption_favorites_store.dart';

class AdoptionFavoritesScope extends InheritedNotifier<AdoptionFavoritesStore> {
  const AdoptionFavoritesScope({
    super.key,
    required AdoptionFavoritesStore notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AdoptionFavoritesStore of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AdoptionFavoritesScope>();
    assert(scope != null, 'AdoptionFavoritesScope not found in widget tree');
    return scope!.notifier!;
  }
}
