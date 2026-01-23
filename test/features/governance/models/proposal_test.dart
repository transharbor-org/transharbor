import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/governance/models/proposal.dart';
import 'package:transharbor/features/governance/models/vote.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('Proposal Model', () {
    test('creates proposal from JSON', () {
      final json = {
        'id': 'prop123',
        'title': 'Test Proposal',
        'description': 'A test proposal',
        'author': 'user123',
        'status': 'active',
        'votesFor': 10,
        'votesAgainst': 5,
        'votesAbstain': 2,
        'startDate': '2024-01-01T00:00:00.000Z',
        'endDate': '2024-01-10T00:00:00.000Z',
        'created': '2024-01-01T00:00:00.000Z',
        'updated': '2024-01-02T00:00:00.000Z',
      };

      final proposal = Proposal.fromJson(json);

      expect(proposal.id, 'prop123');
      expect(proposal.title, 'Test Proposal');
      expect(proposal.description, 'A test proposal');
      expect(proposal.authorId, 'user123');
      expect(proposal.status, 'active');
      expect(proposal.votesFor, 10);
      expect(proposal.votesAgainst, 5);
      expect(proposal.votesAbstain, 2);
    });

    test('converts proposal to JSON', () {
      final proposal = Proposal(
        id: 'prop123',
        title: 'Test Proposal',
        description: 'A test proposal',
        authorId: 'user123',
        status: 'active',
        votesFor: 10,
        votesAgainst: 5,
        votesAbstain: 2,
        startDate: DateTime.parse('2024-01-01T00:00:00.000Z'),
        endDate: DateTime.parse('2024-01-10T00:00:00.000Z'),
        created: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updated: DateTime.parse('2024-01-02T00:00:00.000Z'),
      );

      final json = proposal.toJson();

      expect(json['id'], 'prop123');
      expect(json['title'], 'Test Proposal');
      expect(json['status'], 'active');
      expect(json['votesFor'], 10);
    });

    test('creates proposal from PocketBase record', () {
      final record = MockRecordModel(
        id: 'prop123',
        collectionId: 'col123',
        collectionName: 'proposals',
        data: {
          'title': 'Test',
          'description': 'Description',
          'author': 'user123',
          'status': 'pending',
          'votesFor': 0,
          'votesAgainst': 0,
          'votesAbstain': 0,
          'startDate': '2024-01-01T00:00:00.000Z',
          'endDate': '2024-01-10T00:00:00.000Z',
        },
      );

      final proposal = Proposal.fromPocketBase(record);

      expect(proposal.id, 'prop123');
      expect(proposal.title, 'Test');
      expect(proposal.status, 'pending');
    });

    test('calculates total votes correctly', () {
      final proposal = Proposal(
        id: 'prop123',
        title: 'Test',
        description: 'Test',
        authorId: 'user123',
        status: 'active',
        votesFor: 10,
        votesAgainst: 5,
        votesAbstain: 3,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      expect(proposal.votesFor + proposal.votesAgainst + proposal.votesAbstain, 18);
    });
  });

  group('Vote Model', () {
    test('creates vote from JSON', () {
      final json = {
        'id': 'vote123',
        'proposal': 'prop123',
        'user': 'user123',
        'vote': 'for',
        'created': '2024-01-01T00:00:00.000Z',
        'updated': '2024-01-02T00:00:00.000Z',
      };

      final vote = Vote.fromJson(json);

      expect(vote.id, 'vote123');
      expect(vote.proposalId, 'prop123');
      expect(vote.userId, 'user123');
      expect(vote.vote, 'for');
    });

    test('creates vote from PocketBase record', () {
      final record = MockRecordModel(
        id: 'vote123',
        collectionId: 'col123',
        collectionName: 'votes',
        data: {
          'proposal': 'prop123',
          'user': 'user123',
          'vote': 'against',
        },
      );

      final vote = Vote.fromPocketBase(record);

      expect(vote.id, 'vote123');
      expect(vote.vote, 'against');
    });

    test('handles different vote types', () {
      final voteFor = Vote(
        id: '1',
        proposalId: 'prop1',
        userId: 'user1',
        vote: 'for',
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      final voteAgainst = Vote(
        id: '2',
        proposalId: 'prop1',
        userId: 'user2',
        vote: 'against',
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      final voteAbstain = Vote(
        id: '3',
        proposalId: 'prop1',
        userId: 'user3',
        vote: 'abstain',
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      expect(voteFor.vote, 'for');
      expect(voteAgainst.vote, 'against');
      expect(voteAbstain.vote, 'abstain');
    });
  });
}
