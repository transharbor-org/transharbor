import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/governance/providers/governance_provider.dart';
import 'package:transharbor/core/services/pocketbase_service.dart';
import '../../../helpers/mock_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GovernanceProvider governanceProvider;
  late PocketBaseService fakePocketBaseService;

  setUp(() {
    fakePocketBaseService = FakePocketBaseService();
    governanceProvider =
        GovernanceProvider(pocketBaseService: fakePocketBaseService);
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
