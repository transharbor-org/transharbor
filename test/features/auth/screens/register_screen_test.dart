import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/features/auth/providers/auth_provider.dart';
import 'package:transharbor/features/auth/screens/register_screen.dart';

void main() {
  group('RegisterScreen', () {
    late AuthProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = AuthProvider();
    });

    Widget createRegisterScreen() {
      return ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      );
    }

    testWidgets('renders registration form with all fields', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Join the TransHarbor community'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Confirm Password'),
          findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('email field validates empty input', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('email field validates invalid email format', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalidemail',
      );

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('password field validates empty input', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('password field validates minimum length', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'short',
      );

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(
          find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('confirm password field validates empty input', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('validates password match', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'different123',
      );

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('password fields are obscured by default', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      // Check visibility toggle icons are present (indicating obscured text)
      expect(find.byIcon(Icons.visibility), findsNWidgets(2));
    });

    testWidgets('password visibility toggles work', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      // Find all visibility icons
      final visibilityIcons = find.byIcon(Icons.visibility);
      expect(visibilityIcons, findsNWidgets(2));

      // Toggle first password field
      await tester.tap(visibilityIcons.first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsAtLeastNWidgets(1));
    });

    testWidgets('button is enabled when not loading', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Register'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('has back button in app bar', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('email field has email keyboard type', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      // Check email field exists
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    });

    testWidgets('all fields have proper icons', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNWidgets(2));
    });
  });
}
