import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/messaging/models/message.dart';

void main() {
  group('Message Model Tests', () {
    test('creates Message with all fields', () {
      final now = DateTime.now();
      final message = Message(
        id: 'msg-123',
        conversationId: 'conv-456',
        senderId: 'user-789',
        content: 'Hello!',
        createdAt: now,
        isRead: true,
      );

      expect(message.id, 'msg-123');
      expect(message.conversationId, 'conv-456');
      expect(message.senderId, 'user-789');
      expect(message.content, 'Hello!');
      expect(message.createdAt, now);
      expect(message.isRead, true);
    });

    test('creates Message with defaults', () {
      final message = Message(
        id: 'msg-123',
        conversationId: 'conv-456',
        senderId: 'user-789',
        content: 'Hello!',
        createdAt: DateTime.now(),
      );

      expect(message.isRead, false);
    });

    test('handles empty content', () {
      final message = Message(
        id: 'msg-123',
        conversationId: 'conv-456',
        senderId: 'user-789',
        content: '',
        createdAt: DateTime.now(),
      );

      expect(message.content, '');
    });

    test('handles long content', () {
      final longContent = 'A' * 10000;
      final message = Message(
        id: 'msg-123',
        conversationId: 'conv-456',
        senderId: 'user-789',
        content: longContent,
        createdAt: DateTime.now(),
      );

      expect(message.content.length, 10000);
    });

    test('handles emojis and special characters', () {
      const content = 'Trans pride! 🏳️‍⚧️ 🌈 ❤️';
      final message = Message(
        id: 'msg-123',
        conversationId: 'conv-456',
        senderId: 'user-789',
        content: content,
        createdAt: DateTime.now(),
      );

      expect(message.content, content);
    });

    test('isRead defaults to false', () {
      final message = Message(
        id: 'msg-123',
        conversationId: 'conv-456',
        senderId: 'user-789',
        content: 'Test',
        createdAt: DateTime.now(),
      );

      expect(message.isRead, false);
    });
  });

  group('Conversation Model Tests', () {
    test('creates Conversation with all fields', () {
      final now = DateTime.now();
      final conversation = Conversation(
        id: 'conv-123',
        participants: ['user1', 'user2'],
        lastMessage: 'Hey there!',
        lastMessageTime: now,
        unreadCount: 3,
      );

      expect(conversation.id, 'conv-123');
      expect(conversation.participants.length, 2);
      expect(conversation.participants, contains('user1'));
      expect(conversation.participants, contains('user2'));
      expect(conversation.lastMessage, 'Hey there!');
      expect(conversation.lastMessageTime, now);
      expect(conversation.unreadCount, 3);
    });

    test('creates Conversation with defaults', () {
      final conversation = Conversation(
        id: 'conv-123',
        participants: ['user1', 'user2'],
        lastMessageTime: DateTime.now(),
      );

      expect(conversation.lastMessage, isNull);
      expect(conversation.unreadCount, 0);
    });

    test('handles empty participants list', () {
      final conversation = Conversation(
        id: 'conv-123',
        participants: [],
        lastMessageTime: DateTime.now(),
      );

      expect(conversation.participants.isEmpty, true);
    });

    test('handles multiple participants', () {
      final conversation = Conversation(
        id: 'conv-123',
        participants: ['user1', 'user2', 'user3', 'user4'],
        lastMessageTime: DateTime.now(),
      );

      expect(conversation.participants.length, 4);
    });

    test('unreadCount defaults to 0', () {
      final conversation = Conversation(
        id: 'conv-123',
        participants: ['user1'],
        lastMessageTime: DateTime.now(),
      );

      expect(conversation.unreadCount, 0);
    });

    test('handles large unread count', () {
      final conversation = Conversation(
        id: 'conv-123',
        participants: ['user1', 'user2'],
        lastMessageTime: DateTime.now(),
        unreadCount: 999,
      );

      expect(conversation.unreadCount, 999);
    });
  });
}
