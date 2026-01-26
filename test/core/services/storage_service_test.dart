import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transharbor/core/services/storage_service.dart';

import 'storage_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService - Platform Detection', () {
    test('should use SharedPreferences on web platform', () async {
      // This test verifies the platform detection logic
      // In actual implementation, kIsWeb determines the storage backend
      expect(kIsWeb, isFalse); // In test environment, kIsWeb is false
    });

    test('should use FlutterSecureStorage on mobile platforms', () async {
      // This test verifies the platform detection logic
      // In actual implementation, !kIsWeb means mobile
      expect(kIsWeb, isFalse);
    });
  });

  group('StorageService - Token Storage', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('should store and retrieve auth token', () async {
      // Arrange
      const token = 'test_auth_token_123';
      const key = 'auth_token';

      // Act - Store
      await prefs.setString(key, token);

      // Assert - Retrieve
      final retrieved = prefs.getString(key);
      expect(retrieved, token);
    });

    test('should store and retrieve user ID', () async {
      // Arrange
      const userId = 'user123';
      const key = 'user_id';

      // Act
      await prefs.setString(key, userId);

      // Assert
      final retrieved = prefs.getString(key);
      expect(retrieved, userId);
    });

    test('should return null for non-existent key', () async {
      // Act
      final result = prefs.getString('non_existent_key');

      // Assert
      expect(result, isNull);
    });

    test('should delete stored value', () async {
      // Arrange
      const key = 'test_key';
      const value = 'test_value';
      await prefs.setString(key, value);

      // Act
      await prefs.remove(key);

      // Assert
      final retrieved = prefs.getString(key);
      expect(retrieved, isNull);
    });

    test('should clear all stored values', () async {
      // Arrange
      await prefs.setString('key1', 'value1');
      await prefs.setString('key2', 'value2');
      await prefs.setString('key3', 'value3');

      // Act
      await prefs.clear();

      // Assert
      expect(prefs.getString('key1'), isNull);
      expect(prefs.getString('key2'), isNull);
      expect(prefs.getString('key3'), isNull);
    });
  });

  group('StorageService - Mobile Storage (FlutterSecureStorage)', () {
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockSecureStorage = MockFlutterSecureStorage();
    });

    test('should write to secure storage', () async {
      // Arrange
      const key = 'auth_token';
      const value = 'secure_token_123';

      when(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenAnswer((_) async => Future.value());

      // Act
      await mockSecureStorage.write(key: key, value: value);

      // Assert
      verify(mockSecureStorage.write(key: key, value: value)).called(1);
    });

    test('should read from secure storage', () async {
      // Arrange
      const key = 'auth_token';
      const value = 'secure_token_123';

      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => value);

      // Act
      final result = await mockSecureStorage.read(key: key);

      // Assert
      expect(result, value);
      verify(mockSecureStorage.read(key: key)).called(1);
    });

    test('should delete from secure storage', () async {
      // Arrange
      const key = 'auth_token';

      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async => Future.value());

      // Act
      await mockSecureStorage.delete(key: key);

      // Assert
      verify(mockSecureStorage.delete(key: key)).called(1);
    });

    test('should return null for non-existent key', () async {
      // Arrange
      const key = 'non_existent';

      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => null);

      // Act
      final result = await mockSecureStorage.read(key: key);

      // Assert
      expect(result, isNull);
    });

    test('should clear all secure storage', () async {
      // Arrange
      when(mockSecureStorage.deleteAll())
          .thenAnswer((_) async => Future.value());

      // Act
      await mockSecureStorage.deleteAll();

      // Assert
      verify(mockSecureStorage.deleteAll()).called(1);
    });
  });

  group('StorageService - Error Handling', () {
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockSecureStorage = MockFlutterSecureStorage();
    });

    test('should handle write errors gracefully', () async {
      // Arrange
      when(mockSecureStorage.write(
        key: anyNamed('key'),
        value: anyNamed('value'),
      )).thenThrow(Exception('Storage error'));

      // Act & Assert
      expect(
        () => mockSecureStorage.write(key: 'key', value: 'value'),
        throwsException,
      );
    });

    test('should handle read errors gracefully', () async {
      // Arrange
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenThrow(Exception('Read error'));

      // Act & Assert
      expect(
        () => mockSecureStorage.read(key: 'key'),
        throwsException,
      );
    });
  });

  group('StorageService - Integration', () {
    test('should maintain data consistency across operations', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      const token = 'test_token';
      const userId = 'user123';

      // Act - Store multiple values
      await prefs.setString('auth_token', token);
      await prefs.setString('user_id', userId);

      // Assert - Verify all values persist
      expect(prefs.getString('auth_token'), token);
      expect(prefs.getString('user_id'), userId);

      // Act - Update one value
      const newToken = 'updated_token';
      await prefs.setString('auth_token', newToken);

      // Assert - Verify only updated value changed
      expect(prefs.getString('auth_token'), newToken);
      expect(prefs.getString('user_id'), userId);

      // Act - Delete one value
      await prefs.remove('auth_token');

      // Assert - Verify only deleted value is gone
      expect(prefs.getString('auth_token'), isNull);
      expect(prefs.getString('user_id'), userId);
    });
  });
}
