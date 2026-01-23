import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/core/services/storage_service.dart';

void main() {
  late StorageService storageService;

  setUp(() {
    storageService = StorageService();
  });

  group('StorageService', () {
    test('stores and retrieves string value', () async {
      const key = 'test_key';
      const value = 'test_value';

      await storageService.saveString(key, value);
      final retrieved = await storageService.getString(key);

      expect(retrieved, value);
    });

    test('stores and retrieves boolean value', () async {
      const key = 'test_bool';
      const value = true;

      await storageService.saveBool(key, value);
      final retrieved = await storageService.getBool(key);

      expect(retrieved, value);
    });

    test('stores and retrieves integer value', () async {
      const key = 'test_int';
      const value = 42;

      await storageService.saveInt(key, value);
      final retrieved = await storageService.getInt(key);

      expect(retrieved, value);
    });

    test('returns null for non-existent key', () async {
      final retrieved = await storageService.getString('non_existent_key');

      expect(retrieved, isNull);
    });

    test('removes value successfully', () async {
      const key = 'test_remove';
      const value = 'to_be_removed';

      await storageService.saveString(key, value);
      await storageService.remove(key);
      final retrieved = await storageService.getString(key);

      expect(retrieved, isNull);
    });

    test('clears all values', () async {
      await storageService.saveString('key1', 'value1');
      await storageService.saveString('key2', 'value2');
      
      await storageService.clear();
      
      final retrieved1 = await storageService.getString('key1');
      final retrieved2 = await storageService.getString('key2');

      expect(retrieved1, isNull);
      expect(retrieved2, isNull);
    });

    test('handles secure storage for token', () async {
      const token = 'secure_auth_token';

      await storageService.saveToken(token);
      final retrieved = await storageService.getToken();

      expect(retrieved, token);
    });

    test('removes token successfully', () async {
      await storageService.saveToken('token_to_remove');
      await storageService.removeToken();
      final retrieved = await storageService.getToken();

      expect(retrieved, isNull);
    });

    test('hasToken returns correct boolean', () async {
      // Initially no token
      expect(await storageService.hasToken(), false);

      // After saving token
      await storageService.saveToken('test_token');
      expect(await storageService.hasToken(), true);

      // After removing token
      await storageService.removeToken();
      expect(await storageService.hasToken(), false);
    });
  });
}
