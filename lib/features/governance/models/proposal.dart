import 'package:pocketbase/pocketbase.dart';

class Proposal {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final DateTime createdAt;
  final DateTime votingEndsAt;
  final ProposalStatus status;
  final int votesFor;
  final int votesAgainst;
  final int votesAbstain;

  Proposal({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    required this.createdAt,
    required this.votingEndsAt,
    required this.status,
    this.votesFor = 0,
    this.votesAgainst = 0,
    this.votesAbstain = 0,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      authorId: json['author_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      votingEndsAt: DateTime.parse(json['voting_ends_at'] as String),
      status: ProposalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProposalStatus.active,
      ),
      votesFor: json['votes_for'] as int? ?? 0,
      votesAgainst: json['votes_against'] as int? ?? 0,
      votesAbstain: json['votes_abstain'] as int? ?? 0,
    );
  }

  factory Proposal.fromPocketBase(RecordModel record) {
    return Proposal(
      id: record.id,
      title: record.getStringValue('title'),
      description: record.getStringValue('description'),
      authorId: record.getStringValue('author'),
      createdAt: DateTime.parse(record.created),
      votingEndsAt: DateTime.parse(record.getStringValue('endDate')),
      status: ProposalStatus.values.firstWhere(
        (e) => e.name == record.getStringValue('status'),
        orElse: () => ProposalStatus.active,
      ),
      votesFor: record.getIntValue('votesFor'),
      votesAgainst: record.getIntValue('votesAgainst'),
      votesAbstain: record.getIntValue('votesAbstain'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author_id': authorId,
      'created_at': createdAt.toIso8601String(),
      'voting_ends_at': votingEndsAt.toIso8601String(),
      'status': status.name,
      'votes_for': votesFor,
      'votes_against': votesAgainst,
      'votes_abstain': votesAbstain,
    };
  }

  int get totalVotes => votesFor + votesAgainst + votesAbstain;
}

enum ProposalStatus {
  active,
  passed,
  rejected,
  expired,
}

enum VoteChoice {
  forProposal,
  against,
  abstain,
}

extension VoteChoiceExtension on VoteChoice {
  String get value {
    switch (this) {
      case VoteChoice.forProposal:
        return 'for';
      case VoteChoice.against:
        return 'against';
      case VoteChoice.abstain:
        return 'abstain';
    }
  }
}
