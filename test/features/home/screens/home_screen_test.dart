import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/home/screens/home_screen.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const HomeScreen()));

      expect(find.text('TransHarbor'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays all feature cards', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const HomeScreen()));

      expect(find.text('Personals'), findsOneWidget);
      expect(find.text('Messaging'), findsOneWidget);
      expect(find.text('Governance'), findsOneWidget);
      expect(find.text('Groups'), findsOneWidget);
    });

    testWidgets('displays feature descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const HomeScreen()));

      expect(find.textContaining('Share your experiences'), findsOneWidget);
      expect(find.textContaining('Connect with community'), findsOneWidget);
      expect(find.textContaining('Participate in democratic'), findsOneWidget);
      expect(find.textContaining('Join interest-based'), findsOneWidget);
    });

    testWidgets('displays icons for each feature', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const HomeScreen()));

      // Should have icons for Personals, Messaging, Governance, and Groups
      expect(find.byIcon(Icons.edit_note), findsOneWidget);
      expect(find.byIcon(Icons.chat), findsOneWidget);
      expect(find.byIcon(Icons.how_to_vote), findsOneWidget);
      expect(find.byIcon(Icons.groups), findsOneWidget);
    });

    testWidgets('displays navigation bottom bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const HomeScreen()));

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('displays profile icon in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const HomeScreen()));

      expect(find.byIcon(Icons.account_circle), findsOneWidget);
    });

    testWidgets('feature cards are tappable', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const HomeScreen()));

      expect(find.byType(Card), findsWidgets);
    });
  });
}
