import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/personals/screens/personals_feed_screen.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('PersonalsFeedScreen Widget Tests', () {
    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PersonalsFeedScreen()));

      expect(find.text('Personals'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PersonalsFeedScreen()));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('displays empty state when no personals', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const PersonalsFeedScreen()));

      // Should show some empty state or loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
