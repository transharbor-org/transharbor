import 'package:flutter/material.dart';
import '../features/moderation/screens/report_dialog.dart';
import '../features/moderation/models/report.dart';

/// Helper class for showing moderation-related dialogs
class ModerationHelpers {
  /// Show a dialog to report a post
  static Future<bool?> showReportPostDialog(
    BuildContext context, {
    required String postId,
    String postPreview = '',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ReportDialog(
        reportedItemId: postId,
        type: ReportType.post,
        itemPreview: postPreview,
      ),
    );
  }

  /// Show a dialog to report a group post
  static Future<bool?> showReportGroupPostDialog(
    BuildContext context, {
    required String postId,
    String postPreview = '',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ReportDialog(
        reportedItemId: postId,
        type: ReportType.groupPost,
        itemPreview: postPreview,
      ),
    );
  }

  /// Show a dialog to report a user
  static Future<bool?> showReportUserDialog(
    BuildContext context, {
    required String userId,
    String username = '',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ReportDialog(
        reportedItemId: userId,
        type: ReportType.user,
        itemPreview: username.isNotEmpty ? '@$username' : '',
      ),
    );
  }

  /// Show a dialog to report a message
  static Future<bool?> showReportMessageDialog(
    BuildContext context, {
    required String messageId,
    String messagePreview = '',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ReportDialog(
        reportedItemId: messageId,
        type: ReportType.message,
        itemPreview: messagePreview,
      ),
    );
  }
}
