import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/core/services/encryption_service.dart';

void main() {
  group('EncryptionService Tests', () {
    late EncryptionService encryptionService;

    setUp(() async {
      encryptionService = EncryptionService();
      // Initialize with a test key
      await encryptionService.initialize(
        providedKey: 'test-encryption-key-32chars!',
      );
    });

    test('encrypts and decrypts text correctly', () {
      const plaintext = 'This is a test message';

      final encrypted = encryptionService.encrypt(plaintext);
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(plaintext));

      final decrypted = encryptionService.decrypt(encrypted);
      expect(decrypted, plaintext);
    });

    test('encrypted text contains IV separator', () {
      const plaintext = 'Test';
      final encrypted = encryptionService.encrypt(plaintext);

      // Format is: IV:ciphertext (both base64)
      expect(encrypted.contains(':'), true);
    });

    test('isEncrypted detects encrypted format', () {
      const plaintext = 'This is not encrypted';
      final encrypted = encryptionService.encrypt(plaintext);

      expect(encryptionService.isEncrypted(encrypted), true);
      expect(encryptionService.isEncrypted(plaintext), false);
    });

    test('encrypts same text differently each time (unique IVs)', () {
      const plaintext = 'Same text';

      final encrypted1 = encryptionService.encrypt(plaintext);
      final encrypted2 = encryptionService.encrypt(plaintext);

      expect(encrypted1, isNot(encrypted2));

      // Both should decrypt to same plaintext
      expect(encryptionService.decrypt(encrypted1), plaintext);
      expect(encryptionService.decrypt(encrypted2), plaintext);
    });

    test('handles empty string', () {
      const plaintext = '';

      final encrypted = encryptionService.encrypt(plaintext);
      final decrypted = encryptionService.decrypt(encrypted);

      expect(decrypted, plaintext);
    });

    test('handles long text', () {
      final plaintext = 'A' * 10000;

      final encrypted = encryptionService.encrypt(plaintext);
      final decrypted = encryptionService.decrypt(encrypted);

      expect(decrypted, plaintext);
    });

    test('handles special characters', () {
      const plaintext =
          'Special chars: 🏳️‍⚧️ 🌈 @#\$%^&*()_+-=[]{}|;:,.<>?/~`';

      final encrypted = encryptionService.encrypt(plaintext);
      final decrypted = encryptionService.decrypt(encrypted);

      expect(decrypted, plaintext);
    });

    test('handles multi-line text', () {
      const plaintext = '''Line 1
Line 2
Line 3''';

      final encrypted = encryptionService.encrypt(plaintext);
      final decrypted = encryptionService.decrypt(encrypted);

      expect(decrypted, plaintext);
    });

    test('decryption throws on invalid format', () {
      const invalidEncrypted = 'not-a-valid-encrypted-string';

      expect(
        () => encryptionService.decrypt(invalidEncrypted),
        throwsException,
      );
    });

    test('isEncrypted returns false for plaintext', () {
      expect(encryptionService.isEncrypted('hello'), false);
      expect(encryptionService.isEncrypted('no-colon-base64'), false);
      expect(encryptionService.isEncrypted(''), false);
    });
  });
}
