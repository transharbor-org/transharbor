import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

/// Wraps a widget with MaterialApp for testing
Widget createTestWidget(Widget child) {
  return MaterialApp(
    home: child,
  );
}

/// Wraps a widget with MaterialApp and providers for testing
Widget createTestWidgetWithProviders(Widget child, List<ChangeNotifierProvider> providers) {
  return MultiProvider(
    providers: providers,
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Wraps a widget with MaterialApp and GoRouter for testing
Widget createTestWidgetWithRouter(Widget child, GoRouter router) {
  return MaterialApp.router(
    routerConfig: router,
  );
}

/// Pumps a widget and waits for all animations to complete
Future<void> pumpAndSettleWidget(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

/// Finds a widget by type and verifies it exists
void expectWidgetExists<T>() {
  expect(find.byType(T), findsOneWidget);
}

/// Finds a widget by key and verifies it exists
void expectWidgetExistsByKey(Key key) {
  expect(find.byKey(key), findsOneWidget);
}

/// Finds text and verifies it exists
void expectTextExists(String text) {
  expect(find.text(text), findsOneWidget);
}

/// Verifies a widget does not exist
void expectWidgetNotExists<T>() {
  expect(find.byType(T), findsNothing);
}

/// Simulates a tap on a widget
Future<void> tapWidget(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Simulates entering text into a field
Future<void> enterText(WidgetTester tester, Finder finder, String text) async {
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

/// Mock RecordModel for PocketBase testing
class MockRecordModel {
  final String id;
  final Map<String, dynamic> data;
  final String collectionId;
  final String collectionName;
  final DateTime created;
  final DateTime updated;

  MockRecordModel({
    required this.id,
    required this.data,
    required this.collectionId,
    required this.collectionName,
    DateTime? created,
    DateTime? updated,
  })  : created = created ?? DateTime.now(),
        updated = updated ?? DateTime.now();

  dynamic getStringValue(String key) => data[key];
  List<dynamic> getListValue(String key) => data[key] ?? [];
  Map<String, dynamic> toJson() => {
        'id': id,
        'collectionId': collectionId,
        'collectionName': collectionName,
        'created': created.toIso8601String(),
        'updated': updated.toIso8601String(),
        ...data,
      };
}
