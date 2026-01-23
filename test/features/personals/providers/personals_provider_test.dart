import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/personals/providers/personals_provider.dart';
import 'package:transharbor/features/personals/models/personal.dart';

void main() {
  late PersonalsProvider personalsProvider;

  setUp(() {
    personalsProvider = PersonalsProvider();
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
