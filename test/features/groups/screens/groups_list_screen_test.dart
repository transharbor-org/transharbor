import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/groups/screens/groups_list_screen.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('GroupsListScreen Widget Tests', () {
    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const GroupsListScreen()));

      expect(find.text('Groups'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const GroupsListScreen()));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('displays tab bar with tabs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const GroupsListScreen()));

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('My Groups'), findsOneWidget);
    });

    testWidgets('displays category chips', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const GroupsListScreen()));

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Social'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Hobbies'), findsOneWidget);
      expect(find.text('Activism'), findsOneWidget);
    });

    testWidgets('displays loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const GroupsListScreen()));

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
