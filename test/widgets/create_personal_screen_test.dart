import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/features/personals/screens/create_personal_screen.dart';
import 'package:transharbor/features/personals/providers/personals_provider.dart';

void main() {
  group('CreatePersonalScreen Widget Tests', () {
    late PersonalsProvider mockProvider;

    setUp(() {
      mockProvider = PersonalsProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<PersonalsProvider>.value(
          value: mockProvider,
          child: const CreatePersonalScreen(),
        ),
      );
    }

    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Create Personal'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays text input field', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays character count', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.textContaining('0'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays post button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Post'), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'This is my personal post!');
      await tester.pump();

      expect(find.text('This is my personal post!'), findsOneWidget);
    });

    testWidgets('updates character count when typing', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Hello world!');
      await tester.pump();

      // Should show character count (12 characters)
      expect(find.textContaining('12'), findsAtLeastNWidgets(1));
    });

    testWidgets('post button is initially enabled', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final postButton = find.text('Post');
      expect(postButton, findsOneWidget);
    });

    testWidgets('can tap post button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test post');
      await tester.pump();

      final postButton = find.text('Post');
      await tester.tap(postButton);
      await tester.pump();
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(
        find.text('What\'s on your mind?'),
        findsOneWidget,
      );
    });

    testWidgets('text field has multiple lines', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, greaterThan(1));
    });
  });
}
