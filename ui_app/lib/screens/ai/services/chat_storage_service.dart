import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';

class ChatStorageService {
  static const String _conversationsBoxName = 'conversations';
  static const String _messagesBoxName = 'messages';
  static const int _maxConversations = 50;

  late Box<Conversation> _conversationsBox;
  late Box<ChatMessage> _messagesBox;
  final Uuid _uuid = const Uuid();

  bool _isInitialized = false;


  static final ChatStorageService _instance = ChatStorageService._internal();
  factory ChatStorageService() => _instance;
  ChatStorageService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();


    Hive.registerAdapter(ChatMessageAdapter());
    Hive.registerAdapter(ConversationAdapter());
    Hive.registerAdapter(MessageStatusAdapter());
    Hive.registerAdapter(MessageRoleAdapter());


    _conversationsBox = await Hive.openBox<Conversation>(_conversationsBoxName);
    _messagesBox = await Hive.openBox<ChatMessage>(_messagesBoxName);

    _isInitialized = true;
  }


  Future<List<Conversation>> getAllConversations() async {
    if (!_isInitialized) await initialize();

    final conversations = _conversationsBox.values.toList()
      ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

    return conversations.where((c) => !c.isArchived).toList();
  }

  Future<Conversation?> getConversation(String id) async {
    if (!_isInitialized) await initialize();
    return _conversationsBox.get(id);
  }

  Future<Conversation> createConversation({String? title}) async {
    if (!_isInitialized) await initialize();

    final id = _uuid.v4();
    final now = DateTime.now();

    final conversation = Conversation(
      id: id,
      title: title ?? 'New Chat',
      messages: [],
      createdAt: now,
      updatedAt: now,
      lastMessageAt: now,
      isSynced: false,
    );

    await _conversationsBox.put(id, conversation);
    await _cleanupOldConversations();

    return conversation;
  }

  Future<void> updateConversation(Conversation conversation) async {
    if (!_isInitialized) await initialize();

    conversation.updatedAt = DateTime.now();
    await _conversationsBox.put(conversation.id, conversation);
  }

  Future<void> updateConversationTitle(String conversationId, String title) async {
    if (!_isInitialized) await initialize();

    final conversation = _conversationsBox.get(conversationId);
    if (conversation != null) {
      conversation.title = title;
      conversation.updatedAt = DateTime.now();
      await conversation.save();
    }
  }

  Future<void> deleteConversation(String id) async {
    if (!_isInitialized) await initialize();


    final messagesToDelete = _messagesBox.values
        .where((m) => m.conversationId == id)
        .map((m) => m.key)
        .toList();

    await _messagesBox.deleteAll(messagesToDelete);
    await _conversationsBox.delete(id);
  }

  Future<void> archiveConversation(String id) async {
    if (!_isInitialized) await initialize();

    final conversation = _conversationsBox.get(id);
    if (conversation != null) {
      conversation.isArchived = true;
      await conversation.save();
    }
  }


  Future<ChatMessage> addMessage({
    required String conversationId,
    required String content,
    required MessageRole role,
    MessageStatus status = MessageStatus.sending,
  }) async {
    if (!_isInitialized) await initialize();

    final id = _uuid.v4();
    final now = DateTime.now();

    final message = ChatMessage(
      id: id,
      content: content,
      role: role,
      timestamp: now,
      conversationId: conversationId,
      status: status,
      isSynced: false,
    );

    await _messagesBox.put(id, message);


    final conversation = _conversationsBox.get(conversationId);
    if (conversation != null) {
      conversation.addMessage(message);
      await conversation.save();
    }

    return message;
  }

  Future<List<ChatMessage>> getMessagesForConversation(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    if (!_isInitialized) await initialize();

    final messages = _messagesBox.values
        .where((m) => m.conversationId == conversationId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (offset >= messages.length) return [];

    final endIndex = (offset + limit).clamp(0, messages.length);
    return messages.sublist(offset, endIndex);
  }

  Future<void> updateMessageStatus(
    String messageId,
    MessageStatus status, {
    String? errorMessage,
  }) async {
    if (!_isInitialized) await initialize();

    final message = _messagesBox.get(messageId);
    if (message != null) {
      message.status = status;
      if (errorMessage != null) {
        message.errorMessage = errorMessage;
      }
      await message.save();
    }
  }

  Future<void> markMessageAsSynced(String messageId) async {
    if (!_isInitialized) await initialize();

    final message = _messagesBox.get(messageId);
    if (message != null) {
      message.isSynced = true;
      await message.save();
    }
  }

  Future<void> markConversationAsSynced(String conversationId) async {
    if (!_isInitialized) await initialize();

    final conversation = _conversationsBox.get(conversationId);
    if (conversation != null) {
      conversation.isSynced = true;
      await conversation.save();
    }
  }

  Future<void> deleteMessage(String messageId) async {
    if (!_isInitialized) await initialize();
    await _messagesBox.delete(messageId);
  }


  Future<List<Conversation>> getUnsyncedConversations() async {
    if (!_isInitialized) await initialize();
    return _conversationsBox.values.where((c) => !c.isSynced).toList();
  }

  Future<List<ChatMessage>> getUnsyncedMessages() async {
    if (!_isInitialized) await initialize();
    return _messagesBox.values.where((m) => !m.isSynced).toList();
  }


  Future<void> _cleanupOldConversations() async {
    if (_conversationsBox.length <= _maxConversations) return;

    final conversations = _conversationsBox.values.toList()
      ..sort((a, b) => a.lastMessageAt.compareTo(b.lastMessageAt));

    final toDelete = conversations.take(conversations.length - _maxConversations);

    for (final conversation in toDelete) {
      await deleteConversation(conversation.id);
    }
  }

  Future<void> clearAllData() async {
    if (!_isInitialized) await initialize();

    await _messagesBox.clear();
    await _conversationsBox.clear();
  }


  Future<Map<String, int>> getStats() async {
    if (!_isInitialized) await initialize();

    return {
      'conversations': _conversationsBox.length,
      'messages': _messagesBox.length,
      'unsyncedConversations': _conversationsBox.values.where((c) => !c.isSynced).length,
      'unsyncedMessages': _messagesBox.values.where((m) => !m.isSynced).length,
    };
  }


  Future<void> close() async {
    await _conversationsBox.close();
    await _messagesBox.close();
    _isInitialized = false;
  }
}