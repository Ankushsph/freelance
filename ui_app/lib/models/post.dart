import 'package:intl/intl.dart';

enum PostStatus {
  pending,
  scheduled,
  publishing,
  published,
  partiallyFailed,
  failed,
  cancelled,
}

class PlatformResult {
  final bool success;
  final String? postId;
  final String? url;
  final String? error;

  PlatformResult({
    required this.success,
    this.postId,
    this.url,
    this.error,
  });

  factory PlatformResult.fromJson(Map<String, dynamic> json) {
    return PlatformResult(
      success: json['success'] as bool,
      postId: json['postId'] as String?,
      url: json['url'] as String?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (postId != null) 'postId': postId,
      if (url != null) 'url': url,
      if (error != null) 'error': error,
    };
  }
}

class Post {
  final String id;
  final String userId;
  final String content;
  final List<String> tags;
  final List<String> mediaUrls;
  final List<String> platforms;
  final DateTime? scheduledTime;
  final PostStatus status;
  final Map<String, PlatformResult>? results;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.tags,
    required this.mediaUrls,
    required this.platforms,
    this.scheduledTime,
    required this.status,
    this.results,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    DateTime? parsedScheduledTime;
    if (json['scheduledTime'] != null) {
      final parsed = DateTime.parse(json['scheduledTime'] as String);
      parsedScheduledTime = parsed.toLocal();
    }

    DateTime? parsedPublishedAt;
    if (json['publishedAt'] != null) {
      final parsed = DateTime.parse(json['publishedAt'] as String);
      parsedPublishedAt = parsed.toLocal();
    }

    return Post(
      id: json['_id'] as String? ?? json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      mediaUrls: (json['mediaUrls'] as List<dynamic>).map((e) => e as String).toList(),
      platforms: (json['platforms'] as List<dynamic>).map((e) => e as String).toList(),
      scheduledTime: parsedScheduledTime,
      status: _parseStatus(json['status'] as String),
      results: json['results'] != null
          ? (json['results'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, PlatformResult.fromJson(value as Map<String, dynamic>)),
            )
          : null,
      publishedAt: parsedPublishedAt,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'content': content,
      'tags': tags,
      'mediaUrls': mediaUrls,
      'platforms': platforms,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'status': _statusToString(status),
      'results': results?.map((key, value) => MapEntry(key, value.toJson())),
      'publishedAt': publishedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static PostStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return PostStatus.pending;
      case 'scheduled':
        return PostStatus.scheduled;
      case 'publishing':
        return PostStatus.publishing;
      case 'published':
        return PostStatus.published;
      case 'partially_failed':
        return PostStatus.partiallyFailed;
      case 'failed':
        return PostStatus.failed;
      case 'cancelled':
        return PostStatus.cancelled;
      default:
        return PostStatus.pending;
    }
  }

  static String _statusToString(PostStatus status) {
    switch (status) {
      case PostStatus.pending:
        return 'pending';
      case PostStatus.scheduled:
        return 'scheduled';
      case PostStatus.publishing:
        return 'publishing';
      case PostStatus.published:
        return 'published';
      case PostStatus.partiallyFailed:
        return 'partially_failed';
      case PostStatus.failed:
        return 'failed';
      case PostStatus.cancelled:
        return 'cancelled';
    }
  }

  String get statusDisplay {
    switch (status) {
      case PostStatus.pending:
        return 'Pending';
      case PostStatus.scheduled:
        return 'Scheduled';
      case PostStatus.publishing:
        return 'Publishing';
      case PostStatus.published:
        return 'Published';
      case PostStatus.partiallyFailed:
        return 'Partially Failed';
      case PostStatus.failed:
        return 'Failed';
      case PostStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get scheduledTimeDisplay {
    if (scheduledTime == null) return 'Now';
    return DateFormat('MMM d, y HH:mm').format(scheduledTime!);
  }

  String get scheduledTimeShort {
    if (scheduledTime == null) return 'Now';
    return DateFormat('HH:mm').format(scheduledTime!);
  }

  bool get isScheduled => status == PostStatus.scheduled;
  bool get isPublished => status == PostStatus.published;
  bool get isFailed => status == PostStatus.failed || status == PostStatus.partiallyFailed;

  DateTime get dateKey {
    final date = scheduledTime ?? createdAt;
    return DateTime(date.year, date.month, date.day);
  }
}