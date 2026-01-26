import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/features/personals/screens/personals_feed_screen.dart';
import 'package:transharbor/features/personals/providers/personals_provider.dart';
import 'package:transharbor/features/personals/models/personal.dart';

void main() {
  group('PersonalsFeedScreen Widget Tests', () {
    late PersonalsProvider mockProvider;

    setUp(() {
      mockProvider = PersonalsProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<PersonalsProvider>.value(
          value: mockProvider,
          child: const PersonalsFeedScreen(),
        ),
      );
    }

    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Personals'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays add button in app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no personals', (tester) async {
      mockProvider.loadPersonals();
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No personals yet'), findsOneWidget);
      expect(find.text('Be the first to post!'), findsOneWidget);
      expect(find.byIcon(Icons.article_outlined), findsOneWidget);
    });

    testWidgets('displays personal posts in list', (tester) async {
      final mockPersonal = Personal(
        id: 'test-123',
        userId: 'user-abc',
        content: 'Test personal post content',
        createdAt: DateTime.now(),
        likesCount: 5,
        commentsCount: 3,
      );

      mockProvider.personals.add(mockPersonal);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test personal post content'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('displays like and comment buttons', (tester) async {
      final mockPersonal = Personal(
        id: 'test-123',
        userId: 'user-abc',
        content: 'Test post',
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
      );

      mockProvider.personals.add(mockPersonal);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.comment_outlined), findsOneWidget);
    });

    testWidgets('can pull to refresh', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('displays user avatar circle', (tester) async {
      final mockPersonal = Personal(
        id: 'test-123',
        userId: 'user-abc',
        content: 'Test post',
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
      );

      mockProvider.personals.add(mockPersonal);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('displays formatted user ID', (tester) async {
      final mockPersonal = Personal(
        id: 'test-123',
        userId: 'longuser123456789',
        content: 'Test post',
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
      );

      mockProvider.personals.add(mockPersonal);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('User longuser'), findsOneWidget);
    });

    testWidgets('displays multiple personals', (tester) async {
      mockProvider.personals.addAll([
        Personal(
          id: '1',
          userId: 'user1',
          content: 'First post',
          createdAt: DateTime.now(),
          likesCount: 1,
          commentsCount: 0,
        ),
        Personal(
          id: '2',
          userId: 'user2',
          content: 'Second post',
          createdAt: DateTime.now(),
          likesCount: 2,
          commentsCount: 1,
        ),
        Personal(
          id: '3',
          userId: 'user3',
          content: 'Third post',
          createdAt: DateTime.now(),
          likesCount: 3,
          commentsCount: 2,
        ),
      ]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('First post'), findsOneWidget);
      expect(find.text('Second post'), findsOneWidget);
      expect(find.text('Third post'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
    });
  });
}
