class LocationCache {
  static String? _lastAddress;
  static DateTime? _lastUpdated;

  static String? get lastAddress => _lastAddress;

  static bool isFresh({Duration ttl = const Duration(minutes: 10)}) {
    if (_lastUpdated == null) return false;
    return DateTime.now().difference(_lastUpdated!) < ttl;
  }

  static void set(String address) {
    _lastAddress = address;
    _lastUpdated = DateTime.now();
  }

  static void clear() {
    _lastAddress = null;
    _lastUpdated = null;
  }
}