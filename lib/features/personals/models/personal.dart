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
      userId: json['user'] as String,
      content: json['content'] as String,
      createdAt: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : DateTime.now(),
      updatedAt: json['updated'] != null
          ? DateTime.parse(json['updated'] as String)
          : null,
      likesCount: json['likes'] as int? ?? 0,
      commentsCount: json['comments'] as int? ?? 0,
    );
  }

  factory Personal.fromPocketBase(RecordModel record) {
    return Personal(
      id: record.id,
      userId: record.getStringValue('user'),
      content: record.getStringValue('content'),
      createdAt: record.created.isNotEmpty && record.created != 'null'
          ? DateTime.parse(record.created)
          : DateTime.now(),
      updatedAt: record.updated.isNotEmpty && record.updated != 'null'
          ? DateTime.parse(record.updated)
          : null,
      likesCount: record.getIntValue('likes'),
      commentsCount: record.getIntValue('comments'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'content': content,
      'created': createdAt.toIso8601String(),
      'updated': updatedAt?.toIso8601String(),
      'likes': likesCount,
      'comments': commentsCount,
    };
  }
}
