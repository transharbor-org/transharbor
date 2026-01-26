import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/core/models/user_role.dart';

void main() {
  group('UserRole Enum', () {
    test('has all expected values', () {
      expect(UserRole.values.length, 3);
      expect(UserRole.values.contains(UserRole.user), true);
      expect(UserRole.values.contains(UserRole.moderator), true);
      expect(UserRole.values.contains(UserRole.admin), true);
    });

    test('canModerate returns true for moderators', () {
      expect(UserRole.moderator.canModerate, true);
    });

    test('canModerate returns true for admins', () {
      expect(UserRole.admin.canModerate, true);
    });

    test('canModerate returns false for regular users', () {
      expect(UserRole.user.canModerate, false);
    });

    test('isAdmin returns true only for admin role', () {
      expect(UserRole.admin.isAdmin, true);
      expect(UserRole.moderator.isAdmin, false);
      expect(UserRole.user.isAdmin, false);
    });

    test('isPrivileged returns true for moderators and admins', () {
      expect(UserRole.admin.isPrivileged, true);
      expect(UserRole.moderator.isPrivileged, true);
      expect(UserRole.user.isPrivileged, false);
    });

    test('fromString parses admin correctly', () {
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('Admin'), UserRole.admin);
      expect(UserRole.fromString('ADMIN'), UserRole.admin);
    });

    test('fromString parses moderator correctly', () {
      expect(UserRole.fromString('moderator'), UserRole.moderator);
      expect(UserRole.fromString('Moderator'), UserRole.moderator);
      expect(UserRole.fromString('MODERATOR'), UserRole.moderator);
    });

    test('fromString parses user correctly', () {
      expect(UserRole.fromString('user'), UserRole.user);
      expect(UserRole.fromString('User'), UserRole.user);
      expect(UserRole.fromString('USER'), UserRole.user);
    });

    test('fromString defaults to user for unknown values', () {
      expect(UserRole.fromString('unknown'), UserRole.user);
      expect(UserRole.fromString(''), UserRole.user);
      expect(UserRole.fromString('invalid'), UserRole.user);
    });

    test('toApiString returns correct string', () {
      expect(UserRole.admin.toApiString(), 'admin');
      expect(UserRole.moderator.toApiString(), 'moderator');
      expect(UserRole.user.toApiString(), 'user');
    });

    test('name property returns correct string', () {
      expect(UserRole.admin.name, 'admin');
      expect(UserRole.moderator.name, 'moderator');
      expect(UserRole.user.name, 'user');
    });
  });
}
