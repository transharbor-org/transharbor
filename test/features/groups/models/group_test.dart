import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/groups/models/group.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('Group Model', () {
    test('creates group from JSON', () {
      final json = {
        'id': 'group123',
        'name': 'Test Group',
        'description': 'A test group',
        'category': 'social',
        'creator': 'user123',
        'members': 10,
        'isPrivate': false,
        'created': '2024-01-01T00:00:00.000Z',
        'updated': '2024-01-02T00:00:00.000Z',
      };

      final group = Group.fromJson(json);

      expect(group.id, 'group123');
      expect(group.name, 'Test Group');
      expect(group.description, 'A test group');
      expect(group.category, 'social');
      expect(group.creatorId, 'user123');
      expect(group.memberCount, 10);
      expect(group.isPrivate, false);
    });

    test('converts group to JSON', () {
      final group = Group(
        id: 'group123',
        name: 'Test Group',
        description: 'A test group',
        category: 'social',
        creatorId: 'user123',
        memberCount: 10,
        isPrivate: false,
        created: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updated: DateTime.parse('2024-01-02T00:00:00.000Z'),
      );

      final json = group.toJson();

      expect(json['id'], 'group123');
      expect(json['name'], 'Test Group');
      expect(json['category'], 'social');
      expect(json['members'], 10);
    });

    test('creates group from PocketBase record', () {
      final record = MockRecordModel(
        id: 'group123',
        collectionId: 'col123',
        collectionName: 'groups',
        data: {
          'name': 'Test Group',
          'description': 'Description',
          'category': 'hobbies',
          'creator': 'user123',
          'members': 5,
          'isPrivate': true,
        },
      );

      final group = Group.fromPocketBase(record);

      expect(group.id, 'group123');
      expect(group.name, 'Test Group');
      expect(group.category, 'hobbies');
      expect(group.isPrivate, true);
    });
  });

  group('GroupMember Model', () {
    test('creates group member from JSON', () {
      final json = {
        'id': 'member123',
        'group': 'group123',
        'user': 'user123',
        'role': 'member',
        'created': '2024-01-01T00:00:00.000Z',
        'updated': '2024-01-02T00:00:00.000Z',
      };

      final member = GroupMember.fromJson(json);

      expect(member.id, 'member123');
      expect(member.groupId, 'group123');
      expect(member.userId, 'user123');
      expect(member.role, 'member');
    });

    test('creates group member from PocketBase record', () {
      final record = MockRecordModel(
        id: 'member123',
        collectionId: 'col123',
        collectionName: 'group_members',
        data: {
          'group': 'group123',
          'user': 'user123',
          'role': 'admin',
        },
      );

      final member = GroupMember.fromPocketBase(record);

      expect(member.id, 'member123');
      expect(member.role, 'admin');
    });

    test('handles different member roles', () {
      final admin = GroupMember(
        id: '1',
        groupId: 'group1',
        userId: 'user1',
        role: 'admin',
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      final member = GroupMember(
        id: '2',
        groupId: 'group1',
        userId: 'user2',
        role: 'member',
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      expect(admin.role, 'admin');
      expect(member.role, 'member');
    });
  });

  group('GroupPost Model', () {
    test('creates group post from JSON', () {
      final json = {
        'id': 'post123',
        'group': 'group123',
        'author': 'user123',
        'content': 'Test post content',
        'likes': 5,
        'created': '2024-01-01T00:00:00.000Z',
        'updated': '2024-01-02T00:00:00.000Z',
      };

      final post = GroupPost.fromJson(json);

      expect(post.id, 'post123');
      expect(post.groupId, 'group123');
      expect(post.authorId, 'user123');
      expect(post.content, 'Test post content');
      expect(post.likes, 5);
    });

    test('creates group post from PocketBase record', () {
      final record = MockRecordModel(
        id: 'post123',
        collectionId: 'col123',
        collectionName: 'group_posts',
        data: {
          'group': 'group123',
          'author': 'user123',
          'content': 'Hello group!',
          'likes': 10,
        },
      );

      final post = GroupPost.fromPocketBase(record);

      expect(post.id, 'post123');
      expect(post.content, 'Hello group!');
      expect(post.likes, 10);
    });

    test('handles zero likes', () {
      final json = {
        'id': 'post123',
        'group': 'group123',
        'author': 'user123',
        'content': 'New post',
        'likes': 0,
        'created': '2024-01-01T00:00:00.000Z',
        'updated': '2024-01-02T00:00:00.000Z',
      };

      final post = GroupPost.fromJson(json);

      expect(post.likes, 0);
    });
  });
}
