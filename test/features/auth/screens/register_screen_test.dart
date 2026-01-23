import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/auth/screens/register_screen.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('RegisterScreen Widget Tests', () {
    testWidgets('displays all required elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));

      expect(find.text('TransHarbor'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('has four text fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));

      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('has register button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));

      expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
    });

    testWidgets('has login link', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));

      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Login'), findsOneWidget);
    });

    testWidgets('username field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));

      final usernameField = find.byType(TextFormField).at(0);
      await tester.enterText(usernameField, 'testuser');

      expect(find.text('testuser'), findsOneWidget);
    });

    testWidgets('email field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));

      final emailField = find.byType(TextFormField).at(1);
      await tester.enterText(emailField, 'test@example.com');

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('password field exists', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));

      // There are only 3 fields: email, password, confirm password
      final passwordField = find.byType(TextFormField).at(2);
      
      expect(passwordField, findsOneWidget);
    });
  });
}
