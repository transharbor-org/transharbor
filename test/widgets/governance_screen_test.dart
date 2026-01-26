import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:transharbor/features/governance/screens/governance_screen.dart';
import 'package:transharbor/features/governance/providers/governance_provider.dart';
import 'package:transharbor/features/governance/models/proposal.dart';

void main() {
  group('GovernanceScreen Widget Tests', () {
    late GovernanceProvider mockProvider;

    setUp(() {
      mockProvider = GovernanceProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<GovernanceProvider>.value(
          value: mockProvider,
          child: const GovernanceScreen(),
        ),
      );
    }

    testWidgets('displays app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Governance'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays governance introduction card', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.how_to_vote), findsAtLeastNWidgets(1));
      expect(find.text('Community Governance'), findsOneWidget);
    });

    testWidgets('displays governance description', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('TransHarbor is democratically governed'),
        findsOneWidget,
      );
    });

    testWidgets('displays Active Proposals section header', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Active Proposals'), findsOneWidget);
    });

    testWidgets('displays proposal when available', (tester) async {
      final mockProposal = Proposal(
        id: 'prop-123',
        title: 'Test Proposal',
        description: 'This is a test proposal',
        proposer: 'user-abc',
        status: ProposalStatus.active,
        votesFor: 10,
        votesAgainst: 5,
        createdAt: DateTime.now(),
        endsAt: DateTime.now().add(const Duration(days: 7)),
      );

      mockProvider.proposals.add(mockProposal);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test Proposal'), findsOneWidget);
      expect(find.text('This is a test proposal'), findsOneWidget);
    });

    testWidgets('displays vote counts', (tester) async {
      final mockProposal = Proposal(
        id: 'prop-123',
        title: 'Test Proposal',
        description: 'Description',
        proposer: 'user-abc',
        status: ProposalStatus.active,
        votesFor: 25,
        votesAgainst: 10,
        createdAt: DateTime.now(),
        endsAt: DateTime.now().add(const Duration(days: 7)),
      );

      mockProvider.proposals.add(mockProposal);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('25'), findsAtLeastNWidgets(1));
      expect(find.textContaining('10'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays proposal status badge', (tester) async {
      final mockProposal = Proposal(
        id: 'prop-123',
        title: 'Active Proposal',
        description: 'Description',
        proposer: 'user-abc',
        status: ProposalStatus.active,
        votesFor: 10,
        votesAgainst: 5,
        createdAt: DateTime.now(),
        endsAt: DateTime.now().add(const Duration(days: 7)),
      );

      mockProvider.proposals.add(mockProposal);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('displays multiple proposals', (tester) async {
      mockProvider.proposals.addAll([
        Proposal(
          id: '1',
          title: 'First Proposal',
          description: 'First description',
          proposer: 'user1',
          status: ProposalStatus.active,
          votesFor: 10,
          votesAgainst: 2,
          createdAt: DateTime.now(),
          endsAt: DateTime.now().add(const Duration(days: 7)),
        ),
        Proposal(
          id: '2',
          title: 'Second Proposal',
          description: 'Second description',
          proposer: 'user2',
          status: ProposalStatus.active,
          votesFor: 15,
          votesAgainst: 8,
          createdAt: DateTime.now(),
          endsAt: DateTime.now().add(const Duration(days: 5)),
        ),
      ]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('First Proposal'), findsOneWidget);
      expect(find.text('Second Proposal'), findsOneWidget);
    });

    testWidgets('shows no proposals message when empty', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No active proposals'), findsOneWidget);
    });

    testWidgets('proposal cards are tappable', (tester) async {
      final mockProposal = Proposal(
        id: 'prop-123',
        title: 'Clickable Proposal',
        description: 'Description',
        proposer: 'user-abc',
        status: ProposalStatus.active,
        votesFor: 10,
        votesAgainst: 5,
        createdAt: DateTime.now(),
        endsAt: DateTime.now().add(const Duration(days: 7)),
      );

      mockProvider.proposals.add(mockProposal);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsAtLeastNWidgets(1));
    });

    testWidgets('displays voting icons', (tester) async {
      final mockProposal = Proposal(
        id: 'prop-123',
        title: 'Test Proposal',
        description: 'Description',
        proposer: 'user-abc',
        status: ProposalStatus.active,
        votesFor: 10,
        votesAgainst: 5,
        createdAt: DateTime.now(),
        endsAt: DateTime.now().add(const Duration(days: 7)),
      );

      mockProvider.proposals.add(mockProposal);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.thumb_up), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.thumb_down), findsAtLeastNWidgets(1));
    });
  });
}
