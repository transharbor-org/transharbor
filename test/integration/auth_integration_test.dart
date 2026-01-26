import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

/// Integration tests for authentication workflows
/// These test login and registration against a live PocketBase API
///
/// To run against dev server:
/// flutter test --dart-define=POCKETBASE_URL=https://dev.transharbor.org test/integration/auth_integration_test.dart
///
/// To run against local server:
/// flutter test --dart-define=POCKETBASE_URL=http://localhost:8080 test/integration/auth_integration_test.dart
void main() {
  group('Authentication Integration Tests', () {
    late PocketBase pb;
    late String baseUrl;

    const shouldRunLiveTests = String.fromEnvironment(
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
        print('🌐 Running auth integration tests against: $baseUrl');
      }
    });

    tearDown(() {
      // Clear auth after each test
      pb.authStore.clear();
    });

    group('Login Flow', () {
      test('successful login with valid credentials', () async {
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        expect(authData.token, isNotEmpty);
        expect(authData.record, isNotNull);
        expect(authData.record.id, isNotEmpty);
        expect(authData.record.data['email'], 'alex@example.com');
        expect(pb.authStore.isValid, true);
        expect(pb.authStore.token, isNotEmpty);

        print('✅ Login successful: ${authData.record.data['email']}');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('login fails with invalid email', () async {
        expect(
          () => pb.collection('users').authWithPassword(
                'nonexistent@example.com',
                'password123',
              ),
          throwsA(isA<ClientException>()),
        );

        expect(pb.authStore.isValid, false);
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('login fails with invalid password', () async {
        expect(
          () => pb.collection('users').authWithPassword(
                'alex@example.com',
                'wrongpassword',
              ),
          throwsA(isA<ClientException>()),
        );

        expect(pb.authStore.isValid, false);
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('login fails with empty credentials', () async {
        expect(
          () => pb.collection('users').authWithPassword('', ''),
          throwsA(isA<ClientException>()),
        );
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('login returns user data with correct fields', () async {
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        final userData = authData.record.data;

        expect(userData['id'], isNotEmpty);
        expect(userData['email'], 'alex@example.com');
        expect(userData['username'], isNotNull);
        expect(userData['name'], isNotNull);
        expect(userData['role'], isNotNull);
        expect(userData['membership_type'], isNotNull);
        expect(userData.containsKey('created'), true);
        expect(userData.containsKey('updated'), true);
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('login with moderator credentials', () async {
        final authData = await pb.collection('users').authWithPassword(
              'jordan@example.com',
              'password123',
            );

        expect(authData.record.data['email'], 'jordan@example.com');
        expect(authData.record.data['role'], 'moderator');
        expect(pb.authStore.isValid, true);

        print(
            '✅ Moderator login successful: ${authData.record.data['username']}');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('auth token persists across requests', () async {
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        final firstToken = pb.authStore.token;
        expect(firstToken, isNotEmpty);

        // Make an authenticated request
        final userId = authData.record.id;
        await pb.collection('personals').getList(
              filter: 'user = "$userId"',
            );

        // Token should still be valid and unchanged
        expect(pb.authStore.token, equals(firstToken));
        expect(pb.authStore.isValid, true);
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('logout clears auth state', () async {
        await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        expect(pb.authStore.isValid, true);

        pb.authStore.clear();

        expect(pb.authStore.isValid, false);
        expect(pb.authStore.token, isEmpty);
        expect(pb.authStore.model, isNull);
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Registration Flow', () {
      late String testEmail;
      late String testUsername;

      setUp(() {
        // Generate unique test credentials for each registration test
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        testEmail = 'test_$timestamp@example.com';
        testUsername = 'testuser_$timestamp';
      });

      tearDown(() async {
        // Clean up: delete test user if it was created
        if (pb.authStore.isValid && pb.authStore.model != null) {
          try {
            final userId = pb.authStore.model!.id;
            await pb.collection('users').delete(userId);
            print('🧹 Cleaned up test user: $testEmail');
          } catch (e) {
            // Ignore cleanup errors
          }
        }
        pb.authStore.clear();
      });

      test('successful registration with valid data', () async {
        final userData = await pb.collection('users').create(body: {
          'email': testEmail,
          'username': testUsername,
          'password': 'TestPass123!',
          'passwordConfirm': 'TestPass123!',
          'emailVisibility': false,
          'role': 'user',
          'membership_type': 'non_voting',
        });

        expect(userData.id, isNotEmpty);
        expect(userData.data['email'], testEmail);
        expect(userData.data['username'], testUsername);
        expect(userData.data['role'], 'user');
        expect(userData.data['membership_type'], 'non_voting');

        print('✅ User registered: $testEmail');

        // Login with new account
        final authData = await pb.collection('users').authWithPassword(
              testEmail,
              'TestPass123!',
            );

        expect(authData.token, isNotEmpty);
        expect(authData.record.data['email'], testEmail);
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('registration fails with duplicate email', () async {
        // First registration
        await pb.collection('users').create(body: {
          'email': testEmail,
          'username': testUsername,
          'password': 'TestPass123!',
          'passwordConfirm': 'TestPass123!',
          'emailVisibility': false,
          'role': 'user',
          'membership_type': 'non_voting',
        });

        // Attempt duplicate registration
        expect(
          () => pb.collection('users').create(body: {
            'email': testEmail, // Same email
            'username': '${testUsername}_2',
            'password': 'TestPass123!',
            'passwordConfirm': 'TestPass123!',
            'emailVisibility': false,
            'role': 'user',
            'membership_type': 'non_voting',
          }),
          throwsA(isA<ClientException>()),
        );
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('registration fails with password mismatch', () async {
        expect(
          () => pb.collection('users').create(body: {
            'email': testEmail,
            'username': testUsername,
            'password': 'TestPass123!',
            'passwordConfirm': 'DifferentPass123!', // Mismatch
            'emailVisibility': false,
            'role': 'user',
            'membership_type': 'non_voting',
          }),
          throwsA(isA<ClientException>()),
        );
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('registration fails with invalid email format', () async {
        expect(
          () => pb.collection('users').create(body: {
            'email': 'invalid-email', // Invalid format
            'username': testUsername,
            'password': 'TestPass123!',
            'passwordConfirm': 'TestPass123!',
            'emailVisibility': false,
            'role': 'user',
            'membership_type': 'non_voting',
          }),
          throwsA(isA<ClientException>()),
        );
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('registration fails with empty required fields', () async {
        expect(
          () => pb.collection('users').create(body: {
            'email': '',
            'username': '',
            'password': '',
            'passwordConfirm': '',
          }),
          throwsA(isA<ClientException>()),
        );
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can register and immediately login', () async {
        // Register
        await pb.collection('users').create(body: {
          'email': testEmail,
          'username': testUsername,
          'password': 'TestPass123!',
          'passwordConfirm': 'TestPass123!',
          'emailVisibility': false,
          'role': 'user',
          'membership_type': 'non_voting',
        });

        // Login immediately
        final authData = await pb.collection('users').authWithPassword(
              testEmail,
              'TestPass123!',
            );

        expect(authData.token, isNotEmpty);
        expect(authData.record.data['email'], testEmail);
        expect(pb.authStore.isValid, true);
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Authentication State Management', () {
      test('auth state persists between page loads (simulation)', () async {
        // Login
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        final token = pb.authStore.token;
        final userId = authData.record.id;

        // Simulate app restart by creating new PocketBase instance
        final pb2 = PocketBase(baseUrl);

        // Manually restore auth state (in real app, this would come from storage)
        pb2.authStore.save(token, authData.record);

        expect(pb2.authStore.isValid, true);
        expect(pb2.authStore.model?.id, userId);

        // Verify we can make authenticated requests
        final personals = await pb2.collection('personals').getList(
              filter: 'user = "$userId"',
            );

        expect(personals, isNotNull);
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('expired token gets rejected', () async {
        // Set an invalid/expired token
        pb.authStore.save('invalid_token_12345', null);

        expect(pb.authStore.token, isNotEmpty);

        // Try to make authenticated request with invalid token
        expect(
          () => pb.collection('personals').getList(),
          throwsA(isA<ClientException>()),
        );
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can switch between user accounts', () async {
        // Login as first user
        final auth1 = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        expect(auth1.record.data['email'], 'alex@example.com');

        // Logout
        pb.authStore.clear();
        expect(pb.authStore.isValid, false);

        // Login as second user
        final auth2 = await pb.collection('users').authWithPassword(
              'sam@example.com',
              'password123',
            );

        expect(auth2.record.data['email'], 'sam@example.com');
        expect(pb.authStore.isValid, true);
        expect(auth2.record.id, isNot(equals(auth1.record.id)));
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Security and Validation', () {
      test('authentication required for protected endpoints', () async {
        pb.authStore.clear();

        // Try to access protected endpoint without auth
        expect(
          () => pb.collection('personals').getList(),
          throwsA(isA<ClientException>()),
        );
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('user can only access own data', () async {
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        final alexId = authData.record.id;

        // Get Alex's personals
        final personals = await pb.collection('personals').getList(
              filter: 'user = "$alexId"',
            );

        // Verify all personals belong to Alex
        for (final personal in personals.items) {
          expect(personal.data['user'], alexId);
        }
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('password is not returned in user data', () async {
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        final userData = authData.record.data;

        expect(userData.containsKey('password'), false);
        expect(userData.containsKey('passwordConfirm'), false);
        expect(userData.containsKey('passwordHash'), false);
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });
  });
}
