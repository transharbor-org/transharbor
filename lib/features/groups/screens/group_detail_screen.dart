import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/groups_provider.dart';
import '../models/group.dart';
import '../../auth/providers/auth_provider.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  
  const GroupDetailScreen({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _postController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GroupsProvider>();
      provider.loadGroup(widget.groupId);
      provider.loadMyMembership(widget.groupId);
      provider.loadGroupPosts(widget.groupId);
      provider.loadGroupMembers(widget.groupId);
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    super.dispose();
  }
  
  Future<void> _handleJoinLeave(GroupsProvider provider, bool isMember) async {
    if (isMember) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Leave Group'),
          content: const Text('Are you sure you want to leave this group?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Leave'),
            ),
          ],
        ),
      );
      
      if (confirmed == true && mounted) {
        final success = await provider.leaveGroup(widget.groupId);
        if (success && mounted) {
          context.pop();
        }
      }
    } else {
      final success = await provider.joinGroup(widget.groupId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined group successfully!')),
        );
      }
    }
  }
  
  Future<void> _createPost(GroupsProvider provider) async {
    if (_postController.text.trim().isEmpty) return;
    
    final success = await provider.createGroupPost(
      widget.groupId,
      _postController.text.trim(),
    );
    
    if (success && mounted) {
      _postController.clear();
      FocusScope.of(context).unfocus();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<GroupsProvider>(
      builder: (context, provider, child) {
        final group = provider.groups.firstWhere(
          (g) => g.id == widget.groupId,
          orElse: () => provider.myGroups.firstWhere(
            (g) => g.id == widget.groupId,
            orElse: () => Group(
              id: widget.groupId,
              name: 'Loading...',
              description: '',
              creatorId: '',
              createdAt: DateTime.now(),
            ),
          ),
        );
        
        final isMember = provider.isMember(widget.groupId);
        final isAdmin = provider.isAdmin(widget.groupId);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(group.name),
            actions: [
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // Navigate to group settings
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              _buildGroupHeader(group, provider, isMember),
              if (isMember) ...[
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'Members'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPostsTab(provider),
                      _buildMembersTab(provider),
                    ],
                  ),
                ),
              ] else
                const Expanded(
                  child: Center(
                    child: Text('Join the group to see posts and members'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildGroupHeader(Group group, GroupsProvider provider, bool isMember) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.group,
                    size: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${group.memberCount} members',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (group.isPrivate) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.lock,
                              size: 16,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Private',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(group.description),
            if (group.category != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(group.category!.toUpperCase()),
                visualDensity: VisualDensity.compact,
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleJoinLeave(provider, isMember),
                icon: Icon(isMember ? Icons.logout : Icons.login),
                label: Text(isMember ? 'Leave Group' : 'Join Group'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMember 
                      ? Theme.of(context).colorScheme.error 
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPostsTab(GroupsProvider provider) {
    final posts = provider.getGroupPosts(widget.groupId);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _postController,
                  decoration: const InputDecoration(
                    hintText: 'Share something with the group...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _createPost(provider),
                icon: const Icon(Icons.send),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        Expanded(
          child: posts.isEmpty
              ? const Center(
                  child: Text('No posts yet. Be the first to post!'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final authProvider = context.read<AuthProvider>();
                    final isMyPost = post.userId == authProvider.currentUser?.id;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  child: Icon(Icons.person, size: 16),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Member',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _formatDate(post.createdAt),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isMyPost)
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => provider.deleteGroupPost(
                                      widget.groupId,
                                      post.id,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(post.content),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildMembersTab(GroupsProvider provider) {
    final members = provider.getGroupMembers(widget.groupId);
    
    if (members.isEmpty) {
      return const Center(
        child: Text('No members found'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text('Member ${member.userId.substring(0, 8)}'),
          subtitle: Text('Joined ${_formatDate(member.joinedAt)}'),
          trailing: Chip(
            label: Text(
              member.role.name.toUpperCase(),
              style: const TextStyle(fontSize: 10),
            ),
            visualDensity: VisualDensity.compact,
          ),
        );
      },
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
