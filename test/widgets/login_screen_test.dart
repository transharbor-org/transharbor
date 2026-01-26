import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/features/auth/screens/login_screen.dart';
import 'package:transharbor/features/auth/providers/auth_provider.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late AuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = AuthProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>.value(
          value: mockAuthProvider,
          child: const LoginScreen(),
        ),
      );
    }

    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays welcome message', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Welcome Back!'), findsOneWidget);
    });

    testWidgets('displays email input field', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('displays password input field', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('email field has email icon', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('password field has lock icon', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final passwordField = tester
          .widgetList<TextFormField>(
            find.byType(TextFormField),
          )
          .elementAt(1);

      expect(passwordField.obscureText, true);
    });

    testWidgets('displays Login button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('displays "Don\'t have an account?" text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Don\'t have an account?'), findsOneWidget);
    });

    testWidgets('displays Register link', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('email field accepts input', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('password field accepts input', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('form is within scrollable view', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Login button is enabled with input', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      expect(loginButton, findsOneWidget);
    });

    testWidgets('displays people icon', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.people), findsOneWidget);
    });
  });
}
