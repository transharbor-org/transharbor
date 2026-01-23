import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/messaging/models/message.dart';


void main() {
  group('Message Model', () {
    test('creates message from JSON', () {
      final json = {
        'id': 'msg123',
        'conversation_id': 'conv123',
        'sender_id': 'user123',
        'content': 'Hello world',
        'is_read': false,
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final message = Message.fromJson(json);

      expect(message.id, 'msg123');
      expect(message.conversationId, 'conv123');
      expect(message.senderId, 'user123');
      expect(message.content, 'Hello world');
      expect(message.isRead, false);
    });

    test('converts message to JSON', () {
      final message = Message(
        id: 'msg123',
        conversationId: 'conv123',
        senderId: 'user123',
        content: 'Hello world',
        isRead: false,
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      final json = message.toJson();

      expect(json['id'], 'msg123');
      expect(json['conversation_id'], 'conv123');
      expect(json['sender_id'], 'user123');
      expect(json['content'], 'Hello world');
      expect(json['is_read'], false);
    });

    test('creates message from PocketBase record', () {
      // Skip this test - would require mocking PocketBase RecordModel
    }, skip: true);
  });

  group('Conversation Model', () {
    test('creates conversation from JSON', () {
      final json = {
        'id': 'conv123',
        'participant_ids': ['user1', 'user2'],
        'unread_count': 3,
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final conversation = Conversation.fromJson(json);

      expect(conversation.id, 'conv123');
      expect(conversation.participantIds, ['user1', 'user2']);
      expect(conversation.unreadCount, 3);
    });

    test('creates conversation from PocketBase record', () {
      // Skip this test - would require mocking PocketBase RecordModel
    }, skip: true);
  });
}
