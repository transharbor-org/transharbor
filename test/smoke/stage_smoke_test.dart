import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Smoke tests to verify staging environment is functional
/// Run with: flutter test test/smoke/stage_smoke_test.dart --dart-define=STAGE_URL=https://stage.transharbor.org
void main() {
  final stageUrl = const String.fromEnvironment(
    'STAGE_URL',
    defaultValue: 'https://stage.transharbor.org',
  );
  
  final pbUrl = const String.fromEnvironment(
    'STAGE_PB_URL',
    defaultValue: 'https://pb-stage.transharbor.org',
  );

  group('Stage Environment Smoke Tests', () {
    test('Web app is accessible', () async {
      final response = await http.get(Uri.parse(stageUrl));
      expect(response.statusCode, 200);
      expect(response.body, contains('transharbor'));
    });

    test('PocketBase health check', () async {
      final response = await http.get(Uri.parse('$pbUrl/api/health'));
      expect(response.statusCode, 200);
    });

    test('PocketBase collections exist', () async {
      // Check that we can reach the collections endpoint
      final response = await http.get(
        Uri.parse('$pbUrl/api/collections'),
        headers: {'Content-Type': 'application/json'},
      );
      
      // Should return 401 (unauthorized) but endpoint exists
      expect(response.statusCode, anyOf(200, 401, 403));
    });

    test('Phone verification collection accessible', () async {
      // Verify phone_verification collection endpoint exists
      final response = await http.get(
        Uri.parse('$pbUrl/api/collections/phone_verification/records'),
      );
      
      // Should return 401 (unauthorized) but endpoint exists
      expect(response.statusCode, anyOf(401, 403));
    });

    test('Users collection accessible', () async {
      final response = await http.get(
        Uri.parse('$pbUrl/api/collections/users/records'),
      );
      
      // Should return 401 (unauthorized) but endpoint exists  
      expect(response.statusCode, anyOf(401, 403));
    });
  });

  group('Stage Environment Performance', () {
    test('Web app loads within 3 seconds', () async {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(Uri.parse(stageUrl));
      stopwatch.stop();
      
      expect(response.statusCode, 200);
      expect(stopwatch.elapsedMilliseconds, lessThan(3000),
          reason: 'Web app took ${stopwatch.elapsedMilliseconds}ms to load');
    });

    test('PocketBase API responds within 1 second', () async {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(Uri.parse('$pbUrl/api/health'));
      stopwatch.stop();
      
      expect(response.statusCode, 200);
      expect(stopwatch.elapsedMilliseconds, lessThan(1000),
          reason: 'PocketBase took ${stopwatch.elapsedMilliseconds}ms to respond');
    });
  });
}
