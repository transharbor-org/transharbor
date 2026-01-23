import 'package:pocketbase/pocketbase.dart';

class Personal {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final int commentsCount;

  Personal({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  factory Personal.fromJson(Map<String, dynamic> json) {
    return Personal(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
    );
  }

  factory Personal.fromPocketBase(RecordModel record) {
    return Personal(
      id: record.id,
      userId: record.getStringValue('user_id'),
      content: record.getStringValue('content'),
      createdAt: DateTime.parse(record.created),
      updatedAt: DateTime.parse(record.updated),
      likesCount: record.getIntValue('likes_count'),
      commentsCount: record.getIntValue('comments_count'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
    };
  }
}
