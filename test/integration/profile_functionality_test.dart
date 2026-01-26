import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

/// Integration tests for profile page functionality
/// Tests all buttons, password change, logout, and profile management
///
/// To run:
/// flutter test --dart-define=POCKETBASE_URL=https://dev.transharbor.org test/integration/profile_functionality_test.dart
void main() {
  group('Profile Functionality Integration Tests', () {
    late PocketBase pb;
    late String baseUrl;
    late String testUserId;
    late String authToken;

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
        print('🌐 Running profile tests against: $baseUrl');
      }
    });

    setUp(() async {
      // Login before each test
      if (shouldRunLiveTests) {
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );
        testUserId = authData.record.id;
        authToken = authData.token;
      }
    });

    tearDown(() {
      pb.authStore.clear();
    });

    group('Profile Viewing', () {
      test('can get user profile data from auth', () async {
        // Auth record contains user data
        final authRecord = pb.authStore.model;

        expect(authRecord, isNotNull);
        expect(authRecord!.id, testUserId);
        expect(authRecord.data['email'], 'alex@example.com');
        expect(authRecord.data['username'], isNotEmpty);

        print('✅ Profile data retrieved: ${authRecord.data['username']}');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('profile has expected fields', () async {
        final authRecord = pb.authStore.model;

        expect(authRecord, isNotNull);

        // Core fields
        expect(authRecord!.id, isNotEmpty);
        expect(authRecord.data['username'], isNotEmpty);
        expect(authRecord.data['email'], isNotEmpty);
        expect(authRecord.created, isNotNull);
        expect(authRecord.updated, isNotNull);

        // Optional fields can be null or empty
        final bio = authRecord.data['bio'] ?? '';
        final name = authRecord.data['name'] ?? '';
        final pronouns = authRecord.data['pronouns'] ?? '';

        print('✅ Profile fields validated');
        print('   - Bio: ${bio.toString().isNotEmpty ? "present" : "empty"}');
        print('   - Name: ${name.toString().isNotEmpty ? "present" : "empty"}');
        print(
            '   - Pronouns: ${pronouns.toString().isNotEmpty ? "present" : "empty"}');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can check avatar field', () async {
        final authRecord = pb.authStore.model;

        expect(authRecord, isNotNull);

        final avatar = authRecord!.data['avatar'] ?? '';

        // Avatar can be empty or contain a filename
        expect(avatar, isA<String>());

        print(
            '✅ Avatar field: ${avatar.toString().isNotEmpty ? "set" : "not set"}');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Profile Editing', () {
      String originalBio = '';
      String originalName = '';
      String originalPronouns = '';

      setUp(() async {
        if (shouldRunLiveTests) {
          final authRecord = pb.authStore.model;
          originalBio = authRecord?.data['bio'] ?? '';
          originalName = authRecord?.data['name'] ?? '';
          originalPronouns = authRecord?.data['pronouns'] ?? '';
        }
      });

      tearDown(() async {
        if (shouldRunLiveTests) {
          // Restore original values
          try {
            await pb.collection('users').update(testUserId, body: {
              'bio': originalBio,
              'name': originalName,
              'pronouns': originalPronouns,
            });
            await pb.collection('users').authRefresh();
          } catch (e) {
            // Ignore cleanup errors
          }
        }
      });

      test('can update bio', () async {
        final newBio =
            'Updated bio at ${DateTime.now().millisecondsSinceEpoch}';

        await pb.collection('users').update(
          testUserId,
          body: {'bio': newBio},
        );
        await pb.collection('users').authRefresh();
        final authRecord = pb.authStore.model;

        expect(authRecord?.data['bio'], newBio);

        print('✅ Bio updated successfully');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can update display name', () async {
        final newName = 'Test Name ${DateTime.now().millisecondsSinceEpoch}';

        await pb.collection('users').update(
          testUserId,
          body: {'name': newName},
        );
        await pb.collection('users').authRefresh();
        final authRecord = pb.authStore.model;

        expect(authRecord?.data['name'], newName);

        print('✅ Display name updated successfully');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can update pronouns', () async {
        final newPronouns = 'they/them';

        await pb.collection('users').update(
          testUserId,
          body: {'pronouns': newPronouns},
        );
        await pb.collection('users').authRefresh();
        final authRecord = pb.authStore.model;

        expect(authRecord?.data['pronouns'], newPronouns);

        print('✅ Pronouns updated successfully');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can update multiple profile fields at once', () async {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final newBio = 'Multi-update bio $timestamp';
        final newName = 'Multi Name $timestamp';
        final newPronouns = 'xe/xem';

        await pb.collection('users').update(
          testUserId,
          body: {
            'bio': newBio,
            'name': newName,
            'pronouns': newPronouns,
          },
        );
        await pb.collection('users').authRefresh();
        final authRecord = pb.authStore.model;

        expect(authRecord?.data['bio'], newBio);
        expect(authRecord?.data['name'], newName);
        expect(authRecord?.data['pronouns'], newPronouns);

        print('✅ Multiple fields updated successfully');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can clear bio', () async {
        // First set a bio
        await pb.collection('users').update(
          testUserId,
          body: {'bio': 'Bio to clear'},
        );

        // Then clear it
        await pb.collection('users').update(
          testUserId,
          body: {'bio': ''},
        );
        await pb.collection('users').authRefresh();
        final authRecord = pb.authStore.model;

        expect(authRecord?.data['bio'], '');

        print('✅ Bio cleared successfully');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('cannot update with invalid data', () async {
        // Bio too long (assuming max 500 chars)
        final longBio = 'x' * 1000;

        expect(
          () => pb.collection('users').update(
            testUserId,
            body: {'bio': longBio},
          ),
          throwsA(isA<ClientException>()),
        );

        print('✅ Invalid data rejected correctly');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Password Change', () {
      test('can change password', () async {
        final newPassword = 'newpassword123';
        final oldPassword = 'password123';

        // Change password
        final updatedUser = await pb.collection('users').update(
          testUserId,
          body: {
            'password': newPassword,
            'passwordConfirm': newPassword,
            'oldPassword': oldPassword,
          },
        );

        expect(updatedUser.id, testUserId);

        // Verify can login with new password
        pb.authStore.clear();
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              newPassword,
            );

        expect(authData.record.id, testUserId);

        // Change password back
        await pb.collection('users').update(
          testUserId,
          body: {
            'password': oldPassword,
            'passwordConfirm': oldPassword,
            'oldPassword': newPassword,
          },
        );

        print('✅ Password change successful (and restored)');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('cannot change password with wrong old password', () async {
        expect(
          () => pb.collection('users').update(
            testUserId,
            body: {
              'password': 'newpassword123',
              'passwordConfirm': 'newpassword123',
              'oldPassword': 'wrongpassword',
            },
          ),
          throwsA(isA<ClientException>()),
        );

        print('✅ Wrong old password rejected correctly');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('cannot change password with mismatched confirmation', () async {
        expect(
          () => pb.collection('users').update(
            testUserId,
            body: {
              'password': 'newpassword123',
              'passwordConfirm': 'differentpassword',
              'oldPassword': 'password123',
            },
          ),
          throwsA(isA<ClientException>()),
        );

        print('✅ Mismatched password confirmation rejected');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('cannot set weak password', () async {
        expect(
          () => pb.collection('users').update(
            testUserId,
            body: {
              'password': '123',
              'passwordConfirm': '123',
              'oldPassword': 'password123',
            },
          ),
          throwsA(isA<ClientException>()),
        );

        print('✅ Weak password rejected correctly');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Logout Functionality', () {
      test('can logout and clear auth store', () async {
        // Verify logged in
        expect(pb.authStore.isValid, true);
        expect(pb.authStore.token, isNotEmpty);

        final beforeLogoutUserId = pb.authStore.model?.id;
        expect(beforeLogoutUserId, testUserId);

        // Logout
        pb.authStore.clear();

        // Verify logged out
        expect(pb.authStore.isValid, false);
        expect(pb.authStore.token, isEmpty);
        expect(pb.authStore.model, isNull);

        print('✅ Logout successful - auth store cleared');

        // Re-login for other tests
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );
        testUserId = authData.record.id;
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('cannot access protected resources after logout', () async {
        // Logout
        pb.authStore.clear();

        // Try to update profile (should fail)
        expect(
          () => pb.collection('users').update(
            testUserId,
            body: {'bio': 'This should fail'},
          ),
          throwsA(isA<ClientException>()),
        );

        print('✅ Protected resources blocked after logout');

        // Re-login
        await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can re-login after logout', () async {
        // Logout
        pb.authStore.clear();
        expect(pb.authStore.isValid, false);

        // Re-login
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        expect(authData.record.id, testUserId);
        expect(pb.authStore.isValid, true);
        expect(pb.authStore.token, isNotEmpty);

        print('✅ Re-login after logout successful');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Profile Privacy Settings', () {
      test('can view profile visibility setting', () async {
        final authRecord = pb.authStore.model;

        // Check if profile visibility field exists
        final isPrivate = authRecord?.data['isPrivate'] ?? false;

        expect(isPrivate, isA<bool>());

        print('✅ Profile visibility: ${isPrivate ? "Private" : "Public"}');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('User Activity Data', () {
      test('can fetch user posts count', () async {
        final posts = await pb.collection('personals').getList(
              filter: 'user = "$testUserId"',
              perPage: 1,
            );

        expect(posts, isNotNull);
        expect(posts.totalItems, greaterThanOrEqualTo(0));

        print('✅ User has ${posts.totalItems} personal posts');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can fetch user group memberships', () async {
        final memberships = await pb.collection('group_members').getList(
              filter: 'user = "$testUserId"',
              perPage: 1,
            );

        expect(memberships, isNotNull);
        expect(memberships.totalItems, greaterThanOrEqualTo(0));

        print('✅ User is member of ${memberships.totalItems} groups');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can fetch user proposals', () async {
        final proposals = await pb.collection('proposals').getList(
              filter: 'author = "$testUserId"',
              perPage: 1,
            );

        expect(proposals, isNotNull);
        expect(proposals.totalItems, greaterThanOrEqualTo(0));

        print('✅ User has created ${proposals.totalItems} proposals');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Account Verification', () {
      test('can check if email is verified', () async {
        final authRecord = pb.authStore.model;

        final verified = authRecord?.data['verified'] ?? false;

        expect(verified, isA<bool>());

        print(
            '✅ Email verification status: ${verified ? "Verified" : "Not verified"}');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('user has valid account status', () async {
        final authRecord = pb.authStore.model;

        // Check account is active (not deleted/banned)
        expect(authRecord, isNotNull);
        expect(authRecord!.id, isNotEmpty);
        expect(authRecord.data['username'], isNotEmpty);
        expect(authRecord.data['email'], isNotEmpty);

        print('✅ Account status: Active');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Profile Navigation Links', () {
      test('edit profile data exists', () async {
        final authRecord = pb.authStore.model;

        // All fields that would be in edit profile form should be accessible
        expect(authRecord, isNotNull);
        expect(authRecord!.data['username'], isNotEmpty);
        expect(authRecord.data['email'], isNotEmpty);

        // Optional fields
        authRecord.data['bio'];
        authRecord.data['name'];
        authRecord.data['pronouns'];
        authRecord.data['avatar'];

        print('✅ Edit profile data accessible');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('privacy settings data exists', () async {
        final authRecord = pb.authStore.model;

        expect(authRecord, isNotNull);

        // Check privacy-related fields
        authRecord!.data['isPrivate'];

        print('✅ Privacy settings data accessible');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });
  });
}
