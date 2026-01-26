import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/governance/models/proposal.dart';

void main() {
  group('VoteChoiceExtension', () {
    test('forProposal.value returns "for"', () {
      expect(VoteChoice.forProposal.value, equals('for'));
    });

    test('against.value returns "against"', () {
      expect(VoteChoice.against.value, equals('against'));
    });

    test('abstain.value returns "abstain"', () {
      expect(VoteChoice.abstain.value, equals('abstain'));
    });

    test('all VoteChoice values have non-empty string representations', () {
      for (final choice in VoteChoice.values) {
        expect(choice.value, isNotEmpty);
        expect(choice.value, isA<String>());
      }
    });

    test('value strings are lowercase', () {
      for (final choice in VoteChoice.values) {
        expect(choice.value, equals(choice.value.toLowerCase()));
      }
    });
  });
}
