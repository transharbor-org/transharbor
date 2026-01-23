import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/role_guard.dart';
import '../models/report.dart';
import '../providers/moderation_provider.dart';

/// Screen for moderators to view and manage reports
class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key});

  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen> {
  ReportStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if user has permission
      if (!RoleGuard.canModerate(context)) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You do not have permission to access this page'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      context.read<ModerationProvider>().fetchReports();
    });
  }

  Future<void> _refreshReports() async {
    await context.read<ModerationProvider>().fetchReports(
          status: _selectedFilter,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation'),
        actions: [
          Consumer<ModerationProvider>(
            builder: (context, provider, _) {
              if (provider.pendingCount > 0) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Chip(
                    label: Text('${provider.pendingCount} pending'),
                    backgroundColor: theme.colorScheme.errorContainer,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(theme),
          Expanded(
            child: Consumer<ModerationProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.reports.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${provider.error}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshReports,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.reports.isEmpty) {
                  return Center(
                    child: Text(
                      'No reports found',
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshReports,
                  child: ListView.builder(
                    itemCount: provider.reports.length,
                    itemBuilder: (context, index) {
                      final report = provider.reports[index];
                      return ReportCard(
                        report: report,
                        onStatusChanged: _refreshReports,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: theme.colorScheme.surfaceContainerHighest,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('All'),
              selected: _selectedFilter == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = null);
                  _refreshReports();
                }
              },
            ),
            const SizedBox(width: 8),
            ...ReportStatus.values.map((status) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_getStatusLabel(status)),
                  selected: _selectedFilter == status,
                  onSelected: (selected) {
                    setState(() => _selectedFilter = selected ? status : null);
                    _refreshReports();
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.dismissed:
        return 'Dismissed';
    }
  }
}

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onStatusChanged;

  const ReportCard({
    super.key,
    required this.report,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: _buildStatusIcon(theme),
        title: Text(
          '${_getTypeLabel()} - ${report.reason}',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          'Reported ${_formatDate(report.created)}',
          style: theme.textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Reporter ID:', report.reporterId, theme),
                _buildInfoRow(
                    'Reported Item ID:', report.reportedItemId, theme),
                _buildInfoRow('Type:', _getTypeLabel(), theme),
                _buildInfoRow('Status:', _getStatusLabel(), theme),
                const SizedBox(height: 16),
                Text(
                  'Description:',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  report.description,
                  style: theme.textTheme.bodyMedium,
                ),
                if (report.moderatorNotes != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Moderator Notes:',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.moderatorNotes!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 16),
                _buildActionButtons(context, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    IconData icon;
    Color color;

    switch (report.status) {
      case ReportStatus.pending:
        icon = Icons.pending;
        color = theme.colorScheme.error;
        break;
      case ReportStatus.underReview:
        icon = Icons.rate_review;
        color = theme.colorScheme.primary;
        break;
      case ReportStatus.resolved:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case ReportStatus.dismissed:
        icon = Icons.cancel;
        color = theme.colorScheme.outline;
        break;
    }

    return Icon(icon, color: color);
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    if (report.isResolved || report.isDismissed) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (report.isPending)
          OutlinedButton.icon(
            onPressed: () => _updateStatus(
              context,
              ReportStatus.underReview,
              'Marked as under review',
            ),
            icon: const Icon(Icons.rate_review, size: 18),
            label: const Text('Review'),
          ),
        FilledButton.icon(
          onPressed: () => _showResolveDialog(context),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Resolve'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _showDismissDialog(context),
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Dismiss'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Future<void> _updateStatus(
      BuildContext context, ReportStatus status, String successMessage,
      {String? notes}) async {
    final provider = context.read<ModerationProvider>();
    final success = await provider.updateReportStatus(
      reportId: report.id,
      status: status,
      moderatorNotes: notes,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
        onStatusChanged();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to update report'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showResolveDialog(BuildContext context) async {
    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add notes about the resolution (optional):'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Resolution notes...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _updateStatus(
        context,
        ReportStatus.resolved,
        'Report resolved',
        notes: notesController.text.isNotEmpty ? notesController.text : null,
      );
    }
  }

  Future<void> _showDismissDialog(BuildContext context) async {
    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dismiss Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add notes about why this was dismissed (optional):'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Dismissal notes...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _updateStatus(
        context,
        ReportStatus.dismissed,
        'Report dismissed',
        notes: notesController.text.isNotEmpty ? notesController.text : null,
      );
    }
  }

  String _getTypeLabel() {
    switch (report.type) {
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

  String _getStatusLabel() {
    switch (report.status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.dismissed:
        return 'Dismissed';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
