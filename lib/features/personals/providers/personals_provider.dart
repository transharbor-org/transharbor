import 'package:flutter/material.dart';
import '../../../core/services/pocketbase_service.dart';
import '../../../core/services/logging_service.dart';
import '../models/personal.dart';

class PersonalsProvider extends ChangeNotifier {
  final PocketBaseService _pb;
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
      _personals = result.items
          .map((record) => Personal.fromPocketBase(record))
          .toList();
      
      logger.info('Loaded personals feed', metadata: {'count': _personals.length});
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
      final record = await _pb.createPersonal(content);
      final newPersonal = Personal.fromPocketBase(record);
      _personals.insert(0, newPersonal);
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
