import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/features/messaging/screens/messages_list_screen.dart';
import 'package:transharbor/features/messaging/providers/messaging_provider.dart';
import 'package:transharbor/features/messaging/models/message.dart';

void main() {
  group('MessagesListScreen Widget Tests', () {
    late MessagingProvider mockProvider;

    setUp(() {
      mockProvider = MessagingProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<MessagingProvider>.value(
          value: mockProvider,
          child: const MessagesListScreen(),
        ),
      );
    }

    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Messages'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('displays new message button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no conversations', (tester) async {
      mockProvider.loadConversations();
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No conversations yet'), findsOneWidget);
      expect(find.text('Start a new conversation!'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('displays conversation list', (tester) async {
      final mockConversation = Conversation(
        id: 'conv-123',
        participants: ['user1', 'user2'],
        lastMessage: 'Hello there!',
        lastMessageTime: DateTime.now(),
        unreadCount: 2,
      );

      mockProvider.conversations.add(mockConversation);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Hello there!'), findsOneWidget);
    });

    testWidgets('displays unread count badge', (tester) async {
      final mockConversation = Conversation(
        id: 'conv-123',
        participants: ['user1', 'user2'],
        lastMessage: 'Test message',
        lastMessageTime: DateTime.now(),
        unreadCount: 5,
      );

      mockProvider.conversations.add(mockConversation);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('can pull to refresh', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('displays multiple conversations', (tester) async {
      mockProvider.conversations.addAll([
        Conversation(
          id: '1',
          participants: ['user1', 'user2'],
          lastMessage: 'First message',
          lastMessageTime: DateTime.now(),
          unreadCount: 0,
        ),
        Conversation(
          id: '2',
          participants: ['user1', 'user3'],
          lastMessage: 'Second message',
          lastMessageTime: DateTime.now(),
          unreadCount: 1,
        ),
        Conversation(
          id: '3',
          participants: ['user1', 'user4'],
          lastMessage: 'Third message',
          lastMessageTime: DateTime.now(),
          unreadCount: 2,
        ),
      ]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('First message'), findsOneWidget);
      expect(find.text('Second message'), findsOneWidget);
      expect(find.text('Third message'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('conversation tiles are tappable', (tester) async {
      final mockConversation = Conversation(
        id: 'conv-123',
        participants: ['user1', 'user2'],
        lastMessage: 'Tap me!',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
      );

      mockProvider.conversations.add(mockConversation);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('displays avatar circles', (tester) async {
      final mockConversation = Conversation(
        id: 'conv-123',
        participants: ['user1', 'user2'],
        lastMessage: 'Test',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
      );

      mockProvider.conversations.add(mockConversation);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CircleAvatar), findsAtLeastNWidgets(1));
    });
  });
}
