import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/auth/screens/login_screen.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('displays all required elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));

      expect(find.text('TransHarbor'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Don\'t have an account?'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('has email and password text fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('has login button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));

      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('has register text button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));

      expect(find.widgetWithText(TextButton, 'Register'), findsOneWidget);
    });

    testWidgets('email field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('password field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));

      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('password field exists', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));

      final passwordField = find.byType(TextFormField).last;
      expect(passwordField, findsOneWidget);
    });
  });
}
