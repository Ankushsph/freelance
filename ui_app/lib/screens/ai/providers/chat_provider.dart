import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:konnect/services/auth_storage.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../services/chat_storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatStorageService _storage = ChatStorageService();


  List<Conversation> _conversations = [];
  Conversation? _currentConversation;
  List<ChatMessage> _currentMessages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  String? _syncError;


  List<Conversation> get conversations => _conversations;
  Conversation? get currentConversation => _currentConversation;
  List<ChatMessage> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  String? get syncError => _syncError;


  static final String _aiUrl = dotenv.env['AI_URL'] ?? 'http://localhost:3000/api/ai/chat';

  ChatProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _storage.initialize();
    await loadConversations();
  }


  Future<void> loadConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _storage.getAllConversations();
    } catch (e) {
      _error = 'Failed to load conversations: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<Conversation> createConversation({String? title}) async {
    try {
      final conversation = await _storage.createConversation(title: title);
      _conversations.insert(0, conversation);
      notifyListeners();
      return conversation;
    } catch (e) {
      _error = 'Failed to create conversation: $e';
      notifyListeners();
      rethrow;
    }
  }


  Future<void> loadConversation(String conversationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentConversation = await _storage.getConversation(conversationId);
      if (_currentConversation != null) {
        _currentMessages = await _storage.getMessagesForConversation(conversationId);
      }
    } catch (e) {
      _error = 'Failed to load conversation: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> switchConversation(String conversationId) async {
    await loadConversation(conversationId);
  }


  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isSending) return;


    if (_currentConversation == null) {
      final conversation = await createConversation();
      await loadConversation(conversation.id);
    }

    final localConversationId = _currentConversation!.id;
    final backendConversationId = _currentConversation!.backendId;


    final userMessage = await _storage.addMessage(
      conversationId: localConversationId,
      content: content,
      role: MessageRole.user,
      status: MessageStatus.sending,
    );

    _currentMessages.add(userMessage);
    _conversations.removeWhere((c) => c.id == localConversationId);
    _conversations.insert(0, _currentConversation!);
    _isSending = true;
    notifyListeners();

    try {


      final token = await AuthStorage.getToken();
      final response = await http.post(
        Uri.parse(_aiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'prompt': content,
          'conversationId': backendConversationId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiReply = data['reply'] ?? 'No response';
        final backendConversationId = data['conversationId'] as String?;
        final generatedTitle = data['title'] as String?;


        if (backendConversationId != null && _currentConversation != null) {
          _currentConversation!.backendId = backendConversationId;
        }


        if (generatedTitle != null && generatedTitle.isNotEmpty && _currentConversation != null) {
          _currentConversation!.title = generatedTitle;
        }


        await _storage.updateMessageStatus(userMessage.id, MessageStatus.sent);
        await _storage.markMessageAsSynced(userMessage.id);
        userMessage.status = MessageStatus.sent;


        final assistantMessage = await _storage.addMessage(
          conversationId: localConversationId,
          content: aiReply,
          role: MessageRole.assistant,
          status: MessageStatus.sent,
        );
        await _storage.markMessageAsSynced(assistantMessage.id);
        assistantMessage.isSynced = true;

        _currentMessages.add(assistantMessage);


        await _storage.updateConversation(_currentConversation!);
        _currentConversation!.isSynced = true;
        _currentConversation!.messageCount = _currentMessages.length;
      } else {

        final errorMsg = 'Failed to get response: ${response.statusCode}';
        await _storage.updateMessageStatus(
          userMessage.id,
          MessageStatus.error,
          errorMessage: errorMsg,
        );
        userMessage.status = MessageStatus.error;
        userMessage.errorMessage = errorMsg;
        _error = errorMsg;
      }
    } catch (e) {

      final errorMsg = 'Network error: $e';
      await _storage.updateMessageStatus(
        userMessage.id,
        MessageStatus.error,
        errorMessage: errorMsg,
      );
      userMessage.status = MessageStatus.error;
      userMessage.errorMessage = errorMsg;
      _error = errorMsg;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }


  Future<void> retryMessage(String messageId) async {
    final message = _currentMessages.firstWhere((m) => m.id == messageId);
    if (message.role != MessageRole.user) return;

    await _storage.updateMessageStatus(messageId, MessageStatus.sending);
    message.status = MessageStatus.sending;
    notifyListeners();

    await sendMessage(message.content);
  }


  Future<void> deleteConversation(String conversationId) async {
    try {
      await _storage.deleteConversation(conversationId);
      _conversations.removeWhere((c) => c.id == conversationId);

      if (_currentConversation?.id == conversationId) {
        _currentConversation = null;
        _currentMessages = [];
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete conversation: $e';
      notifyListeners();
    }
  }


  Future<void> updateConversationTitle(String conversationId, String title) async {
    try {
      await _storage.updateConversationTitle(conversationId, title);

      if (_currentConversation?.id == conversationId) {
        _currentConversation!.title = title;
      }

      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        _conversations[index].title = title;
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to update title: $e';
      notifyListeners();
    }
  }


  Future<void> startNewChat() async {
    _currentConversation = null;
    _currentMessages = [];
    _error = null;
    notifyListeners();
  }


  Future<void> syncWithBackend() async {
    try {
      _syncError = null;
      notifyListeners();


      final unsyncedConversations = await _storage.getUnsyncedConversations();
      final unsyncedMessages = await _storage.getUnsyncedMessages();


      for (final conversation in unsyncedConversations) {
        await _storage.markConversationAsSynced(conversation.id);
      }

      for (final message in unsyncedMessages) {
        await _storage.markMessageAsSynced(message.id);
      }

      notifyListeners();
    } catch (e) {
      _syncError = 'Sync failed: $e';
      notifyListeners();
    }
  }


  void clearError() {
    _error = null;
    notifyListeners();
  }


  Future<Map<String, int>> getStats() async {
    return await _storage.getStats();
  }
}