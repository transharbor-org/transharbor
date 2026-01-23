import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/messaging/screens/messages_list_screen.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('MessagesListScreen Widget Tests', () {
    testWidgets('displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const MessagesListScreen()));

      expect(find.text('Messages'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const MessagesListScreen()));

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('displays loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const MessagesListScreen()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
