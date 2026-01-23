import 'package:flutter/material.dart';
import '../../../core/services/pocketbase_service.dart';
import '../models/message.dart';

class MessagingProvider extends ChangeNotifier {
  final PocketBaseService _pb;
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
      _messages[conversationId] =
          result.items.map((record) => Message.fromPocketBase(record)).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<bool> sendMessage(String conversationId, String content) async {
    try {
      final record = await _pb.sendMessage(
        conversationId: conversationId,
        content: content,
      );
      final newMessage = Message.fromPocketBase(record);

      if (_messages[conversationId] == null) {
        _messages[conversationId] = [];
      }
      _messages[conversationId]!.add(newMessage);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
}
