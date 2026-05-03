import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_pet_model.dart';

/// Fully local adoption favorites store — persists to flutter_secure_storage.
/// Mount via [AdoptionFavoritesScope] at the app root so it is accessible
/// everywhere and survives navigation.
class AdoptionFavoritesStore extends ChangeNotifier {
  static const _storageKey = 'adoption_favorites';
  static const _storage = FlutterSecureStorage();

  final Set<String> _ids = {};
  final List<AdoptionPet> _pets = [];

  bool _isLoaded = false;
  bool _isLoading = false;

  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;

  List<AdoptionPet> get pets => List.unmodifiable(_pets);

  bool contains(String petId) => _ids.contains(petId);

  /// Load favorites from secure storage once. No-op on subsequent calls.
  Future<void> loadOnce() async {
    if (_isLoaded || _isLoading) return;
    _isLoading = true;

    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final pet = AdoptionPet.fromJson(item);
            if (!_ids.contains(pet.id)) {
              _ids.add(pet.id);
              _pets.add(pet);
            }
          }
        }
      }
    } catch (_) {
      // Corrupt storage — start fresh
      await _storage.delete(key: _storageKey);
    }

    _isLoaded = true;
    _isLoading = false;
    notifyListeners();
  }

  /// Toggle a pet in/out of favorites and persist.
  ///
  /// Pass [pet] when adding so the favorites screen can display it.
  /// When removing, only the id is needed.
  Future<void> toggle(String petId, {AdoptionPet? pet}) async {
    if (_ids.contains(petId)) {
      _ids.remove(petId);
      _pets.removeWhere((p) => p.id == petId);
    } else {
      _ids.add(petId);
      if (pet != null && !_pets.any((p) => p.id == petId)) {
        _pets.add(pet);
      }
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final encoded = jsonEncode(_pets.map((p) => p.toJson()).toList());
      await _storage.write(key: _storageKey, value: encoded);
    } catch (_) {
      // Silently ignore storage errors
    }
  }
}
