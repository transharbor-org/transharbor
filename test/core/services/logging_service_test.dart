import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/core/services/logging_service.dart';

void main() {
  group('LoggingService Tests', () {
    late LoggingService loggingService;

    setUp(() {
      loggingService = LoggingService();
    });

    test('creates singleton instance', () {
      final instance1 = LoggingService();
      final instance2 = LoggingService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('setUser updates current user', () {
      expect(() => loggingService.setUser('user123'), returnsNormally);
      expect(() => loggingService.setUser(null), returnsNormally);
    });

    test('setScreen updates current screen', () {
      expect(() => loggingService.setScreen('HomeScreen'), returnsNormally);
      expect(() => loggingService.setScreen(null), returnsNormally);
    });

    test('initialize accepts apiBaseUrl', () {
      expect(
        () => loggingService.initialize(apiBaseUrl: '/custom-api'),
        returnsNormally,
      );
      expect(() => loggingService.initialize(), returnsNormally);
    });

    test('debug logs without throwing', () {
      expect(
        () => loggingService.debug('Debug message'),
        returnsNormally,
      );
      expect(
        () => loggingService.debug(
          'Debug with metadata',
          metadata: {'key': 'value'},
        ),
        returnsNormally,
      );
    });

    test('info logs without throwing', () {
      expect(
        () => loggingService.info('Info message'),
        returnsNormally,
      );
      expect(
        () => loggingService.info(
          'Info with metadata',
          metadata: {'key': 'value'},
        ),
        returnsNormally,
      );
    });

    test('warning logs without throwing', () {
      expect(
        () => loggingService.warning('Warning message'),
        returnsNormally,
      );
    });

    test('error logs without throwing', () {
      expect(
        () => loggingService.error('Error message'),
        returnsNormally,
      );
      expect(
        () => loggingService.error(
          'Error with details',
          error: Exception('Test error'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });

    test('fatal logs without throwing', () {
      expect(
        () => loggingService.fatal('Fatal message'),
        returnsNormally,
      );
      expect(
        () => loggingService.fatal(
          'Fatal with details',
          error: Exception('Fatal error'),
        ),
        returnsNormally,
      );
    });

    test('dispose cleans up resources', () {
      expect(() => loggingService.dispose(), returnsNormally);
    });
  });

  group('LogEntry Tests', () {
    test('creates log entry with required fields', () {
      final entry = LogEntry(
        message: 'Test message',
        level: LogLevel.info,
        timestamp: DateTime.now(),
      );

      expect(entry.message, 'Test message');
      expect(entry.level, LogLevel.info);
      expect(entry.timestamp, isA<DateTime>());
    });

    test('creates log entry with optional fields', () {
      final timestamp = DateTime.now();
      final entry = LogEntry(
        message: 'Test message',
        level: LogLevel.error,
        timestamp: timestamp,
        metadata: {'key': 'value'},
        stackTrace: 'stack trace here',
        userId: 'user123',
        screen: 'HomeScreen',
      );

      expect(entry.metadata, {'key': 'value'});
      expect(entry.stackTrace, 'stack trace here');
      expect(entry.userId, 'user123');
      expect(entry.screen, 'HomeScreen');
    });

    test('toJson includes all fields', () {
      final timestamp = DateTime.now();
      final entry = LogEntry(
        message: 'Test message',
        level: LogLevel.warning,
        timestamp: timestamp,
        metadata: {'key': 'value'},
        stackTrace: 'stack trace',
        userId: 'user123',
        screen: 'ProfileScreen',
      );

      final json = entry.toJson();

      expect(json['message'], 'Test message');
      expect(json['level'], 'warning');
      expect(json['timestamp'], timestamp.toIso8601String());
      expect(json['metadata'], {'key': 'value'});
      expect(json['stackTrace'], 'stack trace');
      expect(json['userId'], 'user123');
      expect(json['screen'], 'ProfileScreen');
      expect(json['source'], 'flutter_web');
    });

    test('toJson excludes null optional fields', () {
      final entry = LogEntry(
        message: 'Test message',
        level: LogLevel.debug,
        timestamp: DateTime.now(),
      );

      final json = entry.toJson();

      expect(json.containsKey('metadata'), false);
      expect(json.containsKey('stackTrace'), false);
      expect(json.containsKey('userId'), false);
      expect(json.containsKey('screen'), false);
    });
  });

  group('LogLevel Enum Tests', () {
    test('has all log levels', () {
      expect(LogLevel.debug.name, 'debug');
      expect(LogLevel.info.name, 'info');
      expect(LogLevel.warning.name, 'warning');
      expect(LogLevel.error.name, 'error');
      expect(LogLevel.fatal.name, 'fatal');
    });

    test('log levels are ordered by severity', () {
      expect(LogLevel.debug.index < LogLevel.info.index, isTrue);
      expect(LogLevel.info.index < LogLevel.warning.index, isTrue);
      expect(LogLevel.warning.index < LogLevel.error.index, isTrue);
      expect(LogLevel.error.index < LogLevel.fatal.index, isTrue);
    });
  });
}
