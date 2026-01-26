import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'transharbor_storage',
      publicKey: 'transharbor_public_key',
    ),
  );

  // Keys
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserModel = 'user_model';

  // Helper to use SharedPreferences on web, SecureStorage on mobile
  static Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  static Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      return await _storage.read(key: key);
    }
  }

  static Future<void> _delete(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      await _storage.delete(key: key);
    }
  }

  // Auth Token
  static Future<void> saveAuthToken(String token) async {
    await _write(_keyAuthToken, token);
  }

  static Future<String?> getAuthToken() async {
    return await _read(_keyAuthToken);
  }

  // Refresh Token
  static Future<void> saveRefreshToken(String token) async {
    await _write(_keyRefreshToken, token);
  }

  static Future<String?> getRefreshToken() async {
    return await _read(_keyRefreshToken);
  }

  // User ID
  static Future<void> saveUserId(String userId) async {
    await _write(_keyUserId, userId);
  }

  static Future<String?> getUserId() async {
    return await _read(_keyUserId);
  }

  // User Model (stored as JSON string)
  static Future<void> saveUserModel(String modelJson) async {
    await _write(_keyUserModel, modelJson);
  }

  static Future<String?> getUserModel() async {
    return await _read(_keyUserModel);
  }

  // Clear All
  static Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAuthToken);
      await prefs.remove(_keyRefreshToken);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserModel);
    } else {
      await _storage.deleteAll();
    }
  }
}
