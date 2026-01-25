import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class LogEntry {
  final String message;
  final LogLevel level;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final String? stackTrace;
  final String? userId;
  final String? screen;

  LogEntry({
    required this.message,
    required this.level,
    required this.timestamp,
    this.metadata,
    this.stackTrace,
    this.userId,
    this.screen,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'level': level.name,
        'timestamp': timestamp.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
        if (stackTrace != null) 'stackTrace': stackTrace,
        if (userId != null) 'userId': userId,
        if (screen != null) 'screen': screen,
        'source': 'flutter_web',
      };
}

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  final List<LogEntry> _logBuffer = [];
  final int _maxBufferSize = 50;
  Timer? _flushTimer;
  String? _currentUserId;
  String? _currentScreen;
  String? _apiBaseUrl;

  /// Initialize logging service with API base URL
  void initialize({String? apiBaseUrl}) {
    _apiBaseUrl = apiBaseUrl ?? '/api';
    _startPeriodicFlush();
  }

  /// Set current user for context in logs
  void setUser(String? userId) {
    _currentUserId = userId;
  }

  /// Set current screen for context in logs
  void setScreen(String? screen) {
    _currentScreen = screen;
  }

  /// Log debug message
  void debug(String message, {Map<String, dynamic>? metadata}) {
    _log(LogLevel.debug, message, metadata: metadata);
  }

  /// Log info message
  void info(String message, {Map<String, dynamic>? metadata}) {
    _log(LogLevel.info, message, metadata: metadata);
  }

  /// Log warning message
  void warning(String message, {Map<String, dynamic>? metadata}) {
    _log(LogLevel.warning, message, metadata: metadata);
  }

  /// Log error message
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      LogLevel.error,
      message,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log fatal error
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _log(
      LogLevel.fatal,
      message,
      metadata: metadata,
      error: error,
      stackTrace: stackTrace,
    );
    // Immediately flush fatal errors
    flush();
  }

  void _log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      message: message,
      level: level,
      timestamp: DateTime.now(),
      metadata: {
        if (metadata != null) ...metadata,
        if (error != null) 'error': error.toString(),
      },
      stackTrace: stackTrace?.toString(),
      userId: _currentUserId,
      screen: _currentScreen,
    );

    // Also print to console in debug mode
    if (kDebugMode) {
      final prefix = '[${level.name.toUpperCase()}]';
      if (level == LogLevel.error || level == LogLevel.fatal) {
        debugPrint('$prefix $message');
        if (error != null) debugPrint('Error: $error');
        if (stackTrace != null) debugPrint('$stackTrace');
      } else {
        debugPrint('$prefix $message');
      }
    }

    _logBuffer.add(entry);

    // Flush if buffer is full or it's a critical log
    if (_logBuffer.length >= _maxBufferSize ||
        level == LogLevel.error ||
        level == LogLevel.fatal) {
      flush();
    }
  }

  void _startPeriodicFlush() {
    // Flush logs every 30 seconds
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      flush();
    });
  }

  /// Manually flush logs to backend
  Future<void> flush() async {
    if (_logBuffer.isEmpty || _apiBaseUrl == null) return;

    final logsToSend = List<LogEntry>.from(_logBuffer);
    _logBuffer.clear();

    try {
      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/collections/client_logs/records'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'logs': logsToSend.map((e) => e.toJson()).toList(),
              'batch_timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200 && response.statusCode != 201) {
        // If sending fails, log to console only (avoid infinite loop)
        if (kDebugMode) {
          debugPrint('Failed to send logs: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Silently fail - don't want logging to break the app
      if (kDebugMode) {
        debugPrint('Error sending logs: $e');
      }
    }
  }

  /// Dispose logging service
  void dispose() {
    _flushTimer?.cancel();
    flush();
  }
}

// Global logger instance
final logger = LoggingService();
