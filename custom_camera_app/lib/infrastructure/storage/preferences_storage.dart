import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences wrapper with type-safe operations
class PreferencesStorage {
  final SharedPreferences _preferences;

  PreferencesStorage(this._preferences);

  // String operations
  Future<bool> setString(String key, String value) async {
    return await _preferences.setString(key, value);
  }

  String? getString(String key) {
    return _preferences.getString(key);
  }

  // Int operations
  Future<bool> setInt(String key, int value) async {
    return await _preferences.setInt(key, value);
  }

  int? getInt(String key) {
    return _preferences.getInt(key);
  }

  // Bool operations
  Future<bool> setBool(String key, bool value) async {
    return await _preferences.setBool(key, value);
  }

  bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  // List<String> operations
  Future<bool> setStringList(String key, List<String> value) async {
    return await _preferences.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _preferences.getStringList(key);
  }

  // Remove
  Future<bool> remove(String key) async {
    return await _preferences.remove(key);
  }

  // Clear all
  Future<bool> clear() async {
    return await _preferences.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _preferences.containsKey(key);
  }
}

/// Preference keys
class PreferenceKeys {
  PreferenceKeys._();

  static const String lastConnectedCameraId = 'last_connected_camera_id';
  static const String cameraListCache = 'camera_list_cache';
  static const String isFirstLaunch = 'is_first_launch';
  static const String themeMode = 'theme_mode';
}
