import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/governance/models/proposal.dart';

void main() {
  group('Proposal Model', () {
    final now = DateTime.now();
    final futureDate = now.add(const Duration(days: 7));

    test('creates proposal with required fields', () {
      final proposal = Proposal(
        id: '123',
        title: 'Test Proposal',
        description: 'A test proposal',
        authorId: 'user123',
        createdAt: now,
        votingEndsAt: futureDate,
        status: ProposalStatus.active,
      );

      expect(proposal.id, '123');
      expect(proposal.title, 'Test Proposal');
      expect(proposal.description, 'A test proposal');
      expect(proposal.authorId, 'user123');
      expect(proposal.status, ProposalStatus.active);
      expect(proposal.votesFor, 0);
      expect(proposal.votesAgainst, 0);
      expect(proposal.votesAbstain, 0);
    });

    test('creates proposal with vote counts', () {
      final proposal = Proposal(
        id: '123',
        title: 'Test Proposal',
        description: 'A test proposal',
        authorId: 'user123',
        createdAt: now,
        votingEndsAt: futureDate,
        status: ProposalStatus.active,
        votesFor: 10,
        votesAgainst: 5,
        votesAbstain: 2,
      );

      expect(proposal.votesFor, 10);
      expect(proposal.votesAgainst, 5);
      expect(proposal.votesAbstain, 2);
      expect(proposal.totalVotes, 17);
    });

    test('fromJson creates proposal correctly', () {
      final json = {
        'id': '123',
        'title': 'Test Proposal',
        'description': 'A test proposal',
        'author': 'user123',
        'created': now.toIso8601String(),
        'endDate': futureDate.toIso8601String(),
        'status': 'active',
        'votesFor': 10,
        'votesAgainst': 5,
        'votesAbstain': 2,
      };

      final proposal = Proposal.fromJson(json);

      expect(proposal.id, '123');
      expect(proposal.title, 'Test Proposal');
      expect(proposal.authorId, 'user123');
      expect(proposal.status, ProposalStatus.active);
      expect(proposal.votesFor, 10);
      expect(proposal.votesAgainst, 5);
      expect(proposal.votesAbstain, 2);
    });

    test('fromJson handles missing vote counts', () {
      final json = {
        'id': '123',
        'title': 'Test Proposal',
        'description': 'A test proposal',
        'author': 'user123',
        'created': now.toIso8601String(),
        'endDate': futureDate.toIso8601String(),
        'status': 'active',
      };

      final proposal = Proposal.fromJson(json);

      expect(proposal.votesFor, 0);
      expect(proposal.votesAgainst, 0);
      expect(proposal.votesAbstain, 0);
      expect(proposal.totalVotes, 0);
    });

    test('toJson serializes proposal correctly', () {
      final proposal = Proposal(
        id: '123',
        title: 'Test Proposal',
        description: 'A test proposal',
        authorId: 'user123',
        createdAt: now,
        votingEndsAt: futureDate,
        status: ProposalStatus.passed,
        votesFor: 10,
        votesAgainst: 5,
        votesAbstain: 2,
      );

      final json = proposal.toJson();

      expect(json['id'], '123');
      expect(json['title'], 'Test Proposal');
      expect(json['author'], 'user123');
      expect(json['status'], 'passed');
      expect(json['votesFor'], 10);
      expect(json['votesAgainst'], 5);
      expect(json['votesAbstain'], 2);
    });

    test('totalVotes calculates correctly', () {
      final proposal = Proposal(
        id: '123',
        title: 'Test',
        description: 'Test',
        authorId: 'user123',
        createdAt: now,
        votingEndsAt: futureDate,
        status: ProposalStatus.active,
        votesFor: 100,
        votesAgainst: 50,
        votesAbstain: 25,
      );

      expect(proposal.totalVotes, 175);
    });
  });

  group('ProposalStatus Enum', () {
    test('has all expected values', () {
      expect(ProposalStatus.values.length, 4);
      expect(ProposalStatus.values.contains(ProposalStatus.active), true);
      expect(ProposalStatus.values.contains(ProposalStatus.passed), true);
      expect(ProposalStatus.values.contains(ProposalStatus.rejected), true);
      expect(ProposalStatus.values.contains(ProposalStatus.expired), true);
    });

    test('name property returns correct string', () {
      expect(ProposalStatus.active.name, 'active');
      expect(ProposalStatus.passed.name, 'passed');
      expect(ProposalStatus.rejected.name, 'rejected');
      expect(ProposalStatus.expired.name, 'expired');
    });
  });

  group('VoteChoice Enum', () {
    test('has all expected values', () {
      expect(VoteChoice.values.length, 3);
      expect(VoteChoice.values.contains(VoteChoice.forProposal), true);
      expect(VoteChoice.values.contains(VoteChoice.against), true);
      expect(VoteChoice.values.contains(VoteChoice.abstain), true);
    });
  });
}
