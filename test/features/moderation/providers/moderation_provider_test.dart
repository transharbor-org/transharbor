import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/core/services/pocketbase_service.dart';
import 'package:transharbor/features/moderation/providers/moderation_provider.dart';
import 'package:transharbor/features/moderation/models/report.dart';

void main() {
  group('ModerationProvider Tests', () {
    test('initializes with empty state',
        skip:
            'Requires platform plugin (flutter_secure_storage) not available in unit tests',
        () {
      final pocketBaseService = PocketBaseService();
      final moderationProvider = ModerationProvider(pocketBaseService);

      expect(moderationProvider.reports, isEmpty);
      expect(moderationProvider.pendingReports, isEmpty);
      expect(moderationProvider.isLoading, false);
      expect(moderationProvider.error, isNull);
    });

    test('has correct initial values',
        skip:
            'Requires platform plugin (flutter_secure_storage) not available in unit tests',
        () {
      final pocketBaseService = PocketBaseService();
      final moderationProvider = ModerationProvider(pocketBaseService);

      expect(moderationProvider.reports, isA<List<Report>>());
      expect(moderationProvider.pendingReports, isA<List<Report>>());
      expect(moderationProvider.isLoading, isA<bool>());
      expect(moderationProvider.error, isNull);
    });

    test('getters return correct types',
        skip:
            'Requires platform plugin (flutter_secure_storage) not available in unit tests',
        () {
      final pocketBaseService = PocketBaseService();
      final moderationProvider = ModerationProvider(pocketBaseService);

      expect(moderationProvider.reports, isA<List<Report>>());
      expect(moderationProvider.pendingReports, isA<List<Report>>());
      expect(moderationProvider.isLoading, false);
    });
  });

  group('ReportStatus Enum Tests', () {
    test('has all required statuses', () {
      expect(ReportStatus.pending.name, 'pending');
      expect(ReportStatus.underReview.name, 'underReview');
      expect(ReportStatus.resolved.name, 'resolved');
      expect(ReportStatus.dismissed.name, 'dismissed');
    });

    test('enum values exist', () {
      expect(ReportStatus.values.contains(ReportStatus.pending), isTrue);
      expect(ReportStatus.values.contains(ReportStatus.underReview), isTrue);
      expect(ReportStatus.values.contains(ReportStatus.resolved), isTrue);
      expect(ReportStatus.values.contains(ReportStatus.dismissed), isTrue);
    });
  });

  group('ReportType Enum Tests', () {
    test('has all required types', () {
      expect(ReportType.values.isNotEmpty, isTrue);
    });
  });
}
