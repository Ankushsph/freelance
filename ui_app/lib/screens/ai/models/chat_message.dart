import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 1)
enum MessageStatus {
  @HiveField(0)
  sending,
  @HiveField(1)
  sent,
  @HiveField(2)
  error,
}

@HiveType(typeId: 2)
enum MessageRole {
  @HiveField(0)
  user,
  @HiveField(1)
  assistant,
  @HiveField(2)
  system,
}

@HiveType(typeId: 3)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final MessageRole role;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  MessageStatus status;

  @HiveField(5)
  String? errorMessage;

  @HiveField(6)
  final String conversationId;

  @HiveField(7)
  bool isSynced;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    required this.conversationId,
    this.status = MessageStatus.sending,
    this.errorMessage,
    this.isSynced = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    MessageStatus? status,
    String? errorMessage,
    String? conversationId,
    bool? isSynced,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      conversationId: conversationId ?? this.conversationId,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
      'conversationId': conversationId,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? json['_id'],
      content: json['content'] ?? json['text'],
      role: MessageRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? json['createdAt']),
      conversationId: json['conversationId'] ?? '',
      status: MessageStatus.sent,
      isSynced: true,
    );
  }
}