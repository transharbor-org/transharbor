import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/groups/providers/groups_provider.dart';
import 'package:transharbor/features/groups/models/group.dart';

void main() {
  group('GroupsProvider Tests', () {
    test('initializes with empty state',
        skip:
            'Requires platform plugin (flutter_secure_storage) not available in unit tests',
        () {
      final groupsProvider = GroupsProvider();

      expect(groupsProvider.groups, isEmpty);
      expect(groupsProvider.myGroups, isEmpty);
      expect(groupsProvider.isLoading, false);
      expect(groupsProvider.errorMessage, isNull);
    });

    test('has correct initial values',
        skip:
            'Requires platform plugin (flutter_secure_storage) not available in unit tests',
        () {
      final groupsProvider = GroupsProvider();

      expect(groupsProvider.groups, isA<List<Group>>());
      expect(groupsProvider.myGroups, isA<List<Group>>());
      expect(groupsProvider.isLoading, isA<bool>());
      expect(groupsProvider.errorMessage, isNull);
    });

    test('getGroupPosts returns empty list for non-existent group',
        skip:
            'Requires platform plugin (flutter_secure_storage) not available in unit tests',
        () {
      final groupsProvider = GroupsProvider();
      expect(groupsProvider.getGroupPosts('nonexistent'), isEmpty);
    });

    test('getGroupMembers returns empty list for non-existent group',
        skip:
            'Requires platform plugin (flutter_secure_storage) not available in unit tests',
        () {
      final groupsProvider = GroupsProvider();
      expect(groupsProvider.getGroupMembers('nonexistent'), isEmpty);
    });

    test('getMyMembership returns null for non-existent group',
        skip:
            'Requires platform plugin (flutter_secure_storage) not available in unit tests',
        () {
      final groupsProvider = GroupsProvider();
      expect(groupsProvider.getMyMembership('nonexistent'), isNull);
    });

    test('isMember returns false for non-existent group',
        skip:
            'Requires platform plugin (flutter_secure_storage) not available in unit tests',
        () {
      final groupsProvider = GroupsProvider();
      expect(groupsProvider.isMember('nonexistent'), false);
    });

    test('isAdmin returns false for non-existent group',
        skip:
            'Requires platform plugin (flutter_secure_storage) not available in unit tests',
        () {
      final groupsProvider = GroupsProvider();
      expect(groupsProvider.isAdmin('nonexistent'), false);
    });

    test('getters return correct types',
        skip:
            'Requires platform plugin (flutter_secure_storage) not available in unit tests',
        () {
      final groupsProvider = GroupsProvider();

      expect(groupsProvider.groups, isA<List<Group>>());
      expect(groupsProvider.myGroups, isA<List<Group>>());
      expect(groupsProvider.isLoading, false);
    });
  });

  group('GroupRole Enum Tests', () {
    test('has all required roles', () {
      expect(GroupRole.member.name, 'member');
      expect(GroupRole.admin.name, 'admin');
      expect(GroupRole.moderator.name, 'moderator');
    });

    test('enum values exist', () {
      expect(GroupRole.values.contains(GroupRole.member), isTrue);
      expect(GroupRole.values.contains(GroupRole.admin), isTrue);
      expect(GroupRole.values.contains(GroupRole.moderator), isTrue);
    });
  });
}
