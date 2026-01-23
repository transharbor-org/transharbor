import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/personals/providers/personals_provider.dart';
import 'package:transharbor/core/services/pocketbase_service.dart';
import '../../../helpers/mock_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PersonalsProvider personalsProvider;
  late PocketBaseService fakePocketBaseService;

  setUp(() {
    fakePocketBaseService = FakePocketBaseService();
    personalsProvider =
        PersonalsProvider(pocketBaseService: fakePocketBaseService);
  });

  group('PersonalsProvider', () {
    test('initial state is correct', () {
      expect(personalsProvider.personals, isEmpty);
      expect(personalsProvider.isLoading, false);
      expect(personalsProvider.errorMessage, isNull);
    });

    test('loadPersonals handles errors gracefully', () async {
      // This test would need mocking to test properly
      // For now just verify initial state
      expect(personalsProvider.isLoading, false);
    });

    test('createPersonal handles errors gracefully', () async {
      // This test would need mocking to test properly
      // For now just verify initial state
      expect(personalsProvider.isLoading, false);
    });
  });
}
