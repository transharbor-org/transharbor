import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class PocketBaseService {
  static final PocketBaseService _instance = PocketBaseService._internal();
  late final PocketBase pb;

  // PocketBase configuration
  // SDK automatically adds /api/, so we just need the base path
  // For local dev, use 'http://127.0.0.1:8090'
  static const String baseUrl = String.fromEnvironment(
    'POCKETBASE_URL',
    defaultValue: '/',
  );

  // Collection names
  static const String usersCollection = 'users';
  static const String personalsCollection = 'personals';
  static const String messagesCollection = 'messages';
  static const String conversationsCollection = 'conversations';
  static const String proposalsCollection = 'proposals';
  static const String votesCollection = 'votes';
  static const String groupsCollection = 'groups';
  static const String groupMembersCollection = 'group_members';
  static const String groupPostsCollection = 'group_posts';

  factory PocketBaseService() {
    return _instance;
  }

  PocketBaseService._internal() {
    pb = PocketBase(baseUrl);
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Restore auth from storage
    final token = await StorageService.getAuthToken();
    final modelJson = await StorageService.getUserModel();

    if (token != null && modelJson != null) {
      try {
        final modelData = jsonDecode(modelJson);
        final model = RecordModel.fromJson(modelData);
        pb.authStore.save(token, model);
      } catch (e) {
        // If restoration fails, clear storage
        await StorageService.clearAll();
      }
    }

    // Listen to auth changes
    pb.authStore.onChange.listen((e) {
      if (e.token.isNotEmpty && e.model != null) {
        StorageService.saveAuthToken(e.token);
        StorageService.saveUserModel(jsonEncode(e.model.toJson()));
      } else {
        StorageService.clearAll();
      }
    });
  }

  // Auth Methods
  Future<RecordAuth> login(String email, String password) async {
    try {
      final authData = await pb
          .collection(PocketBaseService.usersCollection)
          .authWithPassword(email, password);
      return authData;
    } catch (e) {
      rethrow;
    }
  }

  Future<RecordAuth> register({
    required String email,
    required String password,
    required String passwordConfirm,
    String? username,
    String? displayName,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
        'emailVisibility': false,
        'role': 'user',
        'membership_type': 'non_voting',
      };

      if (username != null) body['username'] = username;
      if (displayName != null) body['displayName'] = displayName;

      await pb.collection(PocketBaseService.usersCollection).create(body: body);

      // Auto-login after registration
      final authData = await pb
          .collection(PocketBaseService.usersCollection)
          .authWithPassword(email, password);

      return authData;
    } catch (e) {
      rethrow;
    }
  }

  void logout() {
    pb.authStore.clear();
  }

  bool get isAuthenticated => pb.authStore.isValid;

  RecordModel? get currentUser => pb.authStore.model;

  String? get currentUserId => pb.authStore.model?.id;

  // User Profile Methods
  Future<RecordModel> updateUserProfile({
    String? displayName,
    String? bio,
    String? pronouns,
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['displayName'] = displayName;
    if (bio != null) body['bio'] = bio;
    if (pronouns != null) body['pronouns'] = pronouns;

    return await pb.collection(PocketBaseService.usersCollection).update(
          currentUserId!,
          body: body,
        );
  }

  Future<RecordModel> uploadUserAvatar(String filePath) async {
    return await pb.collection(PocketBaseService.usersCollection).update(
      currentUserId!,
      body: {},
      files: [
        await http.MultipartFile.fromPath('avatar', filePath),
      ],
    );
  }

  Future<String> getAvatarUrl(String userId, String? avatarFilename) async {
    if (avatarFilename == null || avatarFilename.isEmpty) return '';
    try {
      final record =
          await pb.collection(PocketBaseService.usersCollection).getOne(userId);
      return pb.files.getUrl(record, avatarFilename).toString();
    } catch (e) {
      return '';
    }
  }

  // Personals Methods
  Future<ResultList<RecordModel>> getPersonals({
    int page = 1,
    int perPage = 20,
    String? filter,
  }) async {
    return await pb.collection(PocketBaseService.personalsCollection).getList(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: '-created',
          expand: 'user',
        );
  }

  Future<RecordModel> createPersonal(String content) async {
    return await pb.collection(PocketBaseService.personalsCollection).create(
      body: {
        'user': currentUserId,
        'content': content,
        'likes': 0,
        'comments': 0,
      },
    );
  }

  Future<void> deletePersonal(String id) async {
    await pb.collection(PocketBaseService.personalsCollection).delete(id);
  }

  // Messaging Methods
  Future<ResultList<RecordModel>> getConversations({
    int page = 1,
    int perPage = 20,
  }) async {
    return await pb
        .collection(PocketBaseService.conversationsCollection)
        .getList(
          page: page,
          perPage: perPage,
          filter: 'participants ~ "$currentUserId"',
          sort: '-updated',
        );
  }

  Future<ResultList<RecordModel>> getMessages({
    required String conversationId,
    int page = 1,
    int perPage = 50,
  }) async {
    return await pb.collection(PocketBaseService.messagesCollection).getList(
          page: page,
          perPage: perPage,
          filter: 'conversation_id = "$conversationId"',
          sort: 'created',
        );
  }

  Future<RecordModel> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    return await pb.collection(PocketBaseService.messagesCollection).create(
      body: {
        'conversation_id': conversationId,
        'sender_id': currentUserId,
        'content': content,
        'is_read': false,
      },
    );
  }

  // Governance Methods
  Future<ResultList<RecordModel>> getProposals({
    int page = 1,
    int perPage = 20,
    String? filter,
  }) async {
    return await pb.collection(PocketBaseService.proposalsCollection).getList(
          page: page,
          perPage: perPage,
          filter: filter,
          sort: '-created',
          expand: 'author_id',
        );
  }

  Future<RecordModel> createProposal({
    required String title,
    required String description,
    required DateTime votingEndsAt,
  }) async {
    return await pb.collection(PocketBaseService.proposalsCollection).create(
      body: {
        'title': title,
        'description': description,
        'author_id': currentUserId,
        'voting_ends_at': votingEndsAt.toIso8601String(),
        'status': 'active',
        'votes_for': 0,
        'votes_against': 0,
        'votes_abstain': 0,
      },
    );
  }

  Future<RecordModel> submitVote({
    required String proposalId,
    required String choice, // 'for', 'against', 'abstain'
  }) async {
    // Check if user already voted
    final existingVotes =
        await pb.collection(PocketBaseService.votesCollection).getList(
              filter: 'proposal = "$proposalId" && user = "$currentUserId"',
            );

    if (existingVotes.items.isNotEmpty) {
      throw Exception('Already voted on this proposal');
    }

    // Create vote record
    final vote = await pb.collection(PocketBaseService.votesCollection).create(
      body: {
        'proposal': proposalId,
        'user': currentUserId,
        'vote': choice,
      },
    );

    // Update proposal vote counts
    final proposal = await pb
        .collection(PocketBaseService.proposalsCollection)
        .getOne(proposalId);
    final votes = {
      'votes_for': proposal.getIntValue('votes_for'),
      'votes_against': proposal.getIntValue('votes_against'),
      'votes_abstain': proposal.getIntValue('votes_abstain'),
    };

    switch (choice) {
      case 'for':
        votes['votes_for'] = votes['votes_for']! + 1;
        break;
      case 'against':
        votes['votes_against'] = votes['votes_against']! + 1;
        break;
      case 'abstain':
        votes['votes_abstain'] = votes['votes_abstain']! + 1;
        break;
    }

    await pb
        .collection(PocketBaseService.proposalsCollection)
        .update(proposalId, body: votes);

    return vote;
  }

  // Realtime Subscriptions
  Future<void> subscribeToCollection(
    String collection,
    void Function(RecordSubscriptionEvent e) callback,
  ) async {
    await pb.collection(collection).subscribe('*', callback);
  }

  void unsubscribeFromCollection(String collection) {
    pb.collection(collection).unsubscribe();
  }

  // Groups Methods
  Future<ResultList<RecordModel>> getGroups({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? category,
  }) async {
    String finalFilter = filter ?? '';
    if (category != null && category.isNotEmpty) {
      finalFilter = finalFilter.isEmpty
          ? 'category = "$category"'
          : '$finalFilter && category = "$category"';
    }

    return await pb.collection(PocketBaseService.groupsCollection).getList(
          page: page,
          perPage: perPage,
          filter: finalFilter.isNotEmpty ? finalFilter : null,
          sort: '-created',
          expand: 'creator_id',
        );
  }

  Future<RecordModel> getGroup(String groupId) async {
    return await pb.collection(PocketBaseService.groupsCollection).getOne(
          groupId,
          expand: 'creator_id',
        );
  }

  Future<RecordModel> createGroup({
    required String name,
    required String description,
    String? category,
    bool isPrivate = false,
  }) async {
    final record =
        await pb.collection(PocketBaseService.groupsCollection).create(
      body: {
        'name': name,
        'description': description,
        'creator_id': currentUserId,
        'category': category,
        'is_private': isPrivate,
        'member_count': 1,
      },
    );

    // Auto-join creator as admin
    await pb.collection(PocketBaseService.groupMembersCollection).create(
      body: {
        'group': record.id,
        'user': currentUserId,
        'role': 'admin',
      },
    );

    return record;
  }

  Future<void> updateGroup(String groupId, Map<String, dynamic> data) async {
    await pb
        .collection(PocketBaseService.groupsCollection)
        .update(groupId, body: data);
  }

  Future<void> deleteGroup(String groupId) async {
    await pb.collection(PocketBaseService.groupsCollection).delete(groupId);
  }

  // Group Members Methods
  Future<ResultList<RecordModel>> getGroupMembers({
    required String groupId,
    int page = 1,
    int perPage = 50,
  }) async {
    return await pb
        .collection(PocketBaseService.groupMembersCollection)
        .getList(
          page: page,
          perPage: perPage,
          filter: 'group = "$groupId"',
          expand: 'user',
        );
  }

  Future<RecordModel?> getUserGroupMembership(String groupId) async {
    try {
      final result =
          await pb.collection(PocketBaseService.groupMembersCollection).getList(
                filter: 'group = "$groupId" && user = "$currentUserId"',
              );
      return result.items.isNotEmpty ? result.items.first : null;
    } catch (e) {
      return null;
    }
  }

  Future<ResultList<RecordModel>> getUserGroups({
    int page = 1,
    int perPage = 20,
  }) async {
    return await pb
        .collection(PocketBaseService.groupMembersCollection)
        .getList(
          page: page,
          perPage: perPage,
          filter: 'user = "$currentUserId"',
          expand: 'group',
          sort: '-created',
        );
  }

  Future<RecordModel> joinGroup(String groupId) async {
    final membership =
        await pb.collection(PocketBaseService.groupMembersCollection).create(
      body: {
        'group': groupId,
        'user': currentUserId,
        'role': 'member',
      },
    );

    // Increment member count
    final group =
        await pb.collection(PocketBaseService.groupsCollection).getOne(groupId);
    await pb.collection(PocketBaseService.groupsCollection).update(
      groupId,
      body: {'member_count': group.getIntValue('member_count') + 1},
    );

    return membership;
  }

  Future<void> leaveGroup(String groupId) async {
    final membership = await getUserGroupMembership(groupId);
    if (membership != null) {
      await pb
          .collection(PocketBaseService.groupMembersCollection)
          .delete(membership.id);

      // Decrement member count
      final group = await pb
          .collection(PocketBaseService.groupsCollection)
          .getOne(groupId);
      final newCount = (group.getIntValue('member_count') - 1).clamp(0, 999999);
      await pb.collection(PocketBaseService.groupsCollection).update(
        groupId,
        body: {'member_count': newCount},
      );
    }
  }

  // Group Posts Methods
  Future<ResultList<RecordModel>> getGroupPosts({
    required String groupId,
    int page = 1,
    int perPage = 20,
  }) async {
    return await pb.collection(PocketBaseService.groupPostsCollection).getList(
          page: page,
          perPage: perPage,
          filter: 'group = "$groupId"',
          sort: '-created',
          expand: 'author',
        );
  }

  Future<RecordModel> createGroupPost({
    required String groupId,
    required String content,
  }) async {
    return await pb.collection(PocketBaseService.groupPostsCollection).create(
      body: {
        'group': groupId,
        'author': currentUserId,
        'content': content,
        'likes': 0,
      },
    );
  }

  Future<void> deleteGroupPost(String postId) async {
    await pb.collection(PocketBaseService.groupPostsCollection).delete(postId);
  }
}
