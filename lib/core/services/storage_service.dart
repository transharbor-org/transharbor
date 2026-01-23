import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  
  // Keys
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  
  // Auth Token
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }
  
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAuthToken);
  }
  
  // Refresh Token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }
  
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }
  
  // User ID
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }
  
  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }
  
  // Clear All
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
