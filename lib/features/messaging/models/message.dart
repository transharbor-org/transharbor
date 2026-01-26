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
      conversationId: json['conversation'] as String,
      senderId: json['sender'] as String,
      content: json['content'] as String,
      createdAt: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : DateTime.now(),
      isRead: json['read'] as bool? ?? false,
    );
  }

  factory Message.fromPocketBase(RecordModel record) {
    return Message(
      id: record.id,
      conversationId: record.getStringValue('conversation'),
      senderId: record.getStringValue('sender'),
      content: record.getStringValue('content'),
      createdAt: record.created.isNotEmpty
          ? DateTime.parse(record.created)
          : DateTime.now(),
      isRead: record.getBoolValue('read'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation': conversationId,
      'sender': senderId,
      'content': content,
      'created': createdAt.toIso8601String(),
      'read': isRead,
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
      participantIds: List<String>.from(json['participants'] as List),
      lastMessage: json['lastMessage'] != null
          ? Message.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      createdAt: json['created'] != null
          ? DateTime.parse(json['created'] as String)
          : DateTime.now(),
    );
  }

  factory Conversation.fromPocketBase(RecordModel record) {
    // PocketBase stores participants as relation array
    final participantIds = (record.data['participants'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    return Conversation(
      id: record.id,
      participantIds: participantIds,
      lastMessage: null, // Can be populated separately
      unreadCount: record.getIntValue('unreadCount'),
      createdAt: record.created.isNotEmpty
          ? DateTime.parse(record.created)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participantIds,
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'created': createdAt.toIso8601String(),
    };
  }
}
