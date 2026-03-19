import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/chat_message.dart';
import 'providers/chat_provider.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/input_bar.dart';
import 'widgets/empty_state.dart';
import 'screens/conversation_list_screen.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void didUpdateWidget(AIChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSend(String text) async {
    await context.read<ChatProvider>().sendMessage(text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _handleRetry(String messageId) {
    context.read<ChatProvider>().retryMessage(messageId);
  }

  void _showConversationList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConversationListScreen()),
    );
  }

  void _startNewChat() async {
    await context.read<ChatProvider>().startNewChat();
    if (mounted) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
      ),
      titleSpacing: 0,
      title: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final conversation = chatProvider.currentConversation;
          return Row(
            children: [
              Image.asset(
                'assets/images/ai/bot.png',
                height: 36,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      conversation?.title ?? "AI Assistant",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.green),
                        SizedBox(width: 6),
                        Text(
                          "Online",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) {
            switch (value) {
              case 'new':
                _startNewChat();
                break;
              case 'history':
                _showConversationList();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'new',
              child: Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('New Chat'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history),
                  SizedBox(width: 8),
                  Text('View History'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Drawer(
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                decoration: BoxDecoration(
                  color: const Color(0xff6A5AE0).withOpacity(0.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/ai/bot.png',
                          height: 40,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'AI Assistant',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff6A5AE0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _startNewChat();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('New Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff6A5AE0),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  ],
                ),
              ),
              

              Expanded(
                child: chatProvider.conversations.isEmpty
                    ? const Center(
                        child: Text(
                          'No recent conversations',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: chatProvider.conversations.length > 10
                            ? 10
                            : chatProvider.conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = chatProvider.conversations[index];
                          final isSelected = chatProvider.currentConversation?.id == conversation.id;
                          
                          return ListTile(
                            leading: Icon(
                              Icons.chat_bubble_outline,
                              color: isSelected 
                                  ? const Color(0xff6A5AE0) 
                                  : Colors.grey[600],
                              size: 20,
                            ),
                            title: Text(
                              conversation.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected ? const Color(0xff6A5AE0) : Colors.black87,
                              ),
                            ),
                            selected: isSelected,
                            onTap: () {
                              Navigator.pop(context);
                              chatProvider.switchConversation(conversation.id);
                            },
                          );
                        },
                      ),
              ),
              

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showConversationList();
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('View All Conversations'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messages = chatProvider.currentMessages;
        final isLoading = chatProvider.isLoading;

        return Column(
          children: [

            if (chatProvider.error != null)
              Container(
                width: double.infinity,
                color: Colors.red.shade100,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatProvider.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red.shade700),
                      onPressed: chatProvider.clearError,
                    ),
                  ],
                ),
              ),
            

            Expanded(
              child: messages.isEmpty && !isLoading
                  ? EmptyState(
                      onSuggestionTap: (suggestion) {
                        _handleSend(suggestion);
                      },
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return ChatBubble(
                          message: message,
                          onRetry: message.status == MessageStatus.error
                              ? () => _handleRetry(message.id)
                              : null,
                        );
                      },
                    ),
            ),
            

            if (chatProvider.isSending)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.blue,
                      backgroundImage: const AssetImage('assets/images/ai/bot_icon.png'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI is typing...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            

            InputBar(
              onSend: _handleSend,
              isLoading: chatProvider.isSending,
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}