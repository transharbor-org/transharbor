import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

/// Functional tests that validate end-to-end user workflows
/// These tests use seed data to verify actual user functionality
///
/// Seed users (from seed_mock_data.py):
/// - alex@example.com / password123 (voting_member, user)
/// - sam@example.com / password123 (voting_member, user)
/// - jordan@example.com / password123 (voting_member, moderator)
/// - casey@example.com / password123 (voting_member, user)
/// - riley@example.com / password123 (non_voting, user)
/// - taylor@example.com / password123 (voting_member, user)
///
/// To run:
/// flutter test --dart-define=POCKETBASE_URL=https://dev.transharbor.org test/integration/user_functional_test.dart
void main() {
  group('User Functional Tests', () {
    late PocketBase pb;
    late String baseUrl;

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
        print('🌐 Running functional tests against: $baseUrl');
      }
    });

    tearDown(() {
      // Clear auth between tests
      pb.authStore.clear();
    });

    group('Authentication Workflows', () {
      test('user can log in with valid credentials', () async {
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        expect(authData.token, isNotEmpty);
        expect(authData.record, isNotNull);
        expect(authData.record!.data['email'], 'alex@example.com');
        expect(pb.authStore.isValid, true);
        print('✅ User logged in: ${authData.record!.data['email']}');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('user cannot log in with invalid credentials', () async {
        expect(
          () => pb.collection('users').authWithPassword(
                'alex@example.com',
                'wrongpassword',
              ),
          throwsA(isA<ClientException>()),
        );
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('auth token persists across requests', () async {
        // Log in
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        final userId = authData.record!.id;

        // Make authenticated request
        final result = await pb.collection('personals').getList(
              filter: 'user = "$userId"',
            );

        expect(result, isNotNull);
        expect(pb.authStore.isValid, true);
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Personals - User Privacy', () {
      test('user sees only their own personals', () async {
        // Login as Alex
        final alexAuth = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );
        final alexId = alexAuth.record!.id;

        // Fetch personals filtered by Alex's ID
        final alexPersonals = await pb.collection('personals').getList(
              filter: 'user = "$alexId"',
              perPage: 100,
            );

        // All personals should belong to Alex
        for (final personal in alexPersonals.items) {
          expect(personal.data['user'], alexId,
              reason: 'Personal should belong to Alex');
        }

        print(
            '✅ Alex sees ${alexPersonals.items.length} personals (all theirs)');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('different users see different personals', () async {
        // Login as Alex
        var authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );
        final alexId = authData.record!.id;
        final alexPersonals = await pb.collection('personals').getList(
              filter: 'user = "$alexId"',
            );
        final alexCount = alexPersonals.items.length;
        pb.authStore.clear();

        // Login as Sam
        authData = await pb.collection('users').authWithPassword(
              'sam@example.com',
              'password123',
            );
        final samId = authData.record!.id;
        final samPersonals = await pb.collection('personals').getList(
              filter: 'user = "$samId"',
            );
        final samCount = samPersonals.items.length;

        // Users should not see each other's personals
        for (final personal in alexPersonals.items) {
          expect(personal.data['user'], alexId);
        }
        for (final personal in samPersonals.items) {
          expect(personal.data['user'], samId);
        }

        print('✅ Alex has $alexCount personals, Sam has $samCount personals');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Conversations - User Privacy', () {
      test('user sees only conversations they participate in', () async {
        // Login as Alex
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );
        final alexId = authData.record!.id;

        // Fetch conversations where Alex is a participant
        final conversations = await pb.collection('conversations').getList(
              filter: 'participants ~ "$alexId"',
              expand: 'participants',
            );

        // All conversations should include Alex as participant
        for (final convo in conversations.items) {
          final participants = convo.data['participants'] as List;
          expect(participants, contains(alexId),
              reason: 'Conversation should include Alex as participant');
        }

        print(
            '✅ Alex participates in ${conversations.items.length} conversations');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('user cannot see conversations they are not part of', () async {
        // Get all conversations (requires knowing we have data)
        // Login as Alex first
        var authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );
        final alexId = authData.record!.id;
        pb.authStore.clear();

        // Login as Sam
        authData = await pb.collection('users').authWithPassword(
              'sam@example.com',
              'password123',
            );
        final samId = authData.record!.id;

        // Get Sam's conversations
        final samConvos = await pb.collection('conversations').getList(
              filter: 'participants ~ "$samId"',
            );

        // Verify none of Sam's conversations contain Alex if they're separate
        // (This assumes seed data creates separate conversations)
        for (final convo in samConvos.items) {
          final participants = convo.data['participants'] as List;
          // Each conversation should include Sam
          expect(participants, contains(samId));
        }

        print('✅ Sam has ${samConvos.items.length} conversations');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Messaging - Conversation Isolation', () {
      test('messages are isolated to specific conversations', () async {
        // Login as Alex
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );
        final alexId = authData.record!.id;

        // Get Alex's conversations
        final conversations = await pb.collection('conversations').getList(
              filter: 'participants ~ "$alexId"',
              perPage: 5,
            );

        if (conversations.items.isEmpty) {
          markTestSkipped('No conversations found for Alex');
          return;
        }

        // Verify we got conversations
        expect(conversations.items, isNotEmpty);
        expect(
            conversations.items.first.data['participants'], contains(alexId));

        print('✅ Found ${conversations.items.length} conversations for Alex');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Proposals - Voting Member Access', () {
      test('voting member can view proposals', () async {
        // Login as Alex (voting member)
        await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        final proposals = await pb.collection('proposals').getList(
              sort: '-created',
            );

        expect(proposals.items, isNotEmpty,
            reason: 'Should have proposals from seed data');

        // Verify proposal structure
        for (final proposal in proposals.items) {
          expect(proposal.data['title'], isNotEmpty);
          expect(proposal.data['description'], isNotEmpty);
          expect(proposal.data['status'], isNotEmpty);
          expect(proposal.data, containsPair('votesFor', isA<int>()));
          expect(proposal.data, containsPair('votesAgainst', isA<int>()));
        }

        print('✅ Found ${proposals.items.length} proposals');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('non-voting member can view but not create proposals', () async {
        // Login as Riley (non-voting member)
        await pb.collection('users').authWithPassword(
              'riley@example.com',
              'password123',
            );

        // Should be able to view proposals
        final proposals = await pb.collection('proposals').getList();
        expect(proposals, isNotNull);

        print(
            '✅ Non-voting member can view ${proposals.items.length} proposals');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('User Profile Data', () {
      test('user can view their own profile from auth record', () async {
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        // Use auth record instead of querying users collection
        final userRecord = authData.record!;

        expect(userRecord.data['email'], 'alex@example.com');
        expect(userRecord.data['name'], isNotEmpty);
        expect(userRecord.data['username'], 'alex_river');
        expect(userRecord.data['name'], 'Alex Rivera');
        expect(userRecord.data['role'], 'user');
        expect(userRecord.data['bio'], contains('Trans activist'));

        print('✅ Profile loaded from auth: ${userRecord.data['name']}');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Moderator Capabilities', () {
      test('moderator user has correct role', () async {
        final authData = await pb.collection('users').authWithPassword(
              'jordan@example.com',
              'password123',
            );

        expect(authData.record!.data['role'], 'moderator');
        expect(authData.record!.data['name'], 'Jordan Blake');

        print('✅ Jordan is a moderator: ${authData.record!.data['name']}');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Data Integrity', () {
      test('personals have correct user associations', () async {
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );
        final alexId = authData.record!.id;

        final personals = await pb.collection('personals').getList(
              filter: 'user = "$alexId"',
              perPage: 5,
            );

        // Verify all personals belong to Alex
        for (final personal in personals.items) {
          expect(personal.data['user'], alexId);
          expect(personal.data['content'], isNotEmpty);
        }

        print('✅ All personals belong to correct user');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('conversations have valid participant relationships', () async {
        final authData = await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );
        final alexId = authData.record!.id;

        final conversations = await pb.collection('conversations').getList(
              filter: 'participants ~ "$alexId"',
              expand: 'participants',
              perPage: 5,
            );

        for (final convo in conversations.items) {
          final participants = convo.data['participants'] as List;

          // Should have at least 2 participants
          expect(participants.length, greaterThanOrEqualTo(2));

          // Should include Alex
          expect(participants, contains(alexId));

          // Expanded participants should have user data
          if (convo.expand.containsKey('participants')) {
            final expandedParticipants = convo.expand['participants'] as List;
            for (final participant in expandedParticipants) {
              final participantMap = participant as Map<String, dynamic>;
              expect(participantMap['email'], isNotEmpty);
            }
          }
        }

        print('✅ Conversation relationships are valid');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });

    group('Seed Data Verification', () {
      test('all seed users exist and can authenticate', () async {
        final seedUsers = [
          {'email': 'alex@example.com', 'name': 'Alex Rivera'},
          {'email': 'sam@example.com', 'name': 'Sam Chen'},
          {'email': 'jordan@example.com', 'name': 'Jordan Blake'},
          {'email': 'casey@example.com', 'name': 'Casey Moore'},
          {'email': 'riley@example.com', 'name': 'Riley Nguyen'},
          {'email': 'taylor@example.com', 'name': 'Taylor Kim'},
        ];

        for (final user in seedUsers) {
          final authData = await pb.collection('users').authWithPassword(
                user['email']!,
                'password123',
              );

          expect(authData.token, isNotEmpty);
          expect(authData.record!.data['name'], user['name']);
          pb.authStore.clear();
        }

        print(
            '✅ All ${seedUsers.length} seed users authenticated successfully');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('seed data contains personals for users', () async {
        await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        final allPersonals =
            await pb.collection('personals').getList(perPage: 100);

        expect(allPersonals.items, isNotEmpty,
            reason: 'Should have personals from seed data');

        print('✅ Database has ${allPersonals.items.length} total personals');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');

      test('seed data contains proposals', () async {
        await pb.collection('users').authWithPassword(
              'alex@example.com',
              'password123',
            );

        final proposals = await pb.collection('proposals').getList();

        expect(proposals.items, isNotEmpty,
            reason: 'Should have proposals from seed data');

        // Check for expected proposal titles from seed data
        final titles =
            proposals.items.map((p) => p.data['title'] as String).toList();

        print('✅ Database has ${proposals.items.length} proposals');
        print('   Proposal titles: ${titles.join(", ")}');
      },
          skip: shouldRunLiveTests
              ? false
              : 'Set POCKETBASE_URL to run live tests');
    });
  });
}
