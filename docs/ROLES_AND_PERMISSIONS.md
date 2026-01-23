# Admin and Moderator Access Control

## Overview

TransHarbor implements role-based access control (RBAC) with three user roles:

- **User**: Standard user with basic permissions
- **Moderator**: Can review and manage content reports
- **Admin**: Full system access including user role management

> **Note**: Roles control system permissions. For voting eligibility, see [Membership Types](MEMBERSHIP_TYPES.md).

## User Roles

### Role Hierarchy

```
Admin (highest privileges)
  ├── Can do everything Moderators can do
  ├── Manage user roles (promote/demote users)
  ├── Access admin management screen
  └── Delete any content
  
Moderator
  ├── Can do everything Users can do
  ├── Review and manage reports
  ├── Update report statuses
  └── Add moderator notes
  
User (default)
  ├── Create and manage own content
  ├── Submit reports
  └── Standard app features
```

### Role Enum

```dart
enum UserRole {
  user,      // Default role
  moderator, // Content moderation
  admin;     // Full system access
}
```

## Implementation

### User Model

The `User` model includes role information and helper methods:

```dart
class User {
  final UserRole role;
  
  // Helper methods
  bool get canModerate => role.canModerate;
  bool get isAdmin => role.isAdmin;
  bool get isPrivileged => role.isPrivileged;
}
```

### Auth Provider

The `AuthProvider` exposes role-checking methods:

```dart
final authProvider = context.read<AuthProvider>();

// Check permissions
bool canModerate = authProvider.canModerate;
bool isAdmin = authProvider.isAdmin;
bool isPrivileged = authProvider.isPrivileged;
UserRole? role = authProvider.userRole;
```

### Role Guard Utilities

Use `RoleGuard` for quick permission checks:

```dart
import 'package:transharbor/core/utils/role_guard.dart';

// Check if user can moderate
if (RoleGuard.canModerate(context)) {
  // Show moderator features
}

// Check if user is admin
if (RoleGuard.isAdmin(context)) {
  // Show admin features
}

// Check for specific role
if (RoleGuard.hasRole(context, UserRole.moderator)) {
  // Moderator-specific logic
}
```

### Guard Widgets

#### ModeratorOnly

Shows content only to moderators and admins:

```dart
ModeratorOnly(
  child: ListTile(
    title: Text('Moderation Dashboard'),
    onTap: () => context.go('/moderation'),
  ),
)
```

#### AdminOnly

Shows content only to admins:

```dart
AdminOnly(
  child: ListTile(
    title: Text('User Management'),
    onTap: () => context.go('/admin'),
  ),
)
```

#### PrivilegedOnly

Shows content to any privileged user (moderator or admin):

```dart
PrivilegedOnly(
  child: FloatingActionButton(
    onPressed: () => showModerationTools(),
    child: Icon(Icons.shield),
  ),
)
```

#### RoleBasedWidget

Shows different content based on role:

```dart
RoleBasedWidget(
  adminWidget: Text('Admin Dashboard'),
  moderatorWidget: Text('Moderator Tools'),
  userWidget: Text('User Profile'),
  fallback: Text('Not authenticated'),
)
```

## Admin Management

### User Management Screen

Admins can access the user management screen at `/admin`:

```dart
// Navigate to admin screen
context.go('/admin');
```

Features:
- View all users with their roles
- Change user roles (user → moderator → admin)
- See user registration dates
- Role-based visual indicators (colors and icons)

### Changing User Roles

```dart
// Programmatically update a user's role
await PocketBaseService().pb.collection('users').update(userId, body: {
  'role': 'moderator', // or 'admin' or 'user'
});
```

## PocketBase Schema

The users collection includes a `role` field:

```json
{
  "name": "role",
  "type": "select",
  "required": true,
  "options": {
    "maxSelect": 1,
    "values": ["user", "moderator", "admin"]
  }
}
```

### Access Rules

**Users Collection:**
- List: Any authenticated user
- View: Any authenticated user
- Create: Public (registration)
- Update: Own profile only
- Delete: Own profile only

**Reports Collection:**
- List: Reporter or moderator/admin
- View: Reporter or moderator/admin
- Create: Any authenticated user
- Update: Moderator/admin only
- Delete: Admin only

**Other Collections:**
- Standard CRUD rules with role-based exceptions
- Moderators can manage reported content
- Admins have override access

## Setting Initial Roles

### Via PocketBase Admin UI

1. Access PocketBase admin: `http://localhost:8090/_/`
2. Navigate to Users collection
3. Edit user record
4. Set `role` field to desired value

### Via API (Programmatic)

```dart
// Promote user to moderator
await pb.collection('users').update(userId, body: {
  'role': 'moderator',
});

// Promote user to admin
await pb.collection('users').update(userId, body: {
  'role': 'admin',
});

// Demote to regular user
await pb.collection('users').update(userId, body: {
  'role': 'user',
});
```

## Common Usage Patterns

### Navigation Menu

```dart
Drawer(
  child: ListView(
    children: [
      // Standard items for all users
      ListTile(
        title: Text('Home'),
        onTap: () => context.go('/home'),
      ),
      
      // Moderator/Admin only
      ModeratorOnly(
        child: ListTile(
          leading: Icon(Icons.shield),
          title: Text('Moderation'),
          onTap: () => context.go('/moderation'),
        ),
      ),
      
      // Admin only
      AdminOnly(
        child: ListTile(
          leading: Icon(Icons.admin_panel_settings),
          title: Text('Admin'),
          onTap: () => context.go('/admin'),
        ),
      ),
    ],
  ),
)
```

### AppBar Actions

```dart
AppBar(
  title: Text('TransHarbor'),
  actions: [
    // Show moderation badge for moderators
    Consumer<ModerationProvider>(
      builder: (context, moderation, _) {
        if (!RoleGuard.canModerate(context)) return SizedBox.shrink();
        
        return Badge(
          label: Text('${moderation.pendingCount}'),
          child: IconButton(
            icon: Icon(Icons.flag),
            onPressed: () => context.go('/moderation'),
          ),
        );
      },
    ),
    
    // Admin settings for admins
    AdminOnly(
      child: IconButton(
        icon: Icon(Icons.admin_panel_settings),
        onPressed: () => context.go('/admin'),
      ),
    ),
  ],
)
```

### Protected Routes

```dart
// In screen's initState or build
if (!RoleGuard.canModerate(context)) {
  Navigator.of(context).pop();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Access denied')),
  );
  return;
}
```

### Content Actions

```dart
// Show delete button only to content author or moderators
if (isAuthor || RoleGuard.canModerate(context)) {
  IconButton(
    icon: Icon(Icons.delete),
    onPressed: () => deleteContent(),
  );
}
```

## Security Considerations

1. **Client-Side Checks**: Role checks in Flutter are for UX only
2. **Server-Side Enforcement**: PocketBase access rules enforce permissions
3. **Token-Based**: User role is in the auth token
4. **Audit Trail**: Role changes should be logged (future enhancement)
5. **Least Privilege**: Users start with minimal permissions

## Best Practices

1. **Always check on server**: Client checks are for UI only
2. **Use guard widgets**: Cleaner than inline conditionals
3. **Consistent naming**: Use `canModerate`, `isAdmin` throughout
4. **Document permissions**: Clear comments on restricted features
5. **Test thoroughly**: Verify access control in all scenarios
6. **Log role changes**: Track who changes user roles (admin audit)

## Testing

```dart
// Test role-based widgets
testWidgets('ModeratorOnly shows for moderator', (tester) async {
  final mockAuth = MockAuthProvider();
  when(mockAuth.currentUser).thenReturn(
    User(role: UserRole.moderator, ...),
  );
  
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authProvider.overrideWith(() => mockAuth)],
      child: ModeratorOnly(child: Text('Secret')),
    ),
  );
  
  expect(find.text('Secret'), findsOneWidget);
});
```

## Future Enhancements

- [ ] Custom role permissions
- [ ] Role change notifications
- [ ] Role history/audit log
- [ ] Temporary role grants
- [ ] Role-based feature flags
- [ ] Multi-role support
- [ ] Role expiration dates

## Support

For role-related issues:
1. Check PocketBase admin UI for correct role values
2. Verify auth token includes role field
3. Test access rules in PocketBase
4. Review server logs for permission errors
