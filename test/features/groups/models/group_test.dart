import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/groups/models/group.dart';

void main() {
  group('Group Model', () {
    final now = DateTime.now();

    test('creates group with required fields', () {
      final group = Group(
        id: '123',
        name: 'Test Group',
        description: 'A test group',
        creatorId: 'user123',
        createdAt: now,
      );

      expect(group.id, '123');
      expect(group.name, 'Test Group');
      expect(group.description, 'A test group');
      expect(group.creatorId, 'user123');
      expect(group.isPrivate, false);
      expect(group.memberCount, 0);
      expect(group.category, null);
      expect(group.bannerUrl, null);
    });

    test('creates group with all fields', () {
      final group = Group(
        id: '123',
        name: 'Test Group',
        description: 'A test group',
        creatorId: 'user123',
        category: 'community',
        isPrivate: true,
        memberCount: 42,
        bannerUrl: 'https://example.com/banner.jpg',
        createdAt: now,
      );

      expect(group.category, 'community');
      expect(group.isPrivate, true);
      expect(group.memberCount, 42);
      expect(group.bannerUrl, 'https://example.com/banner.jpg');
    });

    test('fromJson creates group correctly', () {
      final json = {
        'id': '123',
        'name': 'Test Group',
        'description': 'A test group',
        'creator': 'user123',
        'category': 'community',
        'isPrivate': true,
        'memberCount': 42,
        'bannerUrl': 'https://example.com/banner.jpg',
        'created': now.toIso8601String(),
      };

      final group = Group.fromJson(json);

      expect(group.id, '123');
      expect(group.name, 'Test Group');
      expect(group.description, 'A test group');
      expect(group.creatorId, 'user123');
      expect(group.category, 'community');
      expect(group.isPrivate, true);
      expect(group.memberCount, 42);
    });

    test('fromJson handles optional fields', () {
      final json = {
        'id': '123',
        'name': 'Test Group',
        'description': 'A test group',
        'creator': 'user123',
        'created': now.toIso8601String(),
      };

      final group = Group.fromJson(json);

      expect(group.category, null);
      expect(group.isPrivate, false);
      expect(group.memberCount, 0);
      expect(group.bannerUrl, null);
    });

    test('toJson serializes group correctly', () {
      final group = Group(
        id: '123',
        name: 'Test Group',
        description: 'A test group',
        creatorId: 'user123',
        category: 'community',
        isPrivate: true,
        memberCount: 42,
        bannerUrl: 'https://example.com/banner.jpg',
        createdAt: now,
      );

      final json = group.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Test Group');
      expect(json['creator'], 'user123');
      expect(json['category'], 'community');
      expect(json['isPrivate'], true);
      expect(json['memberCount'], 42);
    });
  });

  group('GroupRole Enum', () {
    test('has all expected values', () {
      expect(GroupRole.values.length, 3);
      expect(GroupRole.values.contains(GroupRole.admin), true);
      expect(GroupRole.values.contains(GroupRole.moderator), true);
      expect(GroupRole.values.contains(GroupRole.member), true);
    });

    test('name property returns correct string', () {
      expect(GroupRole.admin.name, 'admin');
      expect(GroupRole.moderator.name, 'moderator');
      expect(GroupRole.member.name, 'member');
    });
  });

  group('GroupMember Model', () {
    final now = DateTime.now();

    test('creates group member correctly', () {
      final member = GroupMember(
        id: '123',
        groupId: 'group123',
        userId: 'user123',
        role: GroupRole.member,
        joinedAt: now,
      );

      expect(member.id, '123');
      expect(member.groupId, 'group123');
      expect(member.userId, 'user123');
      expect(member.role, GroupRole.member);
      expect(member.joinedAt, now);
    });

    test('supports different roles', () {
      final admin = GroupMember(
        id: '1',
        groupId: 'group123',
        userId: 'user1',
        role: GroupRole.admin,
        joinedAt: now,
      );

      final moderator = GroupMember(
        id: '2',
        groupId: 'group123',
        userId: 'user2',
        role: GroupRole.moderator,
        joinedAt: now,
      );

      expect(admin.role, GroupRole.admin);
      expect(moderator.role, GroupRole.moderator);
    });
  });
}
