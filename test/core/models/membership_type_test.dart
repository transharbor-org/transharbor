import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/core/models/membership_type.dart';

void main() {
  group('MembershipType Enum', () {
    test('has all expected values', () {
      expect(MembershipType.values.length, 2);
      expect(MembershipType.values.contains(MembershipType.nonVoting), true);
      expect(MembershipType.values.contains(MembershipType.votingMember), true);
    });

    test('value property returns correct string', () {
      expect(MembershipType.nonVoting.value, 'non_voting');
      expect(MembershipType.votingMember.value, 'voting_member');
    });

    test('canVote returns true only for voting members', () {
      expect(MembershipType.votingMember.canVote, true);
      expect(MembershipType.nonVoting.canVote, false);
    });

    test('isFullMember returns true only for voting members', () {
      expect(MembershipType.votingMember.isFullMember, true);
      expect(MembershipType.nonVoting.isFullMember, false);
    });

    test('fromString parses voting_member correctly', () {
      expect(MembershipType.fromString('voting_member'),
          MembershipType.votingMember);
      expect(MembershipType.fromString('Voting_Member'),
          MembershipType.votingMember);
      expect(MembershipType.fromString('VOTING_MEMBER'),
          MembershipType.votingMember);
    });

    test('fromString parses non_voting correctly', () {
      expect(MembershipType.fromString('non_voting'), MembershipType.nonVoting);
      expect(MembershipType.fromString('Non_Voting'), MembershipType.nonVoting);
      expect(MembershipType.fromString('NON_VOTING'), MembershipType.nonVoting);
    });

    test('fromString defaults to non_voting for unknown values', () {
      expect(MembershipType.fromString('unknown'), MembershipType.nonVoting);
      expect(MembershipType.fromString(''), MembershipType.nonVoting);
      expect(MembershipType.fromString('invalid'), MembershipType.nonVoting);
    });

    test('toApiString returns correct string', () {
      expect(MembershipType.votingMember.toApiString(), 'voting_member');
      expect(MembershipType.nonVoting.toApiString(), 'non_voting');
    });

    test('toString returns correct string', () {
      expect(MembershipType.votingMember.toString(), 'voting_member');
      expect(MembershipType.nonVoting.toString(), 'non_voting');
    });
  });
}
