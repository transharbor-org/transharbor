import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/core/models/user.dart';
import 'package:transharbor/core/models/user_role.dart';
import 'package:transharbor/core/models/membership_type.dart';

void main() {
  group('User Model', () {
    final now = DateTime.now();

    test('creates user with required fields', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        createdAt: now,
      );

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.role, UserRole.user);
      expect(user.membershipType, MembershipType.nonVoting);
      expect(user.isActive, true);
      expect(user.username, null);
      expect(user.displayName, null);
    });

    test('creates user with all fields', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        username: 'testuser',
        displayName: 'Test User',
        bio: 'A test bio',
        pronouns: 'they/them',
        avatar: 'https://example.com/avatar.jpg',
        role: UserRole.moderator,
        membershipType: MembershipType.votingMember,
        createdAt: now,
        isActive: true,
      );

      expect(user.username, 'testuser');
      expect(user.displayName, 'Test User');
      expect(user.bio, 'A test bio');
      expect(user.pronouns, 'they/them');
      expect(user.avatar, 'https://example.com/avatar.jpg');
      expect(user.role, UserRole.moderator);
      expect(user.membershipType, MembershipType.votingMember);
    });

    test('canModerate returns true for moderators', () {
      final moderator = User(
        id: '123',
        email: 'mod@example.com',
        role: UserRole.moderator,
        createdAt: now,
      );

      expect(moderator.canModerate, true);
    });

    test('canModerate returns true for admins', () {
      final admin = User(
        id: '123',
        email: 'admin@example.com',
        role: UserRole.admin,
        createdAt: now,
      );

      expect(admin.canModerate, true);
    });

    test('canModerate returns false for regular users', () {
      final user = User(
        id: '123',
        email: 'user@example.com',
        role: UserRole.user,
        createdAt: now,
      );

      expect(user.canModerate, false);
    });

    test('isAdmin returns true only for admins', () {
      final admin = User(
        id: '1',
        email: 'admin@example.com',
        role: UserRole.admin,
        createdAt: now,
      );

      final moderator = User(
        id: '2',
        email: 'mod@example.com',
        role: UserRole.moderator,
        createdAt: now,
      );

      final user = User(
        id: '3',
        email: 'user@example.com',
        role: UserRole.user,
        createdAt: now,
      );

      expect(admin.isAdmin, true);
      expect(moderator.isAdmin, false);
      expect(user.isAdmin, false);
    });

    test('isPrivileged returns true for moderators and admins', () {
      final admin = User(
        id: '1',
        email: 'admin@example.com',
        role: UserRole.admin,
        createdAt: now,
      );

      final moderator = User(
        id: '2',
        email: 'mod@example.com',
        role: UserRole.moderator,
        createdAt: now,
      );

      final user = User(
        id: '3',
        email: 'user@example.com',
        role: UserRole.user,
        createdAt: now,
      );

      expect(admin.isPrivileged, true);
      expect(moderator.isPrivileged, true);
      expect(user.isPrivileged, false);
    });

    test('canVote returns true for voting members', () {
      final votingMember = User(
        id: '123',
        email: 'voter@example.com',
        membershipType: MembershipType.votingMember,
        createdAt: now,
      );

      expect(votingMember.canVote, true);
    });

    test('canVote returns false for non-voting members', () {
      final nonVoting = User(
        id: '123',
        email: 'nonvoter@example.com',
        membershipType: MembershipType.nonVoting,
        createdAt: now,
      );

      expect(nonVoting.canVote, false);
    });

    test('isFullMember returns true for voting members', () {
      final votingMember = User(
        id: '123',
        email: 'voter@example.com',
        membershipType: MembershipType.votingMember,
        createdAt: now,
      );

      expect(votingMember.isFullMember, true);
    });

    test('fromJson creates user correctly', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'username': 'testuser',
        'name': 'Test User',
        'bio': 'A test bio',
        'pronouns': 'they/them',
        'avatar': 'https://example.com/avatar.jpg',
        'role': 'moderator',
        'membershipType': 'voting_member',
        'created': now.toIso8601String(),
        'isActive': true,
      };

      final user = User.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.username, 'testuser');
      expect(user.displayName, 'Test User');
      expect(user.role, UserRole.moderator);
      expect(user.membershipType, MembershipType.votingMember);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'created': now.toIso8601String(),
      };

      final user = User.fromJson(json);

      expect(user.role, UserRole.user);
      expect(user.membershipType, MembershipType.nonVoting);
      expect(user.isActive, true);
    });
  });
}
