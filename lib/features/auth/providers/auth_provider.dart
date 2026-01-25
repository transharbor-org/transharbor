import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/pocketbase_service.dart';
import '../../../core/services/logging_service.dart';

class AuthProvider extends ChangeNotifier {
  final PocketBaseService _pb;
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({PocketBaseService? pocketBaseService})
      : _pb = pocketBaseService ?? PocketBaseService();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _pb.isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Check if current user can moderate
  bool get canModerate => _currentUser?.canModerate ?? false;

  /// Check if current user is admin
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Check if current user has privileged access
  bool get isPrivileged => _currentUser?.isPrivileged ?? false;

  /// Get current user's role
  UserRole? get userRole => _currentUser?.role;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_pb.isAuthenticated && _pb.currentUser != null) {
        _currentUser = User.fromPocketBase(_pb.currentUser!);
      }
    } catch (e) {
      _errorMessage = e.toString();
      // Log auth check error
      if (e.toString().contains('Failed') || e.toString().contains('Error')) {
        logger.error('Auth check failed', error: e);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    try {
      if (_pb.isAuthenticated && _pb.currentUserId != null) {
        final record =
            await _pb.pb.collection('users').getOne(_pb.currentUserId!);
        _currentUser = User.fromPocketBase(record);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authData = await _pb.login(email, password);
      if (authData.record != null) {
        _currentUser = User.fromPocketBase(authData.record!);
        logger.setUser(_currentUser!.id);
        logger.info('User logged in successfully', metadata: {'userId': _currentUser!.id});
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      logger.error('Login failed', error: e, metadata: {'email': email});
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password,
      {String? username}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authData = await _pb.register(
        email: email,
        password: password,
        passwordConfirm: password,
      );
      if (authData.record != null) {
        _currentUser = User.fromPocketBase(authData.record!);
        logger.setUser(_currentUser!.id);
        logger.info('User registered successfully', metadata: {'userId': _currentUser!.id, 'email': email});
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      logger.error('Registration failed', error: e, metadata: {'email': email});
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _pb.logout();
    _currentUser = null;
    notifyListeners();
  }
}
