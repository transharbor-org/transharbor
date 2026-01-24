import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_role.dart';
import '../../../core/models/membership_type.dart';
import '../../../core/services/pocketbase_service.dart';
import '../../auth/providers/auth_provider.dart';

/// Screen for admins to manage user roles and membership
class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  final PocketBaseService _pb = PocketBaseService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    // Check if user is admin
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAdmin) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin access required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final records = await _pb.pb.collection('users').getFullList(
            sort: '-created',
            expand: '',
          );

      setState(() {
        _users = records.map((record) {
          return {
            'id': record.id,
            'username': record.getStringValue('username'),
            'email': record.getStringValue('email'),
            'role': record.getStringValue('role'),
            'membershipType': record.getStringValue('membershipType'),
            'created': record.created,
          };
        }).toList();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      await _pb.pb.collection('users').update(userId, body: {
        'role': newRole,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User role updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update role: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateUserMembership(
      String userId, String newMembershipType) async {
    try {
      await _pb.pb.collection('users').update(userId, body: {
        'membershipType': newMembershipType,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Membership type updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update membership: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showRoleDialog(Map<String, dynamic> user) async {
    final currentRole = user['role'] as String;
    final selectedRole = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Role for ${user['username']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            return RadioListTile<String>(
              title: Text(_getRoleLabel(role)),
              subtitle: Text(_getRoleDescription(role)),
              value: role.name,
              groupValue: currentRole,
              onChanged: (value) {
                Navigator.of(context).pop(value);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedRole != null && selectedRole != currentRole) {
      await _updateUserRole(user['id'] as String, selectedRole);
    }
  }

  Future<void> _showMembershipDialog(Map<String, dynamic> user) async {
    final currentMembership = user['membershipType'] as String;
    final selectedMembership = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Membership for ${user['username']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: MembershipType.values.map((type) {
            return RadioListTile<String>(
              title: Text(_getMembershipLabel(type)),
              subtitle: Text(_getMembershipDescription(type)),
              value: type.value,
              groupValue: currentMembership,
              onChanged: (value) {
                Navigator.of(context).pop(value);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedMembership != null && selectedMembership != currentMembership) {
      await _updateUserMembership(user['id'] as String, selectedMembership);
    }
  }

  String _getRoleLabel(UserRole role) {
    return switch (role) {
      UserRole.admin => 'Admin',
      UserRole.moderator => 'Moderator',
      UserRole.user => 'User',
    };
  }

  String _getRoleDescription(UserRole role) {
    return switch (role) {
      UserRole.admin => 'Full system access and user management',
      UserRole.moderator => 'Can review and manage reports',
      UserRole.user => 'Standard user privileges',
    };
  }

  String _getMembershipLabel(MembershipType type) {
    return switch (type) {
      MembershipType.votingMember => 'Voting Member',
      MembershipType.nonVoting => 'Non-Voting Member',
    };
  }

  String _getMembershipDescription(MembershipType type) {
    return switch (type) {
      MembershipType.votingMember => 'Can participate in governance and vote',
      MembershipType.nonVoting => 'Cannot vote on governance matters',
    };
  }

  Color _getRoleColor(String role) {
    return switch (role) {
      'admin' => Colors.red,
      'moderator' => Colors.orange,
      _ => Colors.blue,
    };
  }

  IconData _getRoleIcon(String role) {
    return switch (role) {
      'admin' => Icons.admin_panel_settings,
      'moderator' => Icons.shield,
      _ => Icons.person,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error loading users',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_error!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Text('No users found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final role = user['role'] as String;
          final membershipType = user['membershipType'] as String;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getRoleColor(role),
                child: Icon(_getRoleIcon(role), color: Colors.white),
              ),
              title: Text(user['username'] as String),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email'] as String),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          _getRoleLabel(UserRole.fromString(role)),
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: _getRoleColor(role).withOpacity(0.2),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        avatar: Icon(
                          membershipType == 'voting_member'
                              ? Icons.how_to_vote
                              : Icons.visibility,
                          size: 16,
                        ),
                        label: Text(
                          _getMembershipLabel(
                              MembershipType.fromString(membershipType)),
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: membershipType == 'voting_member'
                            ? Colors.green.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'role') {
                    _showRoleDialog(user);
                  } else if (value == 'membership') {
                    _showMembershipDialog(user);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'role',
                    child: Row(
                      children: [
                        Icon(Icons.shield),
                        SizedBox(width: 8),
                        Text('Change Role'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'membership',
                    child: Row(
                      children: [
                        Icon(Icons.how_to_vote),
                        SizedBox(width: 8),
                        Text('Change Membership'),
                      ],
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
