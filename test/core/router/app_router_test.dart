import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/core/router/app_router.dart';
import 'package:transharbor/features/auth/screens/splash_screen.dart';
import 'package:transharbor/features/auth/screens/login_screen.dart';
import 'package:transharbor/features/auth/screens/register_screen.dart';
import 'package:transharbor/features/home/screens/home_screen.dart';
import 'package:transharbor/features/personals/screens/personals_feed_screen.dart';
import 'package:transharbor/features/personals/screens/create_personal_screen.dart';
import 'package:transharbor/features/messaging/screens/messages_list_screen.dart';
import 'package:transharbor/features/messaging/screens/conversation_screen.dart';
import 'package:transharbor/features/governance/screens/governance_screen.dart';
import 'package:transharbor/features/governance/screens/voting_screen.dart';
import 'package:transharbor/features/groups/screens/groups_list_screen.dart';
import 'package:transharbor/features/groups/screens/create_group_screen.dart';
import 'package:transharbor/features/groups/screens/group_detail_screen.dart';
import 'package:transharbor/features/moderation/screens/moderation_screen.dart';
import 'package:transharbor/features/admin/screens/admin_management_screen.dart';
import 'package:transharbor/features/profile/screens/profile_screen.dart';
import 'package:transharbor/features/settings/screens/settings_screen.dart';

void main() {
  group('AppRouter', () {
    test('router is configured', () {
      expect(AppRouter.router, isNotNull);
    });

    test('router has initial location set to root', () {
      expect(AppRouter.router.routerDelegate.currentConfiguration.uri.path,
          equals('/'));
    });

    test('router has navigation observer', () {
      expect(AppRouter.router.routerDelegate.navigatorKey, isNotNull);
    });

    group('Route definitions', () {
      testWidgets('root route renders SplashScreen', (tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: AppRouter.router,
          ),
        );

        expect(find.byType(SplashScreen), findsOneWidget);
      });

      testWidgets('login route renders LoginScreen', (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/login');
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
      });

      testWidgets('register route renders RegisterScreen', (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/register');
        await tester.pumpAndSettle();

        expect(find.byType(RegisterScreen), findsOneWidget);
      });

      testWidgets('home route renders HomeScreen', (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/home');
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('personals route renders PersonalsFeedScreen',
          (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/personals');
        await tester.pumpAndSettle();

        expect(find.byType(PersonalsFeedScreen), findsOneWidget);
      });

      testWidgets('create personal route renders CreatePersonalScreen',
          (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/personals/create');
        await tester.pumpAndSettle();

        expect(find.byType(CreatePersonalScreen), findsOneWidget);
      });

      testWidgets('messages route renders MessagesListScreen', (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/messages');
        await tester.pumpAndSettle();

        expect(find.byType(MessagesListScreen), findsOneWidget);
      });

      testWidgets('conversation route renders ConversationScreen with ID',
          (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/messages/conv123');
        await tester.pumpAndSettle();

        expect(find.byType(ConversationScreen), findsOneWidget);
        final screen = tester.widget<ConversationScreen>(
          find.byType(ConversationScreen),
        );
        expect(screen.conversationId, equals('conv123'));
      });

      testWidgets('governance route renders GovernanceScreen', (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/governance');
        await tester.pumpAndSettle();

        expect(find.byType(GovernanceScreen), findsOneWidget);
      });

      testWidgets('voting route renders VotingScreen with proposal ID',
          (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/governance/vote/prop123');
        await tester.pumpAndSettle();

        expect(find.byType(VotingScreen), findsOneWidget);
        final screen = tester.widget<VotingScreen>(
          find.byType(VotingScreen),
        );
        expect(screen.proposalId, equals('prop123'));
      });

      testWidgets('groups route renders GroupsListScreen', (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/groups');
        await tester.pumpAndSettle();

        expect(find.byType(GroupsListScreen), findsOneWidget);
      });

      testWidgets('create group route renders CreateGroupScreen',
          (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/groups/create');
        await tester.pumpAndSettle();

        expect(find.byType(CreateGroupScreen), findsOneWidget);
      });

      testWidgets('group detail route renders GroupDetailScreen with ID',
          (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/groups/group123');
        await tester.pumpAndSettle();

        expect(find.byType(GroupDetailScreen), findsOneWidget);
        final screen = tester.widget<GroupDetailScreen>(
          find.byType(GroupDetailScreen),
        );
        expect(screen.groupId, equals('group123'));
      });

      testWidgets('moderation route renders ModerationScreen', (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/moderation');
        await tester.pumpAndSettle();

        expect(find.byType(ModerationScreen), findsOneWidget);
      });

      testWidgets('admin route renders AdminManagementScreen', (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/admin');
        await tester.pumpAndSettle();

        expect(find.byType(AdminManagementScreen), findsOneWidget);
      });

      testWidgets('profile route renders ProfileScreen', (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/profile');
        await tester.pumpAndSettle();

        expect(find.byType(ProfileScreen), findsOneWidget);
      });

      testWidgets('settings route renders SettingsScreen', (tester) async {
        final router = AppRouter.router;
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        router.go('/settings');
        await tester.pumpAndSettle();

        expect(find.byType(SettingsScreen), findsOneWidget);
      });
    });

    group('NavigationLogger', () {
      test('NavigationLogger is a NavigatorObserver', () {
        final logger = NavigationLogger();
        expect(logger, isA<NavigatorObserver>());
      });
    });
  });
}
