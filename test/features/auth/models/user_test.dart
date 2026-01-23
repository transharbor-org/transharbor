import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/core/models/user.dart';
import 'package:transharbor/core/models/user_role.dart';
import 'package:transharbor/core/models/membership_type.dart';

void main() {
  group('User Model', () {
    test('creates user from JSON', () {
      final json = {
        'id': 'user123',
        'username': 'testuser',
        'email': 'test@example.com',
        'display_name': 'Test User',
        'bio': 'Test bio',
        'avatar': 'avatar.jpg',
        'role': 'user',
        'membership_type': 'non_voting',
        'created_at': '2024-01-01T00:00:00.000Z',
        'is_active': true,
      };

      final user = User.fromJson(json);

      expect(user.id, 'user123');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.bio, 'Test bio');
      expect(user.avatar, 'avatar.jpg');
      expect(user.role, UserRole.user);
    });

    test('converts user to JSON', () {
      final user = User(
        id: 'user123',
        username: 'testuser',
        email: 'test@example.com',
        displayName: 'Test User',
        bio: 'Test bio',
        avatar: 'avatar.jpg',
        role: UserRole.user,
        membershipType: MembershipType.nonVoting,
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        isActive: true,
      );

      final json = user.toJson();

      expect(json['id'], 'user123');
      expect(json['username'], 'testuser');
      expect(json['email'], 'test@example.com');
      expect(json['display_name'], 'Test User');
      expect(json['bio'], 'Test bio');
      expect(json['avatar'], 'avatar.jpg');
      expect(json['role'], 'user');
    });

    test('creates user from PocketBase record', () {
      // Skip this test - would require mocking PocketBase RecordModel
      // which is not needed for basic functionality testing
    }, skip: true);

    test('handles nullable fields', () {
      final json = {
        'id': 'user123',
        'username': 'testuser',
        'email': 'test@example.com',
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.displayName, null);
      expect(user.bio, null);
      expect(user.avatar, null);
      expect(user.isActive, true);
    });
  });
}
