import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/personals/screens/create_personal_screen.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('CreatePersonalScreen Widget Tests', () {
    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreatePersonalScreen()));

      expect(find.text('Create Personal'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays content text field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreatePersonalScreen()));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('What would you like to share?'), findsOneWidget);
    });

    testWidgets('displays post button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreatePersonalScreen()));

      expect(find.widgetWithText(TextButton, 'Post'), findsOneWidget);
    });

    testWidgets('content field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreatePersonalScreen()));

      final contentField = find.byType(TextField);
      await tester.enterText(contentField, 'Test personal content');

      expect(find.text('Test personal content'), findsOneWidget);
    });

    testWidgets('content field has max lines of 10', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreatePersonalScreen()));

      final contentField = find.byType(TextField);
      final textField = tester.widget<TextField>(contentField);

      expect(textField.maxLines, 10);
    });

    testWidgets('displays community guidelines text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const CreatePersonalScreen()));

      expect(find.textContaining('community guidelines'), findsOneWidget);
    });
  });
}
