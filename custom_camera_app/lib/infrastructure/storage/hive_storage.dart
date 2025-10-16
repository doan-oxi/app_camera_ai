import 'package:hive_flutter/hive_flutter.dart';

/// Hive-based cache storage with TTL support
class HiveStorage {
  static const String _cameraBoxName = 'camera_cache';
  static const String _timestampSuffix = '_timestamp';

  Box<dynamic>? _cameraBox;

  /// Initialize Hive
  Future<void> init() async {
    await Hive.initFlutter();
    _cameraBox = await Hive.openBox<dynamic>(_cameraBoxName);
  }

  /// Save to cache with current timestamp
  Future<void> put(String key, dynamic value) async {
    await _cameraBox?.put(key, value);
    await _cameraBox?.put('$key$_timestampSuffix', DateTime.now().millisecondsSinceEpoch);
  }

  /// Get from cache if not expired
  T? get<T>(String key, {int? ttlSeconds}) {
    if (_cameraBox == null) return null;

    // Check TTL if provided
    if (ttlSeconds != null) {
      final timestamp = _cameraBox!.get('$key$_timestampSuffix') as int?;
      if (timestamp != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (age > ttlSeconds * 1000) {
          // Expired, delete and return null
          delete(key);
          return null;
        }
      }
    }

    return _cameraBox!.get(key) as T?;
  }

  /// Delete from cache
  Future<void> delete(String key) async {
    await _cameraBox?.delete(key);
    await _cameraBox?.delete('$key$_timestampSuffix');
  }

  /// Clear all cache
  Future<void> clear() async {
    await _cameraBox?.clear();
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _cameraBox?.containsKey(key) ?? false;
  }

  /// Close box
  Future<void> close() async {
    await _cameraBox?.close();
  }
}

/// Cache keys
class CacheKeys {
  CacheKeys._();

  static const String cameraList = 'camera_list';
  static String cameraStatus(String id) => 'camera_status_$id';
  static String cameraDetails(String id) => 'camera_details_$id';
}
