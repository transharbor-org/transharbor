import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/groups/providers/groups_provider.dart';
import 'package:transharbor/features/groups/models/group.dart';

void main() {
  late GroupsProvider groupsProvider;

  setUp(() {
    groupsProvider = GroupsProvider();
  });

  group('GroupsProvider', () {
    test('initial state is correct', () {
      expect(groupsProvider.allGroups, isEmpty);
      expect(groupsProvider.myGroups, isEmpty);
      expect(groupsProvider.groupMembers, isEmpty);
      expect(groupsProvider.groupPosts, isEmpty);
      expect(groupsProvider.isLoading, false);
      expect(groupsProvider.errorMessage, isNull);
    });

    test('setLoading updates loading state', () {
      groupsProvider.setLoading(true);
      expect(groupsProvider.isLoading, true);

      groupsProvider.setLoading(false);
      expect(groupsProvider.isLoading, false);
    });

    test('setAllGroups updates all groups list', () {
      final groupsList = [
        Group(
          id: '1',
          name: 'Test Group',
          description: 'Description',
          category: 'social',
          creatorId: 'user1',
          memberCount: 10,
          isPrivate: false,
          created: DateTime.now(),
          updated: DateTime.now(),
        ),
      ];

      groupsProvider.setAllGroups(groupsList);

      expect(groupsProvider.allGroups, groupsList);
      expect(groupsProvider.allGroups.length, 1);
    });

    test('setMyGroups updates my groups list', () {
      final groupsList = [
        Group(
          id: '1',
          name: 'My Group',
          description: 'Description',
          category: 'hobbies',
          creatorId: 'user1',
          memberCount: 5,
          isPrivate: true,
          created: DateTime.now(),
          updated: DateTime.now(),
        ),
      ];

      groupsProvider.setMyGroups(groupsList);

      expect(groupsProvider.myGroups, groupsList);
      expect(groupsProvider.myGroups.length, 1);
    });

    test('addGroup adds group to all groups', () {
      final group = Group(
        id: '1',
        name: 'New Group',
        description: 'Description',
        category: 'support',
        creatorId: 'user1',
        memberCount: 1,
        isPrivate: false,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      groupsProvider.addGroup(group);

      expect(groupsProvider.allGroups.length, 1);
      expect(groupsProvider.allGroups.first.id, '1');
    });

    test('updateGroup updates existing group', () {
      final group = Group(
        id: '1',
        name: 'Original Name',
        description: 'Description',
        category: 'social',
        creatorId: 'user1',
        memberCount: 5,
        isPrivate: false,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      groupsProvider.setAllGroups([group]);

      final updated = Group(
        id: '1',
        name: 'Updated Name',
        description: 'Updated Description',
        category: 'social',
        creatorId: 'user1',
        memberCount: 10,
        isPrivate: false,
        created: group.created,
        updated: DateTime.now(),
      );

      groupsProvider.updateGroup(updated);

      expect(groupsProvider.allGroups.first.name, 'Updated Name');
      expect(groupsProvider.allGroups.first.memberCount, 10);
    });

    test('addToMyGroups adds group to my groups', () {
      final group = Group(
        id: '1',
        name: 'Joined Group',
        description: 'Description',
        category: 'social',
        creatorId: 'user2',
        memberCount: 10,
        isPrivate: false,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      groupsProvider.addToMyGroups(group);

      expect(groupsProvider.myGroups.length, 1);
      expect(groupsProvider.myGroups.first.id, '1');
    });

    test('removeFromMyGroups removes group from my groups', () {
      final group1 = Group(
        id: '1',
        name: 'Group 1',
        description: 'Description',
        category: 'social',
        creatorId: 'user1',
        memberCount: 10,
        isPrivate: false,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      final group2 = Group(
        id: '2',
        name: 'Group 2',
        description: 'Description',
        category: 'hobbies',
        creatorId: 'user1',
        memberCount: 5,
        isPrivate: false,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      groupsProvider.setMyGroups([group1, group2]);
      groupsProvider.removeFromMyGroups('1');

      expect(groupsProvider.myGroups.length, 1);
      expect(groupsProvider.myGroups.first.id, '2');
    });

    test('setGroupMembers updates group members list', () {
      final members = [
        GroupMember(
          id: '1',
          groupId: 'group1',
          userId: 'user1',
          role: 'admin',
          created: DateTime.now(),
          updated: DateTime.now(),
        ),
      ];

      groupsProvider.setGroupMembers(members);

      expect(groupsProvider.groupMembers, members);
      expect(groupsProvider.groupMembers.length, 1);
    });

    test('setGroupPosts updates group posts list', () {
      final posts = [
        GroupPost(
          id: '1',
          groupId: 'group1',
          authorId: 'user1',
          content: 'Test post',
          likes: 5,
          created: DateTime.now(),
          updated: DateTime.now(),
        ),
      ];

      groupsProvider.setGroupPosts(posts);

      expect(groupsProvider.groupPosts, posts);
      expect(groupsProvider.groupPosts.length, 1);
    });

    test('addGroupPost adds post to list', () {
      final existing = GroupPost(
        id: '1',
        groupId: 'group1',
        authorId: 'user1',
        content: 'First post',
        likes: 0,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      groupsProvider.setGroupPosts([existing]);

      final newPost = GroupPost(
        id: '2',
        groupId: 'group1',
        authorId: 'user2',
        content: 'Second post',
        likes: 0,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      groupsProvider.addGroupPost(newPost);

      expect(groupsProvider.groupPosts.length, 2);
      expect(groupsProvider.groupPosts.first.id, '2');
    });

    test('filterGroupsByCategory returns correct groups', () {
      final group1 = Group(
        id: '1',
        name: 'Social Group',
        description: 'Description',
        category: 'social',
        creatorId: 'user1',
        memberCount: 10,
        isPrivate: false,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      final group2 = Group(
        id: '2',
        name: 'Hobby Group',
        description: 'Description',
        category: 'hobbies',
        creatorId: 'user1',
        memberCount: 5,
        isPrivate: false,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      groupsProvider.setAllGroups([group1, group2]);

      final filtered = groupsProvider.allGroups
          .where((g) => g.category == 'social')
          .toList();

      expect(filtered.length, 1);
      expect(filtered.first.category, 'social');
    });
  });
}
