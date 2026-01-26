import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/features/profile/screens/profile_screen.dart';
import 'package:transharbor/features/auth/providers/auth_provider.dart';
import 'package:transharbor/core/models/user.dart';

void main() {
  group('ProfileScreen Widget Tests', () {
    late AuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = AuthProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: const ProfileScreen(),
        ),
      );
    }

    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays default avatar when user has no avatar',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircleAvatar), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.person), findsAtLeastNWidgets(1));
    });

    testWidgets('displays camera button for avatar upload', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('displays Edit Profile option', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('displays Privacy Settings option', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Privacy Settings'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('displays About TransHarbor option', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('About TransHarbor'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('displays Community Guidelines option', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Community Guidelines'), findsOneWidget);
      expect(find.byIcon(Icons.article_outlined), findsOneWidget);
    });

    testWidgets('displays Privacy Policy option', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.byIcon(Icons.policy_outlined), findsOneWidget);
    });

    testWidgets('displays Logout option', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Logout'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('all menu items have arrow icons', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Edit, Privacy, About, Guidelines, Policy (5 items with arrows)
      expect(
          find.byWidgetPredicate((widget) =>
              widget is Icon &&
              widget.icon == Icons.arrow_forward_ios &&
              widget.size == 16),
          findsNWidgets(5));
    });

    testWidgets('displays dividers between sections', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('Logout option is red', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final logoutText = find.text('Logout');
      expect(logoutText, findsOneWidget);

      final textWidget = tester.widget<Text>(logoutText);
      expect(textWidget.style?.color, Colors.red);
    });

    testWidgets('displays user display name when available', (tester) async {
      mockAuthProvider.currentUser = User(
        id: 'test-user',
        email: 'test@example.com',
        username: 'testuser',
        displayName: 'Test User',
        role: UserRole.member,
        verified: true,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('displays pronouns when available', (tester) async {
      mockAuthProvider.currentUser = User(
        id: 'test-user',
        email: 'test@example.com',
        username: 'testuser',
        displayName: 'Test User',
        pronouns: 'she/her',
        role: UserRole.member,
        verified: true,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('she/her'), findsOneWidget);
    });

    testWidgets('displays bio when available', (tester) async {
      mockAuthProvider.currentUser = User(
        id: 'test-user',
        email: 'test@example.com',
        username: 'testuser',
        displayName: 'Test User',
        bio: 'This is my test bio',
        role: UserRole.member,
        verified: true,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('This is my test bio'), findsOneWidget);
    });

    testWidgets('displays email address', (tester) async {
      mockAuthProvider.currentUser = User(
        id: 'test-user',
        email: 'user@example.com',
        username: 'testuser',
        role: UserRole.member,
        verified: true,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('user@example.com'), findsOneWidget);
    });

    testWidgets('all list tiles are scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(6));
    });
  });
}
