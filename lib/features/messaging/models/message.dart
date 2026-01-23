import 'package:pocketbase/pocketbase.dart';

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  factory Message.fromPocketBase(RecordModel record) {
    return Message(
      id: record.id,
      conversationId: record.getStringValue('conversation_id'),
      senderId: record.getStringValue('sender_id'),
      content: record.getStringValue('content'),
      createdAt: DateTime.parse(record.created),
      isRead: record.getBoolValue('is_read'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}

class Conversation {
  final String id;
  final List<String> participantIds;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      participantIds: List<String>.from(json['participant_ids'] as List),
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory Conversation.fromPocketBase(RecordModel record) {
    // PocketBase stores arrays as JSON arrays
    final participantIds = (record.data['participant_ids'] as List)
        .map((e) => e.toString())
        .toList();

    return Conversation(
      id: record.id,
      participantIds: participantIds,
      lastMessage: null, // Can be populated separately
      unreadCount: record.getIntValue('unread_count'),
      createdAt: DateTime.parse(record.created),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_ids': participantIds,
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
