import 'package:pocketbase/pocketbase.dart';
import 'user_role.dart';
import 'membership_type.dart';

class User {
  final String id;
  final String email;
  final String? username;
  final String? displayName;
  final String? bio;
  final String? pronouns;
  final String? avatar;
  final UserRole role;
  final MembershipType membershipType;
  final DateTime createdAt;
  final bool isActive;
  
  const User({
    required this.id,
    required this.email,
    this.username,
    this.displayName,
    this.bio,
    this.pronouns,
    this.avatar,
    this.role = UserRole.user,
    this.membershipType = MembershipType.nonVoting,
    required this.createdAt,
    this.isActive = true,
  });

  /// Check if user can moderate content
  bool get canModerate => role.canModerate;

  /// Check if user is an admin
  bool get isAdmin => role.isAdmin;

  /// Check if user has any privileged access
  bool get isPrivileged => role.isPrivileged;

  /// Check if user can vote on governance
  bool get canVote => membershipType.canVote;

  /// Check if user is a full member
  bool get isFullMember => membershipType.isFullMember;
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      pronouns: json['pronouns'] as String?,
      avatar: json['avatar'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
      membershipType: MembershipType.fromString(json['membership_type'] as String? ?? 'non_voting'),
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
  
  factory User.fromPocketBase(RecordModel record) {
    return User(
      id: record.id,
      email: record.getStringValue('email'),
      username: record.getStringValue('username').isNotEmpty 
          ? record.getStringValue('username') 
          : null,
      displayName: record.getStringValue('displayName').isNotEmpty
          ? record.getStringValue('displayName')
          : null,
      bio: record.getStringValue('bio').isNotEmpty
          ? record.getStringValue('bio')
          : null,
      pronouns: record.getStringValue('pronouns').isNotEmpty
          ? record.getStringValue('pronouns')
          : null,
      avatar: record.getStringValue('avatar').isNotEmpty
          ? record.getStringValue('avatar')
          : null,
      role: UserRole.fromString(record.getStringValue('role')),
      membershipType: MembershipType.fromString(record.getStringValue('membership_type')),
      createdAt: DateTime.parse(record.created),
      isActive: true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'display_name': displayName,
      'bio': bio,
      'pronouns': pronouns,
      'avatar': avatar,
      'role': role.toApiString(),
      'membership_type': membershipType.toApiString(),
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}
