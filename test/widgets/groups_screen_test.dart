import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/features/groups/screens/groups_list_screen.dart';
import 'package:transharbor/features/groups/providers/groups_provider.dart';
import 'package:transharbor/features/groups/models/group.dart';

void main() {
  group('GroupsListScreen Widget Tests', () {
    late GroupsProvider mockProvider;

    setUp(() {
      mockProvider = GroupsProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<GroupsProvider>.value(
          value: mockProvider,
          child: const GroupsListScreen(),
        ),
      );
    }

    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Groups'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays create group button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no groups', (tester) async {
      mockProvider.loadGroups();
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No groups yet'), findsOneWidget);
      expect(find.text('Create the first group!'), findsOneWidget);
      expect(find.byIcon(Icons.group_outlined), findsOneWidget);
    });

    testWidgets('displays group list', (tester) async {
      final mockGroup = Group(
        id: 'group-123',
        name: 'Test Group',
        description: 'A test group for testing',
        createdBy: 'user-abc',
        memberCount: 10,
        isPublic: true,
        createdAt: DateTime.now(),
      );

      mockProvider.groups.add(mockGroup);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test Group'), findsOneWidget);
      expect(find.text('A test group for testing'), findsOneWidget);
    });

    testWidgets('displays member count', (tester) async {
      final mockGroup = Group(
        id: 'group-123',
        name: 'Test Group',
        description: 'Description',
        createdBy: 'user-abc',
        memberCount: 25,
        isPublic: true,
        createdAt: DateTime.now(),
      );

      mockProvider.groups.add(mockGroup);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('25'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.people), findsAtLeastNWidgets(1));
    });

    testWidgets('displays public/private indicator', (tester) async {
      final mockGroup = Group(
        id: 'group-123',
        name: 'Public Group',
        description: 'Description',
        createdBy: 'user-abc',
        memberCount: 10,
        isPublic: true,
        createdAt: DateTime.now(),
      );

      mockProvider.groups.add(mockGroup);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.public), findsAtLeastNWidgets(1));
    });

    testWidgets('displays multiple groups', (tester) async {
      mockProvider.groups.addAll([
        Group(
          id: '1',
          name: 'First Group',
          description: 'First description',
          createdBy: 'user1',
          memberCount: 10,
          isPublic: true,
          createdAt: DateTime.now(),
        ),
        Group(
          id: '2',
          name: 'Second Group',
          description: 'Second description',
          createdBy: 'user2',
          memberCount: 20,
          isPublic: false,
          createdAt: DateTime.now(),
        ),
        Group(
          id: '3',
          name: 'Third Group',
          description: 'Third description',
          createdBy: 'user3',
          memberCount: 30,
          isPublic: true,
          createdAt: DateTime.now(),
        ),
      ]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('First Group'), findsOneWidget);
      expect(find.text('Second Group'), findsOneWidget);
      expect(find.text('Third Group'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('can pull to refresh', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('group cards are tappable', (tester) async {
      final mockGroup = Group(
        id: 'group-123',
        name: 'Clickable Group',
        description: 'Description',
        createdBy: 'user-abc',
        memberCount: 10,
        isPublic: true,
        createdAt: DateTime.now(),
      );

      mockProvider.groups.add(mockGroup);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsAtLeastNWidgets(1));
    });

    testWidgets('displays group icons', (tester) async {
      final mockGroup = Group(
        id: 'group-123',
        name: 'Icon Group',
        description: 'Description',
        createdBy: 'user-abc',
        memberCount: 10,
        isPublic: true,
        createdAt: DateTime.now(),
      );

      mockProvider.groups.add(mockGroup);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.group), findsAtLeastNWidgets(1));
    });
  });
}
