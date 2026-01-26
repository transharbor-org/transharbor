import 'package:flutter/material.dart';
import '../../../core/services/pocketbase_service.dart';
import '../../../core/services/logging_service.dart';
import '../../../core/services/encryption_service.dart';
import '../models/message.dart';

class MessagingProvider extends ChangeNotifier {
  final PocketBaseService _pb;
  final EncryptionService _encryption = EncryptionService();
  List<Conversation> _conversations = [];
  Map<String, List<Message>> _messages = {};
  bool _isLoading = false;
  String? _errorMessage;

  MessagingProvider({PocketBaseService? pocketBaseService})
      : _pb = pocketBaseService ?? PocketBaseService();

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Message> getMessages(String conversationId) {
    return _messages[conversationId] ?? [];
  }

  Future<void> loadConversations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _pb.getConversations();
      _conversations = result.items
          .map((record) => Conversation.fromPocketBase(record))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      final result = await _pb.getMessages(conversationId: conversationId);
      _messages[conversationId] = result.items.map((record) {
        final message = Message.fromPocketBase(record);
        // Decrypt message content
        return Message(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          content: _encryption.decrypt(message.content),
          createdAt: message.createdAt,
          isRead: message.isRead,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<bool> sendMessage(String conversationId, String content) async {
    try {
      // Encrypt message content before sending
      final encryptedContent = _encryption.encrypt(content);
      
      final record = await _pb.sendMessage(
        conversationId: conversationId,
        content: encryptedContent,
      );
      final newMessage = Message.fromPocketBase(record);
      
      // Decrypt for local display
      final decryptedMessage = Message(
        id: newMessage.id,
        conversationId: newMessage.conversationId,
        senderId: newMessage.senderId,
        content: content, // Use original unencrypted content
        createdAt: newMessage.createdAt,
        isRead: newMessage.isRead,
      );

      if (_messages[conversationId] == null) {
        _messages[conversationId] = [];
      }
      _messages[conversationId]!.add(decryptedMessage);
      notifyListeners();

      logger.info('Message sent', metadata: {
        'conversationId': conversationId,
        'messageId': newMessage.id,
        'contentLength': content.length,
      });

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      logger.error('Failed to send message', error: e, metadata: {
        'conversationId': conversationId,
      });
      return false;
    }
  }
}
