# Community Moderation Feature

## Overview

The TransHarbor app includes a comprehensive community moderation system that allows users to report inappropriate content and enables moderators/support staff to review and take action on reports.

## Features

### For Users
- **Report Content**: Users can report posts, group posts, messages, and other users
- **Predefined Reasons**: 8 common report reasons (Spam, Harassment, Hate Speech, Violence, Misinformation, Inappropriate Content, Impersonation, Other)
- **Detailed Descriptions**: Users can provide additional context for their reports
- **Track Reports**: Users can view the status of their submitted reports

### For Moderators/Support
- **Review Queue**: View all reports with filtering by status (Pending, Under Review, Resolved, Dismissed)
- **Pending Count**: Quick indicator of how many reports need attention
- **Status Management**: Mark reports as under review, resolve, or dismiss
- **Moderator Notes**: Add notes explaining the resolution or dismissal
- **Detailed View**: See full report details including reporter, reported item, reason, and description

## Report Types

1. **Post**: Report a personal ad post
2. **User**: Report a user profile
3. **Group Post**: Report content within a group
4. **Message**: Report a direct message

## Report Statuses

1. **Pending**: Newly created report awaiting review
2. **Under Review**: Moderator is actively investigating
3. **Resolved**: Action taken and issue addressed
4. **Dismissed**: Report was invalid or didn't require action

## Report Reasons

The system provides predefined reasons for consistency:

- **Spam**: Unsolicited or repetitive content
- **Harassment**: Bullying, threats, or targeted attacks
- **Hate Speech**: Content promoting hatred or discrimination
- **Violence**: Threats or depictions of violence
- **Misinformation**: False or misleading information
- **Inappropriate Content**: NSFW or otherwise unsuitable content
- **Impersonation**: Pretending to be someone else
- **Other**: Any reason not covered above

## Usage Examples

### Reporting Content

```dart
import 'package:transharbor/core/utils/moderation_helpers.dart';

// Report a post
ModerationHelpers.showReportPostDialog(
  context,
  postId: 'post123',
  postPreview: 'This is the post content...',
);

// Report a user
ModerationHelpers.showReportUserDialog(
  context,
  userId: 'user456',
  username: 'johndoe',
);

// Report a group post
ModerationHelpers.showReportGroupPostDialog(
  context,
  postId: 'groupPost789',
  postPreview: 'Group post content...',
);

// Report a message
ModerationHelpers.showReportMessageDialog(
  context,
  messageId: 'message123',
  messagePreview: 'Message content...',
);
```

### Accessing Moderation Screen

Moderators can access the moderation dashboard:

```dart
import 'package:go_router/go_router.dart';

// Navigate to moderation screen
context.go('/moderation');
```

### Using ModerationProvider

```dart
import 'package:provider/provider.dart';
import 'package:transharbor/features/moderation/providers/moderation_provider.dart';

// Get the provider
final moderationProvider = context.read<ModerationProvider>();

// Fetch all reports
await moderationProvider.fetchReports();

// Fetch only pending reports
await moderationProvider.fetchReports(status: ReportStatus.pending);

// Fetch user's own reports
await moderationProvider.fetchMyReports();

// Create a report
final report = await moderationProvider.createReport(
  reportedItemId: 'post123',
  type: ReportType.post,
  reason: 'Spam',
  description: 'This post contains spam content',
);

// Update report status (moderator action)
final success = await moderationProvider.updateReportStatus(
  reportId: 'report123',
  status: ReportStatus.resolved,
  moderatorNotes: 'Content removed and user warned',
);

// Delete a report (admin only)
await moderationProvider.deleteReport('report123');

// Get pending report count
final pendingCount = moderationProvider.pendingCount;
```

## PocketBase Schema

The moderation system uses the `reports` collection with the following schema:

```json
{
  "id": "reports",
  "name": "reports",
  "type": "base",
  "schema": [
    {"name": "reporter", "type": "relation", "options": {"collectionId": "users"}},
    {"name": "reportedItem", "type": "text"},
    {"name": "type", "type": "select", "options": {"values": ["post", "user", "groupPost", "message"]}},
    {"name": "reason", "type": "text"},
    {"name": "description", "type": "text"},
    {"name": "status", "type": "select", "options": {"values": ["pending", "underReview", "resolved", "dismissed"]}},
    {"name": "moderator", "type": "relation", "options": {"collectionId": "users"}},
    {"name": "moderatorNotes", "type": "text"}
  ]
}
```

### Access Rules

- **List/View**: Users can see their own reports; moderators/admins can see all reports
- **Create**: Any authenticated user can create a report
- **Update**: Only moderators and admins can update report status
- **Delete**: Only admins can delete reports

### User Roles

The moderation system uses role-based access control:

- **User**: Can submit reports about content and users
- **Moderator**: Can view all reports, update statuses, and add notes
- **Admin**: Full access including deleting reports and managing users

See [ROLES_AND_PERMISSIONS.md](ROLES_AND_PERMISSIONS.md) for detailed information about user roles.

## Integration Points

### Add Report Button to Posts

```dart
IconButton(
  icon: Icon(Icons.flag),
  onPressed: () {
    ModerationHelpers.showReportPostDialog(
      context,
      postId: post.id,
      postPreview: post.content,
    );
  },
)
```

### Add Report Button to User Profiles

```dart
IconButton(
  icon: Icon(Icons.report),
  onPressed: () {
    ModerationHelpers.showReportUserDialog(
      context,
      userId: user.id,
      username: user.username,
    );
  },
)
```

### Show Moderator Badge in App Bar

```dart
Consumer<ModerationProvider>(
  builder: (context, provider, _) {
    if (provider.pendingCount > 0) {
      return Badge(
        label: Text('${provider.pendingCount}'),
        child: IconButton(
          icon: Icon(Icons.shield),
          onPressed: () => context.go('/moderation'),
        ),
      );
    }
    return SizedBox.shrink();
  },
)
```

## Testing

The moderation feature includes comprehensive tests:

- **Model Tests**: `test/features/moderation/models/report_test.dart`
  - JSON serialization/deserialization
  - PocketBase integration
  - Helper methods and enums

- **Provider Tests**: `test/features/moderation/providers/moderation_provider_test.dart`
  - Fetching reports
  - Creating reports
  - Updating report status
  - Error handling

- **Screen Tests**: 
  - `test/features/moderation/screens/report_dialog_test.dart`
  - `test/features/moderation/screens/moderation_screen_test.dart`
  - Widget rendering and interactions
  - Form validation
  - User workflows

Run all moderation tests:
```bash
flutter test test/features/moderation/
```

## Security Considerations

1. **User Privacy**: Reporter information is stored but not publicly visible
2. **Moderator Accountability**: All moderator actions are logged with moderator ID
3. **Role-Based Access**: Only moderators/admins can update report status
4. **Audit Trail**: Timestamps and notes provide complete history
5. **Data Retention**: Admins can delete old resolved reports

## Future Enhancements

- **Email Notifications**: Notify moderators of new reports
- **Auto-Moderation**: Flag content with multiple reports
- **Appeals System**: Allow users to appeal moderator decisions
- **Reporting Analytics**: Dashboard with report statistics
- **Content Filters**: Automatically detect problematic content
- **User Reputation**: Track user report history

## Best Practices

1. **Quick Response**: Address pending reports within 24 hours
2. **Clear Notes**: Always add moderator notes explaining decisions
3. **Consistent Standards**: Apply community guidelines uniformly
4. **User Communication**: Consider notifying users of actions taken
5. **False Reports**: Track users who frequently file invalid reports
6. **Transparency**: Publish moderation statistics to community

## Support

For questions about the moderation system, contact the development team or refer to the main project documentation.
