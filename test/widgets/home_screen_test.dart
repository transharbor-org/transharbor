import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/home/screens/home_screen.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    Widget createTestWidget() {
      return const MaterialApp(
        home: HomeScreen(),
      );
    }

    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('TransHarbor'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays settings icon in app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('displays welcome message', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Welcome to TransHarbor'), findsOneWidget);
    });

    testWidgets('displays tagline', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(
        find.text(
            'User-Owned • Trans-Centered • Privacy-First • Democratic • Nonprofit'),
        findsOneWidget,
      );
    });

    testWidgets('displays people icon', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('displays Personals feature card', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Personals'), findsOneWidget);
      expect(find.text('Text posts to connect with others'), findsOneWidget);
      expect(find.byIcon(Icons.article), findsAtLeastNWidgets(1));
    });

    testWidgets('displays Messaging feature card', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Messaging'), findsOneWidget);
      expect(find.text('Private conversations'), findsOneWidget);
      expect(find.byIcon(Icons.message), findsAtLeastNWidgets(1));
    });

    testWidgets('displays Groups feature card', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Groups'), findsOneWidget);
      expect(find.text('Join interest-based communities'), findsOneWidget);
      expect(find.byIcon(Icons.group), findsAtLeastNWidgets(1));
    });

    testWidgets('displays Governance feature card', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Governance'), findsOneWidget);
      expect(find.text('Active members vote on decisions'), findsOneWidget);
      expect(find.byIcon(Icons.how_to_vote), findsAtLeastNWidgets(1));
    });

    testWidgets('displays bottom navigation bar', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('bottom nav has 6 items', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final bottomNav =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.items.length, 6);
    });

    testWidgets('bottom nav shows correct labels', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('bottom nav has correct icons', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.home), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.person), findsAtLeastNWidgets(1));
    });

    testWidgets('all feature cards are tappable', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(InkWell), findsNWidgets(4));
    });

    testWidgets('feature cards show arrow icons', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(4));
    });
  });
}
