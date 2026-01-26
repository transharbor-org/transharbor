import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:transharbor/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Feature Integration Tests', () {
    testWidgets('Navigate through profile options', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Verify profile screen elements
      expect(find.text('Profile'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Privacy Settings'), findsOneWidget);
      expect(find.text('About TransHarbor'), findsOneWidget);
      expect(find.text('Community Guidelines'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('Navigate to settings from Edit Profile', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Tap Edit Profile
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      // Should navigate to settings
      expect(find.text('Settings'), findsAtLeastNWidgets(1));

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
    });

    testWidgets('Navigate to settings from Privacy Settings', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Tap Privacy Settings
      await tester.tap(find.text('Privacy Settings'));
      await tester.pumpAndSettle();

      // Should navigate to settings
      expect(find.text('Settings'), findsAtLeastNWidgets(1));

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
    });

    testWidgets('Open About TransHarbor dialog', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Tap About TransHarbor
      await tester.tap(find.text('About TransHarbor'));
      await tester.pumpAndSettle();

      // Should show about dialog
      expect(find.text('TransHarbor'), findsAtLeastNWidgets(2));
      expect(find.textContaining('1.0.0'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Should be back on profile
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('Profile displays user information', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Should display user avatar (default or actual)
      expect(find.byType(CircleAvatar), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.person), findsAtLeastNWidgets(1));

      // Should display email if user is logged in
      // This will vary based on auth state
    });

    testWidgets('Scroll through profile options', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Profile should be scrollable
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Scroll down
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      // Logout should still be visible or scrolled to
      expect(find.text('Logout'), findsOneWidget);
    });
  });
}
