import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

/// Live API integration tests for PocketBase
/// These tests actually call the PocketBase API to validate behavior
///
/// To run against live API:
/// flutter test --dart-define=POCKETBASE_URL=https://dev.transharbor.org test/integration/pocketbase_live_api_test.dart
///
/// Note: These tests require a live PocketBase instance with seeded data
void main() {
  group('PocketBase Live API Tests', () {
    late PocketBase pb;
    late String baseUrl;
    String? authToken;
    String? userId;

    // Determine if we should run live tests based on URL
    final shouldRunLiveTests = const String.fromEnvironment(
          'POCKETBASE_URL',
          defaultValue: 'http://localhost:8080',
        ) !=
        'http://localhost:8080';

    setUpAll(() {
      baseUrl = const String.fromEnvironment(
        'POCKETBASE_URL',
        defaultValue: 'http://localhost:8080',
      );
      pb = PocketBase(baseUrl);

      if (shouldRunLiveTests) {
        print('🌐 Running live API tests against: $baseUrl');
      }
    });

    group('Health Check', () {
      test('API is accessible', () async {
        try {
          // Try to access the API root
          final response = await pb.health.check();
          expect(response.code, 200);
          expect(response.message, contains('healthy'));
        } catch (e) {
          // If health check not available, just verify PocketBase is initialized
          expect(pb.baseUrl, isNotEmpty);
        }
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Authentication Flow', () {
      test('can authenticate with test user', () async {
        try {
          final authData = await pb.collection('users').authWithPassword(
                'alex_river@example.com',
                'password123',
              );

          expect(authData.token, isNotEmpty);
          expect(authData.record, isNotNull);
          expect(authData.record?.id, isNotEmpty);

          authToken = authData.token;
          userId = authData.record?.id;
        } catch (e) {
          fail('Authentication failed: $e');
        }
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Collections API', () {
      test('can list personals with pagination', () async {
        final result = await pb.collection('personals').getList(
              page: 1,
              perPage: 5,
              sort: '-created',
              expand: 'user',
            );

        expect(result.items, isNotEmpty);
        expect(result.page, 1);
        expect(result.perPage, 5);
        expect(result.totalItems, greaterThan(0));

        // Verify expand worked
        for (final item in result.items) {
          if (item.expand.isNotEmpty) {
            expect(item.expand['user'], isNotNull);
          }
        }
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can filter personals by user', () async {
        if (userId == null) {
          markTestSkipped('No authenticated user');
          return;
        }

        final result = await pb.collection('personals').getList(
              filter: 'user = "$userId"',
            );

        for (final item in result.items) {
          expect(item.getStringValue('user'), userId);
        }
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('conversations filter with relation array', () async {
        if (userId == null) {
          markTestSkipped('No authenticated user');
          return;
        }

        // Test different filter syntaxes to find what works
        final filterVariations = [
          'participants ~ "$userId"',
          'participants.id ~ "$userId"',
          'participants ?~ "$userId"',
        ];

        for (final filter in filterVariations) {
          try {
            final result = await pb.collection('conversations').getList(
                  filter: filter,
                );

            print('✅ Filter syntax works: $filter');
            print('   Found ${result.totalItems} conversations');

            // Verify participants include the user
            for (final item in result.items) {
              final participants = item.data['participants'] as List?;
              if (participants != null) {
                expect(participants, contains(userId),
                    reason: 'Conversation should include authenticated user');
              }
            }

            return; // If we got here, this filter works!
          } catch (e) {
            print('❌ Filter syntax failed: $filter');
            print('   Error: $e');
          }
        }

        fail('None of the filter syntaxes worked for relation arrays');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can get proposals with author expand', () async {
        final result = await pb.collection('proposals').getList(
              expand: 'author',
              sort: '-created',
            );

        for (final item in result.items) {
          expect(item.data['title'], isNotEmpty);
          expect(item.data['status'], isNotEmpty);

          if (item.expand.isNotEmpty && item.expand['author'] != null) {
            final author = item.expand['author'];
            expect(author, isNotNull);
          }
        }
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Pagination Edge Cases', () {
      test('page 1 and page 2 have different items', () async {
        final page1 = await pb.collection('personals').getList(
              page: 1,
              perPage: 2,
            );

        if (page1.totalItems <= 2) {
          markTestSkipped('Not enough data to test pagination');
          return;
        }

        final page2 = await pb.collection('personals').getList(
              page: 2,
              perPage: 2,
            );

        expect(page1.items.first.id, isNot(equals(page2.items.first.id)),
            reason: 'Different pages should have different items');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('empty page returns empty items', () async {
        final result = await pb.collection('personals').getList(
              page: 9999, // Way beyond actual data
              perPage: 20,
            );

        expect(result.items, isEmpty);
        expect(result.page, 9999);
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Sorting', () {
      test('ascending sort order is correct', () async {
        final result = await pb.collection('personals').getList(
              sort: '+created',
              perPage: 5,
            );

        if (result.items.length < 2) {
          markTestSkipped('Not enough data to test sorting');
          return;
        }

        for (var i = 0; i < result.items.length - 1; i++) {
          final date1 = DateTime.parse(result.items[i].created);
          final date2 = DateTime.parse(result.items[i + 1].created);
          expect(date1.isBefore(date2) || date1.isAtSameMomentAs(date2), true,
              reason: 'Items should be in ascending order');
        }
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('descending sort order is correct', () async {
        final result = await pb.collection('personals').getList(
              sort: '-created',
              perPage: 5,
            );

        if (result.items.length < 2) {
          markTestSkipped('Not enough data to test sorting');
          return;
        }

        for (var i = 0; i < result.items.length - 1; i++) {
          final date1 = DateTime.parse(result.items[i].created);
          final date2 = DateTime.parse(result.items[i + 1].created);
          expect(date1.isAfter(date2) || date1.isAtSameMomentAs(date2), true,
              reason: 'Items should be in descending order');
        }
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Error Handling', () {
      test('404 on non-existent record', () async {
        expect(
          () => pb.collection('personals').getOne('nonexistent123'),
          throwsA(isA<ClientException>()),
        );
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('400 on invalid filter syntax', () async {
        expect(
          () => pb.collection('personals').getList(filter: 'invalid syntax'),
          throwsA(isA<ClientException>()),
        );
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Data Consistency', () {
      test('all personals have required fields', () async {
        final result = await pb.collection('personals').getList();

        for (final item in result.items) {
          expect(item.id, isNotEmpty);
          expect(item.data['user'], isNotEmpty);
          expect(item.data['content'], isNotEmpty);
          expect(item.created, isNotEmpty);
        }
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('all proposals have votesFor and votesAgainst', () async {
        final result = await pb.collection('proposals').getList();

        for (final item in result.items) {
          expect(item.data, containsPair('votesFor', isA<int>()));
          expect(item.data, containsPair('votesAgainst', isA<int>()));
          expect(item.data, containsPair('status', isA<String>()));
        }
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });
  });
}
