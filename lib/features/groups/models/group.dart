import 'package:pocketbase/pocketbase.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final String? category;
  final bool isPrivate;
  final int memberCount;
  final String? bannerUrl;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    this.category,
    this.isPrivate = false,
    this.memberCount = 0,
    this.bannerUrl,
    required this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      creatorId: json['creator_id'] as String,
      category: json['category'] as String?,
      isPrivate: json['is_private'] as bool? ?? false,
      memberCount: json['member_count'] as int? ?? 0,
      bannerUrl: json['banner_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory Group.fromPocketBase(RecordModel record) {
    return Group(
      id: record.id,
      name: record.getStringValue('name'),
      description: record.getStringValue('description'),
      creatorId: record.getStringValue('creator_id'),
      category: record.getStringValue('category').isNotEmpty
          ? record.getStringValue('category')
          : null,
      isPrivate: record.getBoolValue('is_private'),
      memberCount: record.getIntValue('member_count'),
      bannerUrl: record.getStringValue('banner_url').isNotEmpty
          ? record.getStringValue('banner_url')
          : null,
      createdAt: DateTime.parse(record.created),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creator_id': creatorId,
      'category': category,
      'is_private': isPrivate,
      'member_count': memberCount,
      'banner_url': bannerUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum GroupRole {
  admin,
  moderator,
  member,
}

class GroupMember {
  final String id;
  final String groupId;
  final String userId;
  final GroupRole role;
  final DateTime joinedAt;

  GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      role: GroupRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => GroupRole.member,
      ),
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  factory GroupMember.fromPocketBase(RecordModel record) {
    return GroupMember(
      id: record.id,
      groupId: record.getStringValue('group_id'),
      userId: record.getStringValue('user_id'),
      role: GroupRole.values.firstWhere(
        (e) => e.name == record.getStringValue('role'),
        orElse: () => GroupRole.member,
      ),
      joinedAt: DateTime.parse(record.getStringValue('joined_at')),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'role': role.name,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

class GroupPost {
  final String id;
  final String groupId;
  final String userId;
  final String content;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  GroupPost({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.content,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
  });

  factory GroupPost.fromJson(Map<String, dynamic> json) {
    return GroupPost(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory GroupPost.fromPocketBase(RecordModel record) {
    return GroupPost(
      id: record.id,
      groupId: record.getStringValue('group_id'),
      userId: record.getStringValue('user_id'),
      content: record.getStringValue('content'),
      likesCount: record.getIntValue('likes_count'),
      commentsCount: record.getIntValue('comments_count'),
      createdAt: DateTime.parse(record.created),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'content': content,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
