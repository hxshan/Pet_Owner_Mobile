import 'package:flutter/foundation.dart';
import 'package:pet_owner_mobile/models/pet_management/pet_card_model.dart';
import 'package:pet_owner_mobile/services/pet_service.dart';

/// Central cache for the current user's pet list and individual pet details.
///
/// Usage:
///   - [loadOnce]  — fetches only if not already loaded (use on page init)
///   - [refresh]   — always re-fetches from the network (use after mutations)
///   - [getPetDetail] — returns a cached Map for a single pet, fetching if needed
///   - [invalidatePetDetail] — drops the cached detail for one pet
class PetStore extends ChangeNotifier {
  final PetService _service;
  PetStore(this._service);

  // ── Pet list ───────────────────────────────────────────────────────────────
  List<Pet> _pets = [];
  bool _loaded = false;
  bool _loading = false;

  List<Pet> get pets => List.unmodifiable(_pets);
  bool get isLoaded => _loaded;
  bool get isLoading => _loading;

  /// Load the pet list only if it hasn't been loaded yet.
  Future<void> loadOnce() async {
    if (_loaded || _loading) return;
    await refresh();
  }

  /// Always re-fetch the pet list from the API.
  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    try {
      final raw = await _service.getMyPets();
      _pets = raw.map(Pet.fromJson).toList();
      _loaded = true;
      // Clear per-pet detail cache so stale detail data is dropped too
      _petDetails.clear();
    } catch (_) {
      // Keep existing data on failure so the UI doesn't blank out
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Per-pet detail cache ───────────────────────────────────────────────────
  // Stores the full raw Map returned by GET /pet/{id}
  final Map<String, Map<String, dynamic>> _petDetails = {};
  final Set<String> _loadingDetails = {};

  /// Returns cached detail for [petId], or fetches it if not yet cached.
  /// Returns null while the fetch is in progress.
  Future<Map<String, dynamic>> getPetDetail(String petId) async {
    if (_petDetails.containsKey(petId)) return _petDetails[petId]!;
    if (_loadingDetails.contains(petId)) {
      // Wait until it appears in cache (poll briefly)
      while (_loadingDetails.contains(petId)) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _petDetails[petId]!;
    }
    _loadingDetails.add(petId);
    notifyListeners();
    try {
      final data = await _service.getPetById(petId);
      _petDetails[petId] = data;
      return data;
    } finally {
      _loadingDetails.remove(petId);
      notifyListeners();
    }
  }

  /// Whether the detail for [petId] is currently being fetched.
  bool isDetailLoading(String petId) => _loadingDetails.contains(petId);

  /// Whether the detail for [petId] is already cached.
  bool hasDetailCached(String petId) => _petDetails.containsKey(petId);

  /// Get the cached detail synchronously (null if not cached yet).
  Map<String, dynamic>? getCachedDetail(String petId) => _petDetails[petId];

  /// Drop the cached detail for one pet (e.g. after editing it).
  void invalidatePetDetail(String petId) {
    _petDetails.remove(petId);
    notifyListeners();
  }

  /// Delete a pet via the API, then invalidate its detail cache and refresh the list.
  Future<void> deletePet(String petId) async {
    await _service.deletePet(petId);
    _petDetails.remove(petId);
    await refresh();
  }

  /// Wipe all in-memory cached data.
  /// Call this on logout so the next user starts with a clean slate.
  void clear() {
    _pets = [];
    _loaded = false;
    _loading = false;
    _petDetails.clear();
    _loadingDetails.clear();
    notifyListeners();
  }
}
