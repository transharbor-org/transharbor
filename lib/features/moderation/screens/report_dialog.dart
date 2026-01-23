import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../providers/moderation_provider.dart';

/// Dialog to report a post or user
class ReportDialog extends StatefulWidget {
  final String reportedItemId;
  final ReportType type;
  final String itemPreview; // Short preview of the item being reported

  const ReportDialog({
    super.key,
    required this.reportedItemId,
    required this.type,
    this.itemPreview = '',
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason')),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a description')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final provider = context.read<ModerationProvider>();
    final report = await provider.createReport(
      reportedItemId: widget.reportedItemId,
      type: widget.type,
      reason: _selectedReason!,
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    if (report != null) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to submit report'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Report ${_getTypeLabel()}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.itemPreview.isNotEmpty) ...[
              Text(
                'Reporting:',
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.itemPreview,
                  style: theme.textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Reason',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...ReportReasons.all.map((reason) {
              return RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        setState(() => _selectedReason = value);
                      },
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 16),
            Text(
              'Description',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              enabled: !_isSubmitting,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Please provide more details...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submitReport,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit Report'),
        ),
      ],
    );
  }

  String _getTypeLabel() {
    switch (widget.type) {
      case ReportType.post:
        return 'Post';
      case ReportType.user:
        return 'User';
      case ReportType.groupPost:
        return 'Group Post';
      case ReportType.message:
        return 'Message';
    }
  }
}
