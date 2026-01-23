import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../core/services/pocketbase_service.dart';
import '../models/report.dart';

class ModerationProvider with ChangeNotifier {
  final PocketBaseService _pb;
  
  List<Report> _reports = [];
  List<Report> _pendingReports = [];
  bool _isLoading = false;
  String? _error;

  ModerationProvider(this._pb);

  List<Report> get reports => _reports;
  List<Report> get pendingReports => _pendingReports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all reports (admin/moderator view)
  Future<void> fetchReports({ReportStatus? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final filter = status != null ? 'status="${status.name}"' : '';
      final records = await _pb.pb.collection('reports').getFullList(
        sort: '-created',
        filter: filter,
      );

      _reports = records.map((record) => Report.fromPocketBase(record)).toList();
      _updatePendingReports();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch reports created by current user
  Future<void> fetchMyReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = _pb.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final records = await _pb.pb.collection('reports').getFullList(
        sort: '-created',
        filter: 'reporter="${currentUser.id}"',
      );

      _reports = records.map((record) => Report.fromPocketBase(record)).toList();
      _updatePendingReports();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new report
  Future<Report?> createReport({
    required String reportedItemId,
    required ReportType type,
    required String reason,
    required String description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = _pb.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final data = {
        'reporter': currentUser.id,
        'reportedItem': reportedItemId,
        'type': type.name,
        'reason': reason,
        'description': description,
        'status': ReportStatus.pending.name,
      };

      final record = await _pb.pb.collection('reports').create(body: data);
      final report = Report.fromPocketBase(record);

      _reports.insert(0, report);
      _updatePendingReports();
      notifyListeners();

      return report;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update report status (moderator action)
  Future<bool> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    String? moderatorNotes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = _pb.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final data = {
        'status': status.name,
        'moderator': currentUser.id,
        if (moderatorNotes != null) 'moderatorNotes': moderatorNotes,
      };

      final record = await _pb.pb.collection('reports').update(reportId, body: data);
      final updatedReport = Report.fromPocketBase(record);

      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = updatedReport;
      }
      _updatePendingReports();
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a single report by ID
  Future<Report?> getReport(String reportId) async {
    try {
      final record = await _pb.pb.collection('reports').getOne(reportId);
      return Report.fromPocketBase(record);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Delete a report (admin only)
  Future<bool> deleteReport(String reportId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _pb.pb.collection('reports').delete(reportId);
      _reports.removeWhere((r) => r.id == reportId);
      _updatePendingReports();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get count of pending reports
  int get pendingCount => _pendingReports.length;

  void updatePendingReports() {
    _pendingReports = _reports.where((r) => r.isPending).toList();
  }

  void _updatePendingReports() {
    updatePendingReports();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
