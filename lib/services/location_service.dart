import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pet_owner_mobile/utils/location_cache.dart';

class LocationResult {
  final bool success;
  final String message; // human-readable status/error
  final Position? position;
  final String? address;

  const LocationResult({
    required this.success,
    required this.message,
    this.position,
    this.address,
  });
}

class LocationService {
  /// Ensure permission + services are enabled.
  static Future<LocationPermission> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermission.denied; // treat as not allowed
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Get current GPS position
  static Future<LocationResult> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      final permission = await _ensurePermission();

      if (permission == LocationPermission.denied) {
        return const LocationResult(
          success: false,
          message: 'Location permission denied',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          success: false,
          message: 'Location permission permanently denied',
        );
      }

      // If services are off, Geolocator.isLocationServiceEnabled() was false
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          success: false,
          message: 'Location services are disabled',
        );
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );

      return LocationResult(success: true, message: 'OK', position: pos);
    } catch (e) {
      return LocationResult(
        success: false,
        message: 'Failed to get location: $e',
      );
    }
  }

  /// Convert coordinates -> "City, Country"
  static Future<String?> reverseGeocode(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return null;

      final p = placemarks.first;

      final city = (p.locality?.trim().isNotEmpty ?? false)
          ? p.locality!.trim()
          : (p.subAdministrativeArea?.trim().isNotEmpty ?? false)
          ? p.subAdministrativeArea!.trim()
          : (p.administrativeArea?.trim().isNotEmpty ?? false)
          ? p.administrativeArea!.trim()
          : '';

      final country = p.country?.trim() ?? '';

      final parts = [city, country].where((x) => x.isNotEmpty).toList();
      if (parts.isEmpty) return null;

      return parts.join(', ');
    } catch (_) {
      return null;
    }
  }

  /// One-call helper: permission + position + address
  static Future<LocationResult> getCurrentAddress({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    final posRes = await getCurrentPosition(accuracy: accuracy);
    if (!posRes.success || posRes.position == null) return posRes;

    final address = await reverseGeocode(posRes.position!);

    return LocationResult(
      success: true,
      message: 'OK',
      position: posRes.position,
      address: address ?? 'Unknown location',
    );
  }

  /// Optional convenience: open system location settings
  static Future<void> openLocationSettings() =>
      Geolocator.openLocationSettings();

  /// Optional convenience: open app settings for permission
  static Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<String> getLocationForUI() async {
    if (LocationCache.isFresh() && LocationCache.lastAddress != null) {
      return LocationCache.lastAddress!;
    }

    final res = await LocationService.getCurrentAddress();
    if (res.success && res.address != null) {
      LocationCache.set(res.address!);
      return res.address!;
    }
    return res.message; // show "Permission denied" etc
  }
}
