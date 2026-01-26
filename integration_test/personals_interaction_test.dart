import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:transharbor/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Personals Feature Integration Tests', () {
    testWidgets('View personals feed and interact with posts', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to personals
      await tester.tap(find.text('Personals'));
      await tester.pumpAndSettle();

      // Verify we're on personals screen
      expect(find.text('Personals'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.add), findsOneWidget);

      // If there are posts, verify like and comment buttons are visible
      final likeButtons = find.byIcon(Icons.favorite_border);
      final commentButtons = find.byIcon(Icons.comment_outlined);

      if (likeButtons.evaluate().isNotEmpty) {
        expect(likeButtons, findsAtLeastNWidgets(1));
        expect(commentButtons, findsAtLeastNWidgets(1));

        // Tap like button on first post
        await tester.tap(likeButtons.first);
        await tester.pumpAndSettle();

        // Tap comment button
        await tester.tap(commentButtons.first);
        await tester.pumpAndSettle();

        // Should show "coming soon" snackbar
        expect(find.text('Comments coming soon!'), findsOneWidget);
      }
    });

    testWidgets('Navigate to create personal screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to personals
      await tester.tap(find.text('Personals'));
      await tester.pumpAndSettle();

      // Tap add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should navigate to create personal screen
      // Verify presence of text input
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
    });

    testWidgets('Pull to refresh personals feed', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to personals
      await tester.tap(find.text('Personals'));
      await tester.pumpAndSettle();

      // Find scrollable content
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      // Pull to refresh
      await tester.drag(refreshIndicator, const Offset(0, 300));
      await tester.pumpAndSettle();

      // Should complete refresh
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('Scroll through personals list', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to personals
      await tester.tap(find.text('Personals'));
      await tester.pumpAndSettle();

      // If there are multiple posts, try scrolling
      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        await tester.drag(listView, const Offset(0, -300));
        await tester.pumpAndSettle();

        // Should still be on personals screen
        expect(find.text('Personals'), findsAtLeastNWidgets(1));
      }
    });
  });
}
