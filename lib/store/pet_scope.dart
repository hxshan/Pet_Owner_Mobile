import 'package:flutter/widgets.dart';
import 'pet_store.dart';

class PetScope extends InheritedNotifier<PetStore> {
  const PetScope({
    super.key,
    required PetStore notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static PetStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PetScope>();
    assert(scope != null, 'PetScope not found in widget tree');
    return scope!.notifier!;
  }
}
