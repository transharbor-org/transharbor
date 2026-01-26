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
      creatorId: json['creator'] as String,
      category: json['category'] as String?,
      isPrivate: json['isPrivate'] as bool? ?? false,
      memberCount: json['memberCount'] as int? ?? 0,
      bannerUrl: json['bannerUrl'] as String?,
      createdAt: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : DateTime.now(),
    );
  }

  factory Group.fromPocketBase(RecordModel record) {
    return Group(
      id: record.id,
      name: record.getStringValue('name'),
      description: record.getStringValue('description'),
      creatorId: record.getStringValue('creator'),
      category: record.getStringValue('category').isNotEmpty
          ? record.getStringValue('category')
          : null,
      isPrivate: record.getBoolValue('isPrivate'),
      memberCount: (record.data['members'] as List?)?.length ?? 0,
      bannerUrl: record.getStringValue('bannerUrl').isNotEmpty
          ? record.getStringValue('bannerUrl')
          : null,
      createdAt:
          record.created.isNotEmpty ? DateTime.parse(record.created) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creator': creatorId,
      'category': category,
      'isPrivate': isPrivate,
      'memberCount': memberCount,
      'bannerUrl': bannerUrl,
      'created': createdAt.toIso8601String(),
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
      groupId: json['group'] as String,
      userId: json['user'] as String,
      role: GroupRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => GroupRole.member,
      ),
      joinedAt: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : DateTime.now(),
    );
  }

  factory GroupMember.fromPocketBase(RecordModel record) {
    return GroupMember(
      id: record.id,
      groupId: record.getStringValue('group'),
      userId: record.getStringValue('user'),
      role: GroupRole.values.firstWhere(
        (e) => e.name == record.getStringValue('role'),
        orElse: () => GroupRole.member,
      ),
      joinedAt:
          record.created.isNotEmpty ? DateTime.parse(record.created) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group': groupId,
      'user': userId,
      'role': role.name,
      'created': joinedAt.toIso8601String(),
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
      groupId: json['group'] as String,
      userId: json['author'] as String,
      content: json['content'] as String,
      likesCount: json['likes'] as int? ?? 0,
      commentsCount: json['comments'] as int? ?? 0,
      createdAt: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : DateTime.now(),
    );
  }

  factory GroupPost.fromPocketBase(RecordModel record) {
    return GroupPost(
      id: record.id,
      groupId: record.getStringValue('group'),
      userId: record.getStringValue('author'),
      content: record.getStringValue('content'),
      likesCount: record.getIntValue('likes'),
      commentsCount: 0,
      createdAt:
          record.created.isNotEmpty ? DateTime.parse(record.created) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group': groupId,
      'author': userId,
      'content': content,
      'likes': likesCount,
      'comments': commentsCount,
      'created': createdAt.toIso8601String(),
    };
  }
}
