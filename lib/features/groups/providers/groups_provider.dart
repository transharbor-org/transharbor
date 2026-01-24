import 'package:flutter/material.dart';
import '../../../core/services/pocketbase_service.dart';
import '../models/group.dart';

class GroupsProvider extends ChangeNotifier {
  final _pb = PocketBaseService();
  List<Group> _groups = [];
  List<Group> _myGroups = [];
  Map<String, List<GroupPost>> _groupPosts = {};
  Map<String, List<GroupMember>> _groupMembers = {};
  Map<String, GroupMember?> _myMemberships = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<Group> get groups => _groups;
  List<Group> get myGroups => _myGroups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<GroupPost> getGroupPosts(String groupId) {
    return _groupPosts[groupId] ?? [];
  }

  List<GroupMember> getGroupMembers(String groupId) {
    return _groupMembers[groupId] ?? [];
  }

  GroupMember? getMyMembership(String groupId) {
    return _myMemberships[groupId];
  }

  bool isMember(String groupId) {
    return _myMemberships[groupId] != null;
  }

  bool isAdmin(String groupId) {
    final membership = _myMemberships[groupId];
    return membership?.role == GroupRole.admin;
  }

  Future<void> loadGroups({String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _pb.getGroups(category: category);
      _groups =
          result.items.map((record) => Group.fromPocketBase(record)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyGroups() async {
    try {
      final result = await _pb.getUserGroups();
      _myGroups = result.items
          .where((record) => record.expand?['group'] != null)
          .map((record) {
            final groupExpandData = record.expand?['group'];
            if (groupExpandData != null &&
                groupExpandData is List &&
                groupExpandData.isNotEmpty) {
              final groupData = groupExpandData.first;
              return Group.fromPocketBase(groupData);
            }
            return null;
          })
          .where((group) => group != null)
          .cast<Group>()
          .toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<Group?> loadGroup(String groupId) async {
    try {
      final record = await _pb.getGroup(groupId);
      final group = Group.fromPocketBase(record);

      // Update in lists if exists
      final index = _groups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        _groups[index] = group;
      }

      notifyListeners();
      return group;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  Future<bool> createGroup({
    required String name,
    required String description,
    String? category,
    bool isPrivate = false,
  }) async {
    try {
      final record = await _pb.createGroup(
        name: name,
        description: description,
        category: category,
        isPrivate: isPrivate,
      );
      final newGroup = Group.fromPocketBase(record);
      _groups.insert(0, newGroup);
      _myGroups.insert(0, newGroup);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> joinGroup(String groupId) async {
    try {
      final membership = await _pb.joinGroup(groupId);
      _myMemberships[groupId] = GroupMember.fromPocketBase(membership);

      // Update member count in local group
      final index = _groups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        final group = _groups[index];
        _groups[index] = Group(
          id: group.id,
          name: group.name,
          description: group.description,
          creatorId: group.creatorId,
          category: group.category,
          isPrivate: group.isPrivate,
          memberCount: group.memberCount + 1,
          bannerUrl: group.bannerUrl,
          createdAt: group.createdAt,
        );
      }

      await loadMyGroups();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> leaveGroup(String groupId) async {
    try {
      await _pb.leaveGroup(groupId);
      _myMemberships[groupId] = null;
      _myGroups.removeWhere((g) => g.id == groupId);

      // Update member count in local group
      final index = _groups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        final group = _groups[index];
        _groups[index] = Group(
          id: group.id,
          name: group.name,
          description: group.description,
          creatorId: group.creatorId,
          category: group.category,
          isPrivate: group.isPrivate,
          memberCount: (group.memberCount - 1).clamp(0, 999999),
          bannerUrl: group.bannerUrl,
          createdAt: group.createdAt,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<void> loadGroupPosts(String groupId) async {
    try {
      final result = await _pb.getGroupPosts(groupId: groupId);
      _groupPosts[groupId] = result.items
          .map((record) => GroupPost.fromPocketBase(record))
          .toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<bool> createGroupPost(String groupId, String content) async {
    try {
      final record = await _pb.createGroupPost(
        groupId: groupId,
        content: content,
      );
      final newPost = GroupPost.fromPocketBase(record);

      if (_groupPosts[groupId] == null) {
        _groupPosts[groupId] = [];
      }
      _groupPosts[groupId]!.insert(0, newPost);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> deleteGroupPost(String groupId, String postId) async {
    try {
      await _pb.deleteGroupPost(postId);
      _groupPosts[groupId]?.removeWhere((p) => p.id == postId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<void> loadGroupMembers(String groupId) async {
    try {
      final result = await _pb.getGroupMembers(groupId: groupId);
      _groupMembers[groupId] = result.items
          .map((record) => GroupMember.fromPocketBase(record))
          .toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> loadMyMembership(String groupId) async {
    try {
      final membership = await _pb.getUserGroupMembership(groupId);
      _myMemberships[groupId] =
          membership != null ? GroupMember.fromPocketBase(membership) : null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }
}
