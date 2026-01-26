import 'package:flutter/material.dart';
import '../../../core/services/pocketbase_service.dart';
import '../../../core/services/logging_service.dart';
import '../../../core/services/encryption_service.dart';
import '../models/personal.dart';

class PersonalsProvider extends ChangeNotifier {
  final PocketBaseService _pb;
  final EncryptionService _encryption = EncryptionService();
  List<Personal> _personals = [];
  bool _isLoading = false;
  String? _errorMessage;

  PersonalsProvider({PocketBaseService? pocketBaseService})
      : _pb = pocketBaseService ?? PocketBaseService();

  List<Personal> get personals => _personals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPersonals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUserId = _pb.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Load ALL personals from ALL users, sorted by newest first
      final result = await _pb.getPersonals();
      _personals = result.items.map((record) {
        final personal = Personal.fromPocketBase(record);
        // Decrypt content
        return Personal(
          id: personal.id,
          userId: personal.userId,
          content: _encryption.decrypt(personal.content),
          createdAt: personal.createdAt,
          updatedAt: personal.updatedAt,
          likesCount: personal.likesCount,
          commentsCount: personal.commentsCount,
        );
      }).toList();

      logger.info('Loaded personals feed',
          metadata: {'count': _personals.length});
    } catch (e) {
      _errorMessage = e.toString();
      logger.error('Failed to load personals', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPersonal(String content) async {
    try {
      // Encrypt content before sending
      final encryptedContent = _encryption.encrypt(content);

      final record = await _pb.createPersonal(encryptedContent);
      final newPersonal = Personal.fromPocketBase(record);

      // Decrypt for local display
      final decryptedPersonal = Personal(
        id: newPersonal.id,
        userId: newPersonal.userId,
        content: content, // Use original unencrypted content
        createdAt: newPersonal.createdAt,
        updatedAt: newPersonal.updatedAt,
        likesCount: newPersonal.likesCount,
        commentsCount: newPersonal.commentsCount,
      );

      _personals.insert(0, decryptedPersonal);
      notifyListeners();

      logger.info('Personal post created', metadata: {
        'personalId': newPersonal.id,
        'contentLength': content.length,
      });

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      logger.error('Failed to create personal post', error: e);
      return false;
    }
  }

  Future<bool> deletePersonal(String personalId) async {
    try {
      await _pb.deletePersonal(personalId);
      _personals.removeWhere((p) => p.id == personalId);
      notifyListeners();

      logger.info('Personal post deleted', metadata: {
        'personalId': personalId,
      });

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      logger.error('Failed to delete personal post', error: e, metadata: {
        'personalId': personalId,
      });
      return false;
    }
  }
}
