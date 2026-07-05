import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: false),
  );

  /// Write to both secure storage and SharedPreferences (for fast splash reads)
  static Future<void> write(String key, String value) async {
    await Future.wait([
      _storage.write(key: key, value: value).catchError((_) async {}),
      _writeToPrefs(key, value),
    ]);
  }

  static Future<void> _writeToPrefs(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {}
  }

  static Future<String?> read(String key) async {
    // Try SharedPreferences first (fast, no Keystore)
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getString(key);
      if (val != null) return val;
    } catch (_) {}

    // Fallback to secure storage
    try {
      return await _storage.read(key: key)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      return null;
    }
  }

  static Future<void> delete(String key) async {
    await Future.wait([
      _storage.delete(key: key).catchError((_) async {}),
      _deleteFromPrefs(key),
    ]);
  }

  static Future<void> _deleteFromPrefs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (_) {}
  }

  static Future<void> deleteAll() async {
    await Future.wait([
      _storage.deleteAll().catchError((_) async {}),
      _clearPrefs(),
    ]);
  }

  static Future<void> _clearPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
  }
}
