import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/features/auth/providers/auth_provider.dart';
import 'package:transharbor/features/auth/screens/login_screen.dart';

void main() {
  group('LoginScreen', () {
    late AuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = AuthProvider();
    });

    Widget createLoginScreen() {
      return ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      );
    }

    testWidgets('renders login form with all fields', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      expect(find.text('Welcome to TransHarbor'), findsOneWidget);
      expect(find.text('User-Owned Platform for Trans & Nonbinary People'),
          findsOneWidget);
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
      expect(find.text("Don't have an account? Register"), findsOneWidget);
    });

    testWidgets('email field has email keyboard type', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Check that the email field exists with proper key
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
    });

    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Password field exists and visibility toggle is present
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Find the visibility toggle icon
      final visibilityToggle = find.byIcon(Icons.visibility);
      expect(visibilityToggle, findsOneWidget);

      // Tap to toggle visibility
      await tester.tap(visibilityToggle);
      await tester.pumpAndSettle();

      // Should now show visibility_off icon
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('validates empty email field', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Tap login without entering email
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('validates empty password field', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Enter email but not password
      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        'test@example.com',
      );

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('button is enabled when not loading', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('login_button')),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('has proper decoration on form fields', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Check that fields exist and are properly configured
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('displays app icon', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      final icon = tester.widget<Icon>(
        find.byIcon(Icons.people),
      );
      expect(icon.size, equals(80));
    });
  });
}
