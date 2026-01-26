import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Server-side encryption service for sensitive user data
/// Uses AES-256-GCM with platform key for encryption at rest
/// Moderators can decrypt via admin API with audit logging
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _secureStorage = const FlutterSecureStorage();
  Encrypter? _encrypter;

  static const String _keyStorageKey = 'platform_encryption_key';
  static const String _ivStorageKey = 'platform_encryption_iv';

  /// Initialize encryption service with platform key
  /// Key should be provided via environment variable in production
  Future<void> initialize({String? providedKey}) async {
    try {
      // Try to get existing key from secure storage
      String? keyBase64 = await _secureStorage.read(key: _keyStorageKey);

      if (keyBase64 == null) {
        // Generate or use provided key
        final Key key;
        if (providedKey != null && providedKey.length == 32) {
          key = Key.fromUtf8(providedKey);
        } else {
          // Generate random key (32 bytes for AES-256)
          key = Key.fromSecureRandom(32);
        }

        // Store for future use
        keyBase64 = base64.encode(key.bytes);
        await _secureStorage.write(key: _keyStorageKey, value: keyBase64);
      }

      final keyBytes = base64.decode(keyBase64);
      final key = Key(Uint8List.fromList(keyBytes));

      _encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    } catch (e) {
      throw Exception('Failed to initialize encryption: $e');
    }
  }

  /// Encrypt text data
  /// Returns base64-encoded encrypted data with IV prepended
  String encrypt(String plaintext) {
    if (_encrypter == null) {
      throw Exception('Encryption service not initialized');
    }

    if (plaintext.isEmpty) {
      return '';
    }

    // Generate random IV for each encryption (GCM mode)
    final iv = IV.fromSecureRandom(16);

    // Encrypt
    final encrypted = _encrypter!.encrypt(plaintext, iv: iv);

    // Prepend IV to encrypted data (needed for decryption)
    final ivAndEncrypted = iv.base64 + ':' + encrypted.base64;

    return ivAndEncrypted;
  }

  /// Decrypt text data
  /// Expects base64-encoded encrypted data with IV prepended
  String decrypt(String encryptedData) {
    if (_encrypter == null) {
      throw Exception('Encryption service not initialized');
    }

    if (encryptedData.isEmpty) {
      return '';
    }

    try {
      // Split IV and encrypted data
      final parts = encryptedData.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid encrypted data format');
      }

      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);

      // Decrypt
      return _encrypter!.decrypt(encrypted, iv: iv);
    } catch (e) {
      // If decryption fails, might be unencrypted legacy data
      // Return as-is (migration scenario)
      return encryptedData;
    }
  }

  /// Check if data appears to be encrypted
  bool isEncrypted(String data) {
    // Encrypted data has format: base64:base64
    return data.contains(':') &&
        data.split(':').length == 2 &&
        data.split(':').every((part) => _isBase64(part));
  }

  bool _isBase64(String str) {
    try {
      base64.decode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Clear encryption keys (logout)
  Future<void> clearKeys() async {
    await _secureStorage.delete(key: _keyStorageKey);
    await _secureStorage.delete(key: _ivStorageKey);
    _encrypter = null;
  }
}
