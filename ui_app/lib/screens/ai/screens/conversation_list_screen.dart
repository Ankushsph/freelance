import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/conversation.dart';
import '../providers/chat_provider.dart';
import '../ai_chat_screen.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Conversations',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {

          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isLoading && chatProvider.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatProvider.error != null) {
          return _buildErrorWidget(chatProvider.error!);
        }

        if (chatProvider.conversations.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => chatProvider.loadConversations(),
          child: _buildConversationList(chatProvider.conversations),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<ChatProvider>().loadConversations();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ai/bot.png',
              height: 120,
            ),
            const SizedBox(height: 24),
            Text(
              'No conversations yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new chat to get help with your social media content!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _startNewChat(),
              icon: const Icon(Icons.add),
              label: const Text('Start New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff6A5AE0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationList(List<Conversation> conversations) {

    final groupedConversations = _groupConversationsByDate(conversations);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: groupedConversations.length,
      itemBuilder: (context, index) {
        final group = groupedConversations[index];
        return _buildConversationGroup(group);
      },
    );
  }

  Widget _buildConversationGroup(_ConversationGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            group.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        ...group.conversations.map((conversation) => _buildConversationTile(conversation)),
      ],
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<ChatProvider>().deleteConversation(conversation.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversation deleted')),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xff6A5AE0).withOpacity(0.1),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: Color(0xff6A5AE0),
            size: 20,
          ),
        ),
        title: Text(
          conversation.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '${conversation.messageCount} messages',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          _formatTime(conversation.lastMessageAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        onTap: () => _openConversation(conversation),
        onLongPress: () => _showConversationOptions(conversation),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _startNewChat(),
      backgroundColor: const Color(0xff6A5AE0),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'New Chat',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _startNewChat() async {
    await context.read<ChatProvider>().startNewChat();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AIChatScreen()),
      );
    }
  }

  void _openConversation(Conversation conversation) async {
    await context.read<ChatProvider>().loadConversation(conversation.id);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AIChatScreen()),
      );
    }
  }

  void _showConversationOptions(Conversation conversation) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(conversation);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatProvider>().deleteConversation(conversation.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(Conversation conversation) {
    final controller = TextEditingController(text: conversation.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Conversation'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter new title',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context.read<ChatProvider>().updateConversationTitle(
                    conversation.id,
                    controller.text.trim(),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  List<_ConversationGroup> _groupConversationsByDate(List<Conversation> conversations) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));
    final lastMonth = today.subtract(const Duration(days: 30));

    final groups = <_ConversationGroup>[];
    final todayGroup = <Conversation>[];
    final yesterdayGroup = <Conversation>[];
    final lastWeekGroup = <Conversation>[];
    final lastMonthGroup = <Conversation>[];
    final olderGroup = <Conversation>[];

    for (final conversation in conversations) {
      final date = DateTime(
        conversation.lastMessageAt.year,
        conversation.lastMessageAt.month,
        conversation.lastMessageAt.day,
      );

      if (date == today) {
        todayGroup.add(conversation);
      } else if (date == yesterday) {
        yesterdayGroup.add(conversation);
      } else if (date.isAfter(lastWeek)) {
        lastWeekGroup.add(conversation);
      } else if (date.isAfter(lastMonth)) {
        lastMonthGroup.add(conversation);
      } else {
        olderGroup.add(conversation);
      }
    }

    if (todayGroup.isNotEmpty) {
      groups.add(_ConversationGroup('Today', todayGroup));
    }
    if (yesterdayGroup.isNotEmpty) {
      groups.add(_ConversationGroup('Yesterday', yesterdayGroup));
    }
    if (lastWeekGroup.isNotEmpty) {
      groups.add(_ConversationGroup('Previous 7 Days', lastWeekGroup));
    }
    if (lastMonthGroup.isNotEmpty) {
      groups.add(_ConversationGroup('Previous 30 Days', lastMonthGroup));
    }
    if (olderGroup.isNotEmpty) {
      groups.add(_ConversationGroup('Older', olderGroup));
    }

    return groups;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ConversationGroup {
  final String title;
  final List<Conversation> conversations;

  _ConversationGroup(this.title, this.conversations);
}