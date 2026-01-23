import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/governance/screens/proposals_list_screen.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('ProposalsListScreen Widget Tests', () {
    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const ProposalsListScreen()));

      expect(find.text('Governance'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const ProposalsListScreen()));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('displays status filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const ProposalsListScreen()));

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Passed'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('displays loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const ProposalsListScreen()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
