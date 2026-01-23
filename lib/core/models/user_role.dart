/// User role enumeration for access control
enum UserRole {
  user,
  moderator,
  admin;

  /// Check if this role is moderator or admin
  bool get canModerate => this == UserRole.moderator || this == UserRole.admin;

  /// Check if this role is admin
  bool get isAdmin => this == UserRole.admin;

  /// Check if this role has elevated privileges
  bool get isPrivileged => canModerate || isAdmin;

  /// Convert string to UserRole
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'moderator':
        return UserRole.moderator;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  /// Convert UserRole to string for API
  String toApiString() {
    return name;
  }
}
