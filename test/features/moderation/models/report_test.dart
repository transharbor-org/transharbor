import 'package:flutter_test/flutter_test.dart';
import 'package:transharbor/features/moderation/models/report.dart';

void main() {
  group('Report Model', () {
    test('creates report from JSON', () {
      final json = {
        'id': 'report123',
        'reporter': 'user1',
        'reportedItem': 'post123',
        'type': 'post',
        'reason': 'Spam',
        'description': 'This is spam content',
        'status': 'pending',
        'moderator': null,
        'moderatorNotes': null,
        'created': '2024-01-01T00:00:00.000Z',
        'updated': '2024-01-02T00:00:00.000Z',
      };

      final report = Report.fromJson(json);

      expect(report.id, 'report123');
      expect(report.reporterId, 'user1');
      expect(report.reportedItemId, 'post123');
      expect(report.type, ReportType.post);
      expect(report.reason, 'Spam');
      expect(report.description, 'This is spam content');
      expect(report.status, ReportStatus.pending);
      expect(report.moderatorId, isNull);
      expect(report.moderatorNotes, isNull);
    });

    test('converts report to JSON', () {
      final report = Report(
        id: 'report123',
        reporterId: 'user1',
        reportedItemId: 'post123',
        type: ReportType.post,
        reason: 'Spam',
        description: 'This is spam',
        status: ReportStatus.pending,
        created: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updated: DateTime.parse('2024-01-02T00:00:00.000Z'),
      );

      final json = report.toJson();

      expect(json['id'], 'report123');
      expect(json['reporter'], 'user1');
      expect(json['reportedItem'], 'post123');
      expect(json['type'], 'post');
      expect(json['reason'], 'Spam');
      expect(json['status'], 'pending');
    });

    test('parses all report types correctly', () {
      expect(Report.fromJson({'type': 'post', 'reporter': 'u1', 'reportedItem': 'i1', 'reason': 'r', 'description': 'd', 'status': 'pending'}).type, ReportType.post);
      expect(Report.fromJson({'type': 'user', 'reporter': 'u1', 'reportedItem': 'i1', 'reason': 'r', 'description': 'd', 'status': 'pending'}).type, ReportType.user);
      expect(Report.fromJson({'type': 'groupPost', 'reporter': 'u1', 'reportedItem': 'i1', 'reason': 'r', 'description': 'd', 'status': 'pending'}).type, ReportType.groupPost);
      expect(Report.fromJson({'type': 'message', 'reporter': 'u1', 'reportedItem': 'i1', 'reason': 'r', 'description': 'd', 'status': 'pending'}).type, ReportType.message);
    });

    test('parses all report statuses correctly', () {
      expect(Report.fromJson({'status': 'pending', 'reporter': 'u1', 'reportedItem': 'i1', 'type': 'post', 'reason': 'r', 'description': 'd'}).status, ReportStatus.pending);
      expect(Report.fromJson({'status': 'underReview', 'reporter': 'u1', 'reportedItem': 'i1', 'type': 'post', 'reason': 'r', 'description': 'd'}).status, ReportStatus.underReview);
      expect(Report.fromJson({'status': 'resolved', 'reporter': 'u1', 'reportedItem': 'i1', 'type': 'post', 'reason': 'r', 'description': 'd'}).status, ReportStatus.resolved);
      expect(Report.fromJson({'status': 'dismissed', 'reporter': 'u1', 'reportedItem': 'i1', 'type': 'post', 'reason': 'r', 'description': 'd'}).status, ReportStatus.dismissed);
    });

    test('status helper methods work correctly', () {
      final pendingReport = Report(
        id: '1',
        reporterId: 'user1',
        reportedItemId: 'item1',
        type: ReportType.post,
        reason: 'Spam',
        description: 'Test',
        status: ReportStatus.pending,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      expect(pendingReport.isPending, true);
      expect(pendingReport.isUnderReview, false);
      expect(pendingReport.isResolved, false);
      expect(pendingReport.isDismissed, false);

      final resolvedReport = pendingReport.copyWith(status: ReportStatus.resolved);

      expect(resolvedReport.isPending, false);
      expect(resolvedReport.isResolved, true);
    });

    test('copyWith creates new report with updated fields', () {
      final original = Report(
        id: '1',
        reporterId: 'user1',
        reportedItemId: 'item1',
        type: ReportType.post,
        reason: 'Spam',
        description: 'Original',
        status: ReportStatus.pending,
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      final updated = original.copyWith(
        status: ReportStatus.resolved,
        moderatorId: 'mod1',
        moderatorNotes: 'Resolved issue',
      );

      expect(updated.id, original.id);
      expect(updated.status, ReportStatus.resolved);
      expect(updated.moderatorId, 'mod1');
      expect(updated.moderatorNotes, 'Resolved issue');
      expect(updated.reason, original.reason);
    });

    test('handles null moderator fields', () {
      final json = {
        'id': 'report123',
        'reporter': 'user1',
        'reportedItem': 'post123',
        'type': 'post',
        'reason': 'Spam',
        'description': 'Test',
        'status': 'pending',
        'created': '2024-01-01T00:00:00.000Z',
        'updated': '2024-01-02T00:00:00.000Z',
      };

      final report = Report.fromJson(json);

      expect(report.moderatorId, isNull);
      expect(report.moderatorNotes, isNull);
    });
  });

  group('ReportReasons', () {
    test('has all expected reasons', () {
      expect(ReportReasons.all, contains('Spam'));
      expect(ReportReasons.all, contains('Harassment'));
      expect(ReportReasons.all, contains('Hate Speech'));
      expect(ReportReasons.all, contains('Violence'));
      expect(ReportReasons.all, contains('Misinformation'));
      expect(ReportReasons.all, contains('Inappropriate Content'));
      expect(ReportReasons.all, contains('Impersonation'));
      expect(ReportReasons.all, contains('Other'));
    });

    test('has correct count of reasons', () {
      expect(ReportReasons.all.length, 8);
    });

    test('individual reason constants are correct', () {
      expect(ReportReasons.spam, 'Spam');
      expect(ReportReasons.harassment, 'Harassment');
      expect(ReportReasons.hateSpeeech, 'Hate Speech');
      expect(ReportReasons.violence, 'Violence');
      expect(ReportReasons.misinformation, 'Misinformation');
      expect(ReportReasons.inappropriate, 'Inappropriate Content');
      expect(ReportReasons.impersonation, 'Impersonation');
      expect(ReportReasons.other, 'Other');
    });
  });

  group('ReportType Enum', () {
    test('has all expected values', () {
      expect(ReportType.values.length, 4);
      expect(ReportType.values, contains(ReportType.post));
      expect(ReportType.values, contains(ReportType.user));
      expect(ReportType.values, contains(ReportType.groupPost));
      expect(ReportType.values, contains(ReportType.message));
    });

    test('enum names are correct', () {
      expect(ReportType.post.name, 'post');
      expect(ReportType.user.name, 'user');
      expect(ReportType.groupPost.name, 'groupPost');
      expect(ReportType.message.name, 'message');
    });
  });

  group('ReportStatus Enum', () {
    test('has all expected values', () {
      expect(ReportStatus.values.length, 4);
      expect(ReportStatus.values, contains(ReportStatus.pending));
      expect(ReportStatus.values, contains(ReportStatus.underReview));
      expect(ReportStatus.values, contains(ReportStatus.resolved));
      expect(ReportStatus.values, contains(ReportStatus.dismissed));
    });

    test('enum names are correct', () {
      expect(ReportStatus.pending.name, 'pending');
      expect(ReportStatus.underReview.name, 'underReview');
      expect(ReportStatus.resolved.name, 'resolved');
      expect(ReportStatus.dismissed.name, 'dismissed');
    });
  });
}
