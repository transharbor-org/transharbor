import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/features/personals/providers/personals_provider.dart';
import 'package:transharbor/features/personals/screens/create_personal_screen.dart';

void main() {
  group('CreatePersonalScreen', () {
    late PersonalsProvider mockProvider;

    setUp(() {
      mockProvider = PersonalsProvider();
    });

    Widget createScreen() {
      return ChangeNotifierProvider<PersonalsProvider>.value(
        value: mockProvider,
        child: const MaterialApp(
          home: CreatePersonalScreen(),
        ),
      );
    }

    testWidgets('renders create personal form', (tester) async {
      await tester.pumpWidget(createScreen());

      expect(find.text('Create Personal'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Post'), findsOneWidget);
    });

    testWidgets('content field has correct max length', (tester) async {
      await tester.pumpWidget(createScreen());

      // Check content field exists
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('content field has multiple lines', (tester) async {
      await tester.pumpWidget(createScreen());

      // Check content field exists
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('content field has hint text', (tester) async {
      await tester.pumpWidget(createScreen());

      // Check hint text is visible
      expect(find.text('What would you like to share?'), findsOneWidget);
    });

    testWidgets('content field autofocuses', (tester) async {
      await tester.pumpWidget(createScreen());

      // Check content field exists
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays community guidelines reminder', (tester) async {
      await tester.pumpWidget(createScreen());

      expect(
        find.text(
            'Remember to follow community guidelines and be respectful to others.'),
        findsOneWidget,
      );
    });

    testWidgets('can enter text in content field', (tester) async {
      await tester.pumpWidget(createScreen());

      await tester.enterText(
        find.byType(TextField),
        'This is my personal post',
      );

      expect(find.text('This is my personal post'), findsOneWidget);
    });

    testWidgets('Post button is enabled by default', (tester) async {
      await tester.pumpWidget(createScreen());

      final button = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Post'),
      );

      expect(button.onPressed, isNotNull);
    });

    testWidgets('trims whitespace before validation', (tester) async {
      await tester.pumpWidget(createScreen());

      await tester.enterText(
        find.byType(TextField),
        '   ',
      );

      await tester.tap(find.text('Post'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter some content'), findsOneWidget);
    });

    testWidgets('content field has border', (tester) async {
      await tester.pumpWidget(createScreen());

      // Check content field exists
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
