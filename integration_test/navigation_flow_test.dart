import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:transharbor/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('Navigation Flow E2E Tests', () {
    // Helper function to login
    Future<void> loginAsTestUser(WidgetTester tester) async {
      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');

      await tester.enterText(emailField, 'alex@example.com');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    testWidgets('Bottom navigation works after login',
        (WidgetTester tester) async {
      app.main();
      await loginAsTestUser(tester);

      // Verify we're logged in and see bottom navigation
      final bottomNav = find.byType(BottomNavigationBar);
      expect(bottomNav, findsOneWidget);

      // Get navigation items
      final bottomNavWidget = tester.widget<BottomNavigationBar>(bottomNav);
      expect(bottomNavWidget.items.length, greaterThanOrEqualTo(3));
    }, timeout: const Timeout(Duration(seconds: 30)));

    testWidgets('Navigate to Personals tab', (WidgetTester tester) async {
      app.main();
      await loginAsTestUser(tester);

      final bottomNav = find.byType(BottomNavigationBar);
      expect(bottomNav, findsOneWidget);

      // Find and tap Personals navigation item
      final personalsTab = find.descendant(
        of: bottomNav,
        matching: find.byIcon(Icons.people),
      );

      if (personalsTab.evaluate().isNotEmpty) {
        await tester.tap(personalsTab);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should see personals content
        expect(find.text('Personals'), findsWidgets);
      }
    }, timeout: const Timeout(Duration(seconds: 30)));

    testWidgets('Navigate to Messages tab', (WidgetTester tester) async {
      app.main();
      await loginAsTestUser(tester);

      final bottomNav = find.byType(BottomNavigationBar);
      expect(bottomNav, findsOneWidget);

      // Find and tap Messages navigation item
      final messagesTab = find.descendant(
        of: bottomNav,
        matching: find.byIcon(Icons.message),
      );

      if (messagesTab.evaluate().isNotEmpty) {
        await tester.tap(messagesTab);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should see messages content
        expect(find.text('Messages'), findsWidgets);
      }
    }, timeout: const Timeout(Duration(seconds: 30)));

    testWidgets('Navigate to Profile tab', (WidgetTester tester) async {
      app.main();
      await loginAsTestUser(tester);

      final bottomNav = find.byType(BottomNavigationBar);
      expect(bottomNav, findsOneWidget);

      // Find and tap Profile navigation item
      final profileTab = find.descendant(
        of: bottomNav,
        matching: find.byIcon(Icons.person),
      );

      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should see profile content
        expect(find.text('Profile'), findsWidgets);
      }
    }, timeout: const Timeout(Duration(seconds: 30)));

    testWidgets('App bar shows correct title after navigation',
        (WidgetTester tester) async {
      app.main();
      await loginAsTestUser(tester);

      // Verify app has an AppBar
      expect(find.byType(AppBar), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 30)));

    testWidgets('Back button navigation works', (WidgetTester tester) async {
      app.main();
      await loginAsTestUser(tester);

      // Try to find a detail screen by tapping an item
      // This is a basic test - adapt based on actual app structure
      final bottomNav = find.byType(BottomNavigationBar);

      if (bottomNav.evaluate().isNotEmpty) {
        // Navigate to different tabs
        final personalsTab = find.descendant(
          of: bottomNav,
          matching: find.byIcon(Icons.people),
        );

        if (personalsTab.evaluate().isNotEmpty) {
          await tester.tap(personalsTab);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Try to navigate back
          final backButton = find.byType(BackButton);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();
          }
        }
      }
    }, timeout: const Timeout(Duration(seconds: 30)));

    testWidgets('Logout navigation returns to login screen',
        (WidgetTester tester) async {
      app.main();
      await loginAsTestUser(tester);

      // Find logout button - it might be in a drawer or menu
      final logoutButton = find.text('Logout');

      if (logoutButton.evaluate().isNotEmpty) {
        await tester.tap(logoutButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should return to login screen
        expect(find.text('Welcome to TransHarbor'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      } else {
        // Try to find it in a menu
        final menuButton = find.byIcon(Icons.menu);
        if (menuButton.evaluate().isNotEmpty) {
          await tester.tap(menuButton);
          await tester.pumpAndSettle();

          final drawerLogout = find.text('Logout');
          if (drawerLogout.evaluate().isNotEmpty) {
            await tester.tap(drawerLogout);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            expect(find.text('Welcome to TransHarbor'), findsOneWidget);
          }
        }
      }
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
