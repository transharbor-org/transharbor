import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/personals/models/personal.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('Personal Model', () {
    test('creates personal from JSON', () {
      final json = {
        'id': 'personal123',
        'user_id': 'user123',
        'content': 'Test content',
        'likes_count': 10,
        'comments_count': 5,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };

      final personal = Personal.fromJson(json);

      expect(personal.id, 'personal123');
      expect(personal.userId, 'user123');
      expect(personal.content, 'Test content');
      expect(personal.likesCount, 10);
      expect(personal.commentsCount, 5);
    });

    test('converts personal to JSON', () {
      final personal = Personal(
        id: 'personal123',
        userId: 'user123',
        content: 'Test content',
        likesCount: 10,
        commentsCount: 5,
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
      );

      final json = personal.toJson();

      expect(json['id'], 'personal123');
      expect(json['user_id'], 'user123');
      expect(json['content'], 'Test content');
      expect(json['likes_count'], 10);
      expect(json['comments_count'], 5);
    });

    test('creates personal from PocketBase record', () {
      // Skip this test - would require mocking PocketBase RecordModel
    }, skip: true);

    test('handles nullable fields', () {
      final json = {
        'id': 'personal123',
        'user_id': 'user123',
        'content': 'Test content',
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final personal = Personal.fromJson(json);

      expect(personal.likesCount, 0);
      expect(personal.commentsCount, 0);
    });
  });
}
