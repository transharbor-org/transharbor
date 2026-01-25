import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:transharbor/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow E2E Tests', () {
    testWidgets('Complete login flow with valid credentials', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and verify login screen elements
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      
      final emailField = find.byKey(const Key('login_email_field'));
      final passwordField = find.byKey(const Key('login_password_field'));
      final loginButton = find.byKey(const Key('login_button'));

      // Enter valid credentials
      await tester.enterText(emailField, 'alex@example.com');
      await tester.pumpAndSettle();
      
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify successful login - should navigate to home/personals feed
      expect(find.text('Personals'), findsWidgets);
    });

    testWidgets('Login with empty credentials shows validation errors', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final loginButton = find.byKey(const Key('login_button'));

      // Try to login without entering credentials
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Login with invalid credentials shows error message', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final emailField = find.byKey(const Key('login_email_field'));
      final passwordField = find.byKey(const Key('login_password_field'));
      final loginButton = find.byKey(const Key('login_button'));

      // Enter invalid credentials
      await tester.enterText(emailField, 'invalid@example.com');
      await tester.pumpAndSettle();
      
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show error message (from API)
      expect(find.textContaining('Failed to authenticate'), findsOneWidget);
    });

    testWidgets('Navigate to register screen and back', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap register link
      final registerLink = find.text('Create Account');
      expect(registerLink, findsOneWidget);
      
      await tester.tap(registerLink);
      await tester.pumpAndSettle();

      // Verify register screen
      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Confirm Password'), findsOneWidget);

      // Navigate back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Should be back on login screen
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });
  });
}
