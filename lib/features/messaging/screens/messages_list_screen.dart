import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/messaging_provider.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({super.key});

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagingProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Consumer<MessagingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading conversations',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadConversations(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 80,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Start a conversation!'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadConversations(),
            child: ListView.builder(
              itemCount: provider.conversations.length,
              itemBuilder: (context, index) {
                final conversation = provider.conversations[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                      'Conversation ${conversation.id.length > 8 ? conversation.id.substring(0, 8) : conversation.id}'),
                  subtitle: conversation.lastMessage != null
                      ? Text(
                          conversation.lastMessage!.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const Text('No messages'),
                  trailing: conversation.unreadCount > 0
                      ? CircleAvatar(
                          radius: 12,
                          child: Text(
                            '${conversation.unreadCount}',
                            style: const TextStyle(fontSize: 10),
                          ),
                        )
                      : null,
                  onTap: () => context.push('/messages/${conversation.id}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
