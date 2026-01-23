import 'package:pocketbase/pocketbase.dart';

/// Types of content that can be reported
enum ReportType {
  post,
  user,
  groupPost,
  message,
}

/// Report status
enum ReportStatus {
  pending,
  underReview,
  resolved,
  dismissed,
}

/// Represents a report filed by a user
class Report {
  final String id;
  final String reporterId;
  final String reportedItemId;
  final ReportType type;
  final String reason;
  final String description;
  final ReportStatus status;
  final String? moderatorId;
  final String? moderatorNotes;
  final DateTime created;
  final DateTime updated;

  Report({
    required this.id,
    required this.reporterId,
    required this.reportedItemId,
    required this.type,
    required this.reason,
    required this.description,
    required this.status,
    this.moderatorId,
    this.moderatorNotes,
    required this.created,
    required this.updated,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      reporterId: json['reporter'] ?? '',
      reportedItemId: json['reportedItem'] ?? '',
      type: _parseReportType(json['type'] ?? 'post'),
      reason: json['reason'] ?? '',
      description: json['description'] ?? '',
      status: _parseReportStatus(json['status'] ?? 'pending'),
      moderatorId: json['moderator'],
      moderatorNotes: json['moderatorNotes'],
      created: DateTime.parse(json['created'] ?? DateTime.now().toIso8601String()),
      updated: DateTime.parse(json['updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory Report.fromPocketBase(RecordModel record) {
    return Report(
      id: record.id,
      reporterId: record.getStringValue('reporter'),
      reportedItemId: record.getStringValue('reportedItem'),
      type: _parseReportType(record.getStringValue('type')),
      reason: record.getStringValue('reason'),
      description: record.getStringValue('description'),
      status: _parseReportStatus(record.getStringValue('status')),
      moderatorId: record.getStringValue('moderator').isEmpty ? null : record.getStringValue('moderator'),
      moderatorNotes: record.getStringValue('moderatorNotes').isEmpty ? null : record.getStringValue('moderatorNotes'),
      created: DateTime.parse(record.created),
      updated: DateTime.parse(record.updated),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter': reporterId,
      'reportedItem': reportedItemId,
      'type': type.name,
      'reason': reason,
      'description': description,
      'status': status.name,
      'moderator': moderatorId,
      'moderatorNotes': moderatorNotes,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  static ReportType _parseReportType(String type) {
    switch (type.toLowerCase()) {
      case 'post':
        return ReportType.post;
      case 'user':
        return ReportType.user;
      case 'grouppost':
      case 'group_post':
        return ReportType.groupPost;
      case 'message':
        return ReportType.message;
      default:
        return ReportType.post;
    }
  }

  static ReportStatus _parseReportStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ReportStatus.pending;
      case 'underreview':
      case 'under_review':
        return ReportStatus.underReview;
      case 'resolved':
        return ReportStatus.resolved;
      case 'dismissed':
        return ReportStatus.dismissed;
      default:
        return ReportStatus.pending;
    }
  }

  Report copyWith({
    String? id,
    String? reporterId,
    String? reportedItemId,
    ReportType? type,
    String? reason,
    String? description,
    ReportStatus? status,
    String? moderatorId,
    String? moderatorNotes,
    DateTime? created,
    DateTime? updated,
  }) {
    return Report(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reportedItemId: reportedItemId ?? this.reportedItemId,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      moderatorId: moderatorId ?? this.moderatorId,
      moderatorNotes: moderatorNotes ?? this.moderatorNotes,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  bool get isPending => status == ReportStatus.pending;
  bool get isUnderReview => status == ReportStatus.underReview;
  bool get isResolved => status == ReportStatus.resolved;
  bool get isDismissed => status == ReportStatus.dismissed;
}

/// Common report reasons
class ReportReasons {
  static const String spam = 'Spam';
  static const String harassment = 'Harassment';
  static const String hateSpeeech = 'Hate Speech';
  static const String violence = 'Violence';
  static const String misinformation = 'Misinformation';
  static const String inappropriate = 'Inappropriate Content';
  static const String impersonation = 'Impersonation';
  static const String other = 'Other';

  static List<String> get all => [
        spam,
        harassment,
        hateSpeeech,
        violence,
        misinformation,
        inappropriate,
        impersonation,
        other,
      ];
}
