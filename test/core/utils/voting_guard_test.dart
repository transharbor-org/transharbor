import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/core/models/user.dart';
import 'package:transharbor/core/models/membership_type.dart';
import 'package:transharbor/core/utils/voting_guard.dart';
import 'package:transharbor/features/auth/providers/auth_provider.dart';

void main() {
  group('VotingGuard',
      skip:
          'Requires platform plugin (flutter_secure_storage) not available in unit tests',
      () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    Widget createTestWidget(Widget child) {
      return ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp(home: child),
      );
    }

    group('canVote', () {
      testWidgets('returns true for voting members', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'voter@example.com',
          membershipType: MembershipType.votingMember,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = VotingGuard.canVote(context);
              return Container();
            },
          )),
        );

        expect(result, true);
      });

      testWidgets('returns false for non-voting members', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'nonvoter@example.com',
          membershipType: MembershipType.nonVoting,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = VotingGuard.canVote(context);
              return Container();
            },
          )),
        );

        expect(result, false);
      });

      testWidgets('returns false when no user', (tester) async {
        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = VotingGuard.canVote(context);
              return Container();
            },
          )),
        );

        expect(result, false);
      });
    });

    group('isFullMember', () {
      testWidgets('returns true for voting members', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'voter@example.com',
          membershipType: MembershipType.votingMember,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = VotingGuard.isFullMember(context);
              return Container();
            },
          )),
        );

        expect(result, true);
      });

      testWidgets('returns false for non-voting members', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'nonvoter@example.com',
          membershipType: MembershipType.nonVoting,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = VotingGuard.isFullMember(context);
              return Container();
            },
          )),
        );

        expect(result, false);
      });
    });

    group('getMembershipType', () {
      testWidgets('returns current membership type', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'voter@example.com',
          membershipType: MembershipType.votingMember,
          createdAt: DateTime.now(),
        ));

        late MembershipType? result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = VotingGuard.getMembershipType(context);
              return Container();
            },
          )),
        );

        expect(result, MembershipType.votingMember);
      });

      testWidgets('returns null when no user', (tester) async {
        late MembershipType? result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = VotingGuard.getMembershipType(context);
              return Container();
            },
          )),
        );

        expect(result, null);
      });
    });

    group('hasMembershipType', () {
      testWidgets('returns true for matching type', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'voter@example.com',
          membershipType: MembershipType.votingMember,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = VotingGuard.hasMembershipType(
                  context, MembershipType.votingMember);
              return Container();
            },
          )),
        );

        expect(result, true);
      });

      testWidgets('returns false for non-matching type', (tester) async {
        authProvider.setUserForTesting(User(
          id: '123',
          email: 'nonvoter@example.com',
          membershipType: MembershipType.nonVoting,
          createdAt: DateTime.now(),
        ));

        late bool result;
        await tester.pumpWidget(
          createTestWidget(Builder(
            builder: (context) {
              result = VotingGuard.hasMembershipType(
                  context, MembershipType.votingMember);
              return Container();
            },
          )),
        );

        expect(result, false);
      });
    });
  });

  group('VotingMemberOnly Widget',
      skip:
          'Requires platform plugin (flutter_secure_storage) not available in unit tests',
      () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    Widget createTestWidget(Widget child) {
      return ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets('shows child for voting members', (tester) async {
      authProvider.setUserForTesting(User(
        id: '123',
        email: 'voter@example.com',
        membershipType: MembershipType.votingMember,
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(
        createTestWidget(
          const VotingMemberOnly(
            child: Text('Voting Content'),
          ),
        ),
      );

      expect(find.text('Voting Content'), findsOneWidget);
    });

    testWidgets('shows nothing for non-voting members by default',
        (tester) async {
      authProvider.setUserForTesting(User(
        id: '123',
        email: 'nonvoter@example.com',
        membershipType: MembershipType.nonVoting,
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(
        createTestWidget(
          const VotingMemberOnly(
            child: Text('Voting Content'),
          ),
        ),
      );

      expect(find.text('Voting Content'), findsNothing);
    });

    testWidgets('shows fallback for non-voting members when provided',
        (tester) async {
      authProvider.setUserForTesting(User(
        id: '123',
        email: 'nonvoter@example.com',
        membershipType: MembershipType.nonVoting,
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(
        createTestWidget(
          const VotingMemberOnly(
            child: Text('Voting Content'),
            fallback: Text('Not Eligible'),
          ),
        ),
      );

      expect(find.text('Voting Content'), findsNothing);
      expect(find.text('Not Eligible'), findsOneWidget);
    });

    testWidgets('shows nothing when no user', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const VotingMemberOnly(
            child: Text('Voting Content'),
          ),
        ),
      );

      expect(find.text('Voting Content'), findsNothing);
    });
  });
}
