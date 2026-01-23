/// Membership types for voting eligibility
enum MembershipType {
  /// Non-voting member - can participate but cannot vote on governance
  nonVoting('non_voting'),

  /// Full voting member - can participate and vote on all governance matters
  votingMember('voting_member');

  final String value;
  const MembershipType(this.value);

  /// Check if this membership type can vote
  bool get canVote => this == MembershipType.votingMember;

  /// Check if this is a full member
  bool get isFullMember => this == MembershipType.votingMember;

  /// Parse membership type from API string
  static MembershipType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'voting_member':
        return MembershipType.votingMember;
      case 'non_voting':
      default:
        return MembershipType.nonVoting;
    }
  }

  /// Convert to API string format
  String toApiString() => value;

  @override
  String toString() => value;
}
