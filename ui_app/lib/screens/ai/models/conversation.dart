import 'package:hive/hive.dart';
import 'chat_message.dart';

part 'conversation.g.dart';

@HiveType(typeId: 4)
class Conversation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  final List<ChatMessage> messages;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  int messageCount;

  @HiveField(6)
  bool isArchived;

  @HiveField(7)
  bool isSynced;

  @HiveField(8)
  DateTime lastMessageAt;

  @HiveField(9)
  String? backendId;

  Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
    this.isArchived = false,
    this.isSynced = false,
    DateTime? lastMessageAt,
    this.backendId,
  }) : lastMessageAt = lastMessageAt ?? updatedAt;

  Conversation copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
    bool? isArchived,
    bool? isSynced,
    DateTime? lastMessageAt,
    String? backendId,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
      isArchived: isArchived ?? this.isArchived,
      isSynced: isSynced ?? this.isSynced,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      backendId: backendId ?? this.backendId,
    );
  }

  void addMessage(ChatMessage message) {
    messages.add(message);
    messageCount = messages.length;
    updatedAt = DateTime.now();
    lastMessageAt = DateTime.now();
  }

  void removeMessage(String messageId) {
    messages.removeWhere((m) => m.id == messageId);
    messageCount = messages.length;
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messageCount': messageCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? json['_id'],
      title: json['title'] ?? 'New Chat',
      messages: [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      messageCount: json['messageCount'] ?? 0,
      isArchived: json['isArchived'] ?? false,
      isSynced: true,
      lastMessageAt: DateTime.parse(json['lastMessageAt'] ?? json['updatedAt']),
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      lastMessageAt.year,
      lastMessageAt.month,
      lastMessageAt.day,
    );

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(lastMessageAt).inDays < 7) {
      return _getWeekdayName(lastMessageAt.weekday);
    } else {
      return '${lastMessageAt.day}/${lastMessageAt.month}/${lastMessageAt.year}';
    }
  }

  String _getWeekdayName(int weekday) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[weekday - 1];
  }
}