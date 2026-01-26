import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:transharbor/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Journey Integration Tests', () {
    testWidgets('Navigate through all main screens', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should start at splash/login screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Skip actual login for this navigation test
      // Assuming user is already logged in or we're in home screen

      // Test Home Screen navigation
      expect(find.text('TransHarbor'), findsOneWidget);

      // Navigate to Personals via bottom nav
      await tester.tap(find.text('Personals'));
      await tester.pumpAndSettle();
      expect(find.text('Personals'), findsAtLeastNWidgets(1));

      // Navigate to Messages
      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();
      expect(find.text('Messages'), findsAtLeastNWidgets(1));

      // Navigate to Groups
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      expect(find.text('Groups'), findsAtLeastNWidgets(1));

      // Navigate to Governance
      await tester.tap(find.text('Governance'));
      await tester.pumpAndSettle();
      expect(find.text('Governance'), findsAtLeastNWidgets(1));

      // Navigate to Profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsAtLeastNWidgets(1));

      // Navigate back to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to TransHarbor'), findsOneWidget);
    });

    testWidgets('Access feature screens from home cards', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap on Personals feature card
      await tester.tap(find.text('Text posts to connect with others'));
      await tester.pumpAndSettle();
      expect(find.text('Personals'), findsAtLeastNWidgets(1));

      // Go back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Tap on Messaging feature card
      await tester.tap(find.text('Private conversations'));
      await tester.pumpAndSettle();
      expect(find.text('Messages'), findsAtLeastNWidgets(1));

      // Go back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Tap on Groups feature card
      await tester.tap(find.text('Join interest-based communities'));
      await tester.pumpAndSettle();
      expect(find.text('Groups'), findsAtLeastNWidgets(1));

      // Go back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Tap on Governance feature card
      await tester.tap(find.text('Active members vote on decisions'));
      await tester.pumpAndSettle();
      expect(find.text('Governance'), findsAtLeastNWidgets(1));
    });

    testWidgets('Profile navigation flow', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Tap Edit Profile (goes to settings)
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();
      // Should navigate to settings screen

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test About dialog
      await tester.tap(find.text('About TransHarbor'));
      await tester.pumpAndSettle();
      expect(find.text('TransHarbor'), findsAtLeastNWidgets(1));

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('Settings access from home', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap settings icon in app bar
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should navigate to settings screen
      expect(find.text('Settings'), findsAtLeastNWidgets(1));

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to TransHarbor'), findsOneWidget);
    });

    testWidgets('Pull to refresh on personals feed', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to personals
      await tester.tap(find.text('Personals'));
      await tester.pumpAndSettle();

      // Pull to refresh
      await tester.drag(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      // Should still be on personals screen
      expect(find.text('Personals'), findsAtLeastNWidgets(1));
    });

    testWidgets('Bottom navigation persists across screens', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify bottom nav exists
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Navigate through different screens
      await tester.tap(find.text('Personals'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
