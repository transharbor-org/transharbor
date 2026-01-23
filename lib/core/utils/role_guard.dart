import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../models/user_role.dart';

/// Utilities for role-based access control
class RoleGuard {
  /// Check if current user has moderator or admin role
  static bool canModerate(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return authProvider.currentUser?.canModerate ?? false;
  }

  /// Check if current user is an admin
  static bool isAdmin(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return authProvider.currentUser?.isAdmin ?? false;
  }

  /// Check if current user has any privileged role
  static bool isPrivileged(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return authProvider.currentUser?.isPrivileged ?? false;
  }

  /// Check if current user has specific role
  static bool hasRole(BuildContext context, UserRole role) {
    final authProvider = context.read<AuthProvider>();
    return authProvider.currentUser?.role == role;
  }

  /// Get current user's role
  static UserRole? getCurrentRole(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return authProvider.currentUser?.role;
  }
}

/// Widget that only shows content if user has moderator or admin role
class ModeratorOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const ModeratorOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.currentUser?.canModerate ?? false) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Widget that only shows content if user has admin role
class AdminOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.currentUser?.isAdmin ?? false) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Widget that only shows content if user has any privileged role
class PrivilegedOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const PrivilegedOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.currentUser?.isPrivileged ?? false) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Widget that shows content based on user role
class RoleBasedWidget extends StatelessWidget {
  final Widget? adminWidget;
  final Widget? moderatorWidget;
  final Widget? userWidget;
  final Widget? fallback;

  const RoleBasedWidget({
    super.key,
    this.adminWidget,
    this.moderatorWidget,
    this.userWidget,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final role = auth.currentUser?.role;
        
        switch (role) {
          case UserRole.admin:
            return adminWidget ?? moderatorWidget ?? userWidget ?? fallback ?? const SizedBox.shrink();
          case UserRole.moderator:
            return moderatorWidget ?? userWidget ?? fallback ?? const SizedBox.shrink();
          case UserRole.user:
            return userWidget ?? fallback ?? const SizedBox.shrink();
          default:
            return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }
}
