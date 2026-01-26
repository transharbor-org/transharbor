import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/personals/models/personal.dart';

void main() {
  group('Personal Model Tests', () {
    test('creates Personal with all fields', () {
      final now = DateTime.now();
      final personal = Personal(
        id: 'test-123',
        userId: 'user-456',
        content: 'Test content',
        createdAt: now,
        updatedAt: now,
        likesCount: 5,
        commentsCount: 3,
      );

      expect(personal.id, 'test-123');
      expect(personal.userId, 'user-456');
      expect(personal.content, 'Test content');
      expect(personal.createdAt, now);
      expect(personal.updatedAt, now);
      expect(personal.likesCount, 5);
      expect(personal.commentsCount, 3);
    });

    test('creates Personal with required fields only', () {
      final personal = Personal(
        id: 'test-123',
        userId: 'user-456',
        content: 'Test content',
        createdAt: DateTime.now(),
      );

      expect(personal.id, 'test-123');
      expect(personal.userId, 'user-456');
      expect(personal.content, 'Test content');
      expect(personal.updatedAt, isNull);
      expect(personal.likesCount, 0);
      expect(personal.commentsCount, 0);
    });

    test('handles empty content', () {
      final personal = Personal(
        id: 'test-123',
        userId: 'user-456',
        content: '',
        createdAt: DateTime.now(),
      );

      expect(personal.content, '');
    });

    test('handles long content', () {
      final longContent = 'A' * 10000;
      final personal = Personal(
        id: 'test-123',
        userId: 'user-456',
        content: longContent,
        createdAt: DateTime.now(),
      );

      expect(personal.content.length, 10000);
    });

    test('handles special characters in content', () {
      const content = 'Special: 🏳️‍⚧️ 🌈 @#\$%^&*()';
      final personal = Personal(
        id: 'test-123',
        userId: 'user-456',
        content: content,
        createdAt: DateTime.now(),
      );

      expect(personal.content, content);
    });

    test('handles zero likes and comments', () {
      final personal = Personal(
        id: 'test-123',
        userId: 'user-456',
        content: 'Test',
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
      );

      expect(personal.likesCount, 0);
      expect(personal.commentsCount, 0);
    });

    test('handles large like and comment counts', () {
      final personal = Personal(
        id: 'test-123',
        userId: 'user-456',
        content: 'Test',
        createdAt: DateTime.now(),
        likesCount: 999999,
        commentsCount: 888888,
      );

      expect(personal.likesCount, 999999);
      expect(personal.commentsCount, 888888);
    });

    test('updatedAt can be different from createdAt', () {
      final created = DateTime.now();
      final updated = created.add(const Duration(hours: 1));

      final personal = Personal(
        id: 'test-123',
        userId: 'user-456',
        content: 'Test',
        createdAt: created,
        updatedAt: updated,
      );

      expect(personal.createdAt.isBefore(personal.updatedAt!), true);
    });

    test('handles multi-line content', () {
      const content = '''Line 1
Line 2
Line 3''';

      final personal = Personal(
        id: 'test-123',
        userId: 'user-456',
        content: content,
        createdAt: DateTime.now(),
      );

      expect(personal.content, content);
      expect(personal.content.split('\n').length, 3);
    });
  });
}
