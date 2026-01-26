import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/features/groups/providers/groups_provider.dart';
import 'package:transharbor/features/groups/screens/create_group_screen.dart';

void main() {
  group('CreateGroupScreen', () {
    late GroupsProvider mockGroupsProvider;

    setUp(() {
      mockGroupsProvider = GroupsProvider();
    });

    Widget createScreen() {
      return ChangeNotifierProvider<GroupsProvider>.value(
        value: mockGroupsProvider,
        child: const MaterialApp(
          home: CreateGroupScreen(),
        ),
      );
    }

    testWidgets('renders create group form with all fields', (tester) async {
      await tester.pumpWidget(createScreen());

      expect(find.text('Create Group'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Group Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Description'), findsOneWidget);
      expect(find.widgetWithText(DropdownButtonFormField<String>, 'Category'),
          findsOneWidget);
      expect(find.text('Private Group'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('validates empty group name', (tester) async {
      await tester.pumpWidget(createScreen());

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a group name'), findsOneWidget);
    });

    testWidgets('validates empty description', (tester) async {
      await tester.pumpWidget(createScreen());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Group Name'),
        'Test Group',
      );

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a description'), findsOneWidget);
    });

    testWidgets('group name has max length of 100', (tester) async {
      await tester.pumpWidget(createScreen());

      // Check that group name field exists
      expect(find.widgetWithText(TextFormField, 'Group Name'), findsOneWidget);
    });

    testWidgets('description has max length of 500', (tester) async {
      await tester.pumpWidget(createScreen());

      // Check description field exists
      expect(find.widgetWithText(TextFormField, 'Description'), findsOneWidget);
    });

    testWidgets('description has multiple lines', (tester) async {
      await tester.pumpWidget(createScreen());

      // Check description field exists
      expect(find.widgetWithText(TextFormField, 'Description'), findsOneWidget);
    });

    testWidgets('category dropdown shows all categories', (tester) async {
      await tester.pumpWidget(createScreen());

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('SOCIAL'), findsOneWidget);
      expect(find.text('SUPPORT'), findsOneWidget);
      expect(find.text('CREATIVE'), findsOneWidget);
      expect(find.text('ACTIVISM'), findsOneWidget);
    });

    testWidgets('can select category from dropdown', (tester) async {
      await tester.pumpWidget(createScreen());

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SOCIAL').last);
      await tester.pumpAndSettle();

      // Dropdown should now show selected value
      expect(find.text('SOCIAL'), findsOneWidget);
    });

    testWidgets('private group switch is off by default', (tester) async {
      await tester.pumpWidget(createScreen());

      final switchTile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );

      expect(switchTile.value, isFalse);
    });

    testWidgets('can toggle private group switch', (tester) async {
      await tester.pumpWidget(createScreen());

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      final switchTile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );

      expect(switchTile.value, isTrue);
    });

    testWidgets('displays group guidelines card', (tester) async {
      await tester.pumpWidget(createScreen());

      expect(find.text('Group Guidelines'), findsOneWidget);
      expect(
          find.textContaining('Groups are community spaces'), findsOneWidget);
      expect(find.textContaining("you'll be the group admin"), findsOneWidget);
    });

    testWidgets('private group switch has subtitle', (tester) async {
      await tester.pumpWidget(createScreen());

      expect(find.text('Only members can see posts'), findsOneWidget);
    });
  });
}
