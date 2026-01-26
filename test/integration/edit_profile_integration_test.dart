import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

/// Integration tests for Edit Profile screen functionality
/// Tests profile editing with live PocketBase backend
///
/// To run:
/// flutter test --dart-define=POCKETBASE_URL=https://dev.transharbor.org test/integration/edit_profile_integration_test.dart
void main() {
  group('Edit Profile Integration Tests', () {
    late PocketBase pb;
    late String baseUrl;
    late String testUserId;
    late String originalDisplayName;
    late String originalBio;
    late String originalPronouns;
    late bool originalIsPrivate;

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
        print('🌐 Running edit profile tests against: $baseUrl');
      }
    });

    setUp(() async {
      if (shouldRunLiveTests) {
        // Login as test user
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );
        testUserId = authData.record.id;

        // Store original values to restore later
        originalDisplayName = authData.record.data['name'] ?? '';
        originalBio = authData.record.data['bio'] ?? '';
        originalPronouns = authData.record.data['pronouns'] ?? '';
        originalIsPrivate = authData.record.data['isPrivate'] ?? false;
      }
    });

    tearDown(() async {
      if (shouldRunLiveTests) {
        // Restore original values
        try {
          await pb.collection('users').update(testUserId, body: {
            'name': originalDisplayName,
            'bio': originalBio,
            'pronouns': originalPronouns,
            'isPrivate': originalIsPrivate,
          });
        } catch (e) {
          print('⚠️  Failed to restore original values: $e');
        }
        pb.authStore.clear();
      }
    });

    group('Display Name Editing', () {
      test('can update display name', () async {
        const newName = 'Test Display Name';

        // Update display name
        final updated = await pb.collection('users').update(testUserId, body: {
          'name': newName,
        });

        expect(updated.data['name'], newName);
        print('✅ Display name updated to: $newName');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can set empty display name', () async {
        // Backend allows empty name
        final updated = await pb.collection('users').update(testUserId, body: {
          'name': '',
        });

        expect(updated.data['name'], '');
        print('✅ Empty display name allowed');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('accepts long display names', () async {
        final longName = 'A' * 100;

        // Backend doesn't enforce char limits on name
        final updated = await pb.collection('users').update(testUserId, body: {
          'name': longName,
        });

        expect(updated.data['name'], longName);
        expect(updated.data['name'].toString().length, 100);
        print('✅ Long display name accepted (100 chars)');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Pronouns Editing', () {
      test('can update pronouns', () async {
        const newPronouns = 'he/him';

        final updated = await pb.collection('users').update(testUserId, body: {
          'pronouns': newPronouns,
        });

        expect(updated.data['pronouns'], newPronouns);
        print('✅ Pronouns updated to: $newPronouns');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can clear pronouns', () async {
        final updated = await pb.collection('users').update(testUserId, body: {
          'pronouns': '',
        });

        expect(updated.data['pronouns'], '');
        print('✅ Pronouns cleared successfully');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('pronouns respect character limit', () async {
        final longPronouns = 'A' * 100; // Exceeds 50 char limit

        try {
          await pb.collection('users').update(testUserId, body: {
            'pronouns': longPronouns,
          });
          final record = await pb.collection('users').getOne(testUserId);
          expect(
              record.data['pronouns'].toString().length, lessThanOrEqualTo(50));
          print('✅ Long pronouns handled correctly');
        } catch (e) {
          expect(e, isA<ClientException>());
          print('✅ Long pronouns rejected as expected');
        }
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Bio Editing', () {
      test('can update bio', () async {
        const newBio = 'This is my updated bio for testing.';

        final updated = await pb.collection('users').update(testUserId, body: {
          'bio': newBio,
        });

        expect(updated.data['bio'], newBio);
        print('✅ Bio updated to: $newBio');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can clear bio', () async {
        final updated = await pb.collection('users').update(testUserId, body: {
          'bio': '',
        });

        expect(updated.data['bio'], '');
        print('✅ Bio cleared successfully');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can update bio with long text', () async {
        final longBio = 'A' * 400; // Under 500 char limit

        final updated = await pb.collection('users').update(testUserId, body: {
          'bio': longBio,
        });

        expect(updated.data['bio'], longBio);
        expect(updated.data['bio'].toString().length, 400);
        print('✅ Long bio (400 chars) accepted');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('bio respects character limit', () async {
        final tooLongBio = 'A' * 600; // Exceeds 500 char limit

        try {
          await pb.collection('users').update(testUserId, body: {
            'bio': tooLongBio,
          });
          final record = await pb.collection('users').getOne(testUserId);
          expect(record.data['bio'].toString().length, lessThanOrEqualTo(500));
          print('✅ Too long bio handled correctly');
        } catch (e) {
          expect(e, isA<ClientException>());
          print('✅ Too long bio rejected as expected');
        }
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Privacy Settings', () {
      test('can set profile to private', () async {
        final updated = await pb.collection('users').update(testUserId, body: {
          'isPrivate': true,
        });

        expect(updated.data['isPrivate'], true);
        print('✅ Profile set to private');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can set profile to public', () async {
        // First set to private
        await pb.collection('users').update(testUserId, body: {
          'isPrivate': true,
        });

        // Then set to public
        final updated = await pb.collection('users').update(testUserId, body: {
          'isPrivate': false,
        });

        expect(updated.data['isPrivate'], false);
        print('✅ Profile set to public');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('privacy setting persists after other updates', () async {
        // Set to private
        await pb.collection('users').update(testUserId, body: {
          'isPrivate': true,
        });

        // Update other fields
        await pb.collection('users').update(testUserId, body: {
          'name': 'Updated Name',
          'bio': 'Updated Bio',
        });

        // Check privacy is still private
        final record = await pb.collection('users').getOne(testUserId);
        expect(record.data['isPrivate'], true);
        print('✅ Privacy setting persisted');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Multiple Field Updates', () {
      test('can update all profile fields at once', () async {
        const newName = 'Complete Update Test';
        const newBio = 'Updated bio for complete test';
        const newPronouns = 'ze/zir';
        const newIsPrivate = true;

        final updated = await pb.collection('users').update(testUserId, body: {
          'name': newName,
          'bio': newBio,
          'pronouns': newPronouns,
          'isPrivate': newIsPrivate,
        });

        expect(updated.data['name'], newName);
        expect(updated.data['bio'], newBio);
        expect(updated.data['pronouns'], newPronouns);
        expect(updated.data['isPrivate'], newIsPrivate);
        print('✅ All fields updated successfully');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('partial updates only change specified fields', () async {
        // Get current state
        final before = await pb.collection('users').getOne(testUserId);
        final originalBio = before.data['bio'];

        // Update only name
        await pb.collection('users').update(testUserId, body: {
          'name': 'New Name Only',
        });

        // Check bio wasn't changed
        final after = await pb.collection('users').getOne(testUserId);
        expect(after.data['name'], 'New Name Only');
        expect(after.data['bio'], originalBio);
        print('✅ Partial update preserved other fields');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Data Validation', () {
      test('updated timestamp changes after edit', () async {
        final before = await pb.collection('users').getOne(testUserId);
        final beforeUpdated = DateTime.parse(before.updated);

        // Wait a bit to ensure timestamp difference
        await Future.delayed(const Duration(milliseconds: 100));

        // Make an update
        await pb.collection('users').update(testUserId, body: {
          'name': 'Timestamp Test',
        });

        final after = await pb.collection('users').getOne(testUserId);
        final afterUpdated = DateTime.parse(after.updated);

        expect(afterUpdated.isAfter(beforeUpdated), true);
        print('✅ Updated timestamp changes correctly');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can retrieve updated data immediately', () async {
        const testValue = 'Immediate Retrieval Test';

        // Update
        await pb.collection('users').update(testUserId, body: {
          'name': testValue,
        });

        // Immediately retrieve
        final record = await pb.collection('users').getOne(testUserId);

        expect(record.data['name'], testValue);
        print('✅ Updated data retrievable immediately');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('auth refresh returns updated data', () async {
        const testValue = 'Auth Refresh Test';

        // Update via API
        await pb.collection('users').update(testUserId, body: {
          'name': testValue,
        });

        // Refresh auth
        await pb.collection('users').authRefresh();

        // Check auth record has new value
        final authRecord = pb.authStore.model;
        expect(authRecord!.data['name'], testValue);
        print('✅ Auth refresh returns updated data');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Authorization', () {
      test('user can only update own profile', () async {
        // Try to update another user's profile
        const otherUserId = 'different-user-id';

        try {
          await pb.collection('users').update(otherUserId, body: {
            'name': 'Unauthorized Update',
          });
          fail('Should not allow updating other user profiles');
        } catch (e) {
          expect(e, isA<ClientException>());
          final exception = e as ClientException;
          expect(exception.statusCode, anyOf(403, 404));
          print('✅ Cannot update other user profiles');
        }
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('unauthenticated user cannot update profiles', () async {
        // Clear auth
        pb.authStore.clear();

        try {
          await pb.collection('users').update(testUserId, body: {
            'name': 'Unauthenticated Update',
          });
          fail('Should not allow unauthenticated updates');
        } catch (e) {
          expect(e, isA<ClientException>());
          final exception = e as ClientException;
          // Backend returns 404 when unauthenticated
          expect(exception.statusCode, anyOf(401, 403, 404));
          print('✅ Unauthenticated updates rejected');
        } finally {
          // Re-authenticate for tearDown
          await pb.collection('users').authWithPassword(
                'alex@example.com',
                'password123',
              );
        }
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Special Characters and Edge Cases', () {
      test('can use special characters in bio', () async {
        const specialBio =
            'Testing special chars: @#\$%^&*()_+-=[]{}|;:\'"<>,.?/~`';

        final updated = await pb.collection('users').update(testUserId, body: {
          'bio': specialBio,
        });

        expect(updated.data['bio'], specialBio);
        print('✅ Special characters in bio accepted');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can use emojis in profile fields', () async {
        const emojiName = 'Alex 🏳️‍⚧️ Smith';
        const emojiPronouns = '✨ they/them ✨';
        const emojiBio = 'Trans rights are human rights! 🏳️‍⚧️💜';

        final updated = await pb.collection('users').update(testUserId, body: {
          'name': emojiName,
          'pronouns': emojiPronouns,
          'bio': emojiBio,
        });

        expect(updated.data['name'], emojiName);
        expect(updated.data['pronouns'], emojiPronouns);
        expect(updated.data['bio'], emojiBio);
        print('✅ Emojis in profile fields accepted');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('can use unicode characters', () async {
        const unicodeName = 'Søren Kierkegaard';
        const unicodeBio = 'Привет мир 你好世界 مرحبا بالعالم';

        final updated = await pb.collection('users').update(testUserId, body: {
          'name': unicodeName,
          'bio': unicodeBio,
        });

        expect(updated.data['name'], unicodeName);
        expect(updated.data['bio'], unicodeBio);
        print('✅ Unicode characters accepted');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('handles multiline bio', () async {
        const multilineBio = '''
This is a multiline bio.
It has several lines.
Each line tells a story.
''';

        final updated = await pb.collection('users').update(testUserId, body: {
          'bio': multilineBio,
        });

        expect(updated.data['bio'], multilineBio);
        expect(updated.data['bio'].toString().contains('\n'), true);
        print('✅ Multiline bio accepted');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });
  });
}
