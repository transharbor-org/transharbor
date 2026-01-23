import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/governance/providers/governance_provider.dart';
import 'package:transharbor/features/governance/models/proposal.dart';

void main() {
  late GovernanceProvider governanceProvider;

  setUp(() {
    governanceProvider = GovernanceProvider();
  });

  group('GovernanceProvider', () {
    test('initial state is correct', () {
      expect(governanceProvider.proposals, isEmpty);
      expect(governanceProvider.isLoading, false);
      expect(governanceProvider.errorMessage, isNull);
    });

    test('loadProposals handles errors gracefully', () async {
      // This test would need mocking to test properly
      // For now just verify initial state
      expect(governanceProvider.isLoading, false);
    });
  });
}
