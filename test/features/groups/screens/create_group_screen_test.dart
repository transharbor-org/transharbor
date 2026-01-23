import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/groups/screens/create_group_screen.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('CreateGroupScreen Widget Tests', () {
    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreateGroupScreen()));

      expect(find.text('Create Group'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreateGroupScreen()));

      expect(find.text('Group Name'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
    });

    testWidgets('displays text form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreateGroupScreen()));

      // Name and Description fields
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('displays category dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreateGroupScreen()));

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('displays privacy switch', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreateGroupScreen()));

      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.text('Private Group'), findsOneWidget);
    });

    testWidgets('displays create button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreateGroupScreen()));

      expect(find.widgetWithText(ElevatedButton, 'Create Group'), findsOneWidget);
    });

    testWidgets('name field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreateGroupScreen()));

      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test Group');

      expect(find.text('Test Group'), findsOneWidget);
    });

    testWidgets('description field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreateGroupScreen()));

      final descField = find.byType(TextFormField).last;
      await tester.enterText(descField, 'Test Description');

      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('category dropdown has options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreateGroupScreen()));

      // Tap the dropdown to open it
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('Social'), findsWidgets);
      expect(find.text('Support'), findsWidgets);
      expect(find.text('Hobbies'), findsWidgets);
      expect(find.text('Activism'), findsWidgets);
    });
  });
}
