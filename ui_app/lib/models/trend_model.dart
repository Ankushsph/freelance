class Creator {
  final String name;
  final String handle;
  final String avatar;

  Creator({
    required this.name,
    required this.handle,
    required this.avatar,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      name: json['name'] ?? '',
      handle: json['handle'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}

class Engagement {
  final int likes;
  final int comments;
  final int shares;
  final int views;

  Engagement({
    required this.likes,
    required this.comments,
    required this.shares,
    required this.views,
  });

  factory Engagement.fromJson(Map<String, dynamic> json) {
    return Engagement(
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      views: json['views'] ?? 0,
    );
  }
}

class Content {
  final String url;
  final String thumbnail;
  final int? duration;

  Content({
    required this.url,
    required this.thumbnail,
    this.duration,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      duration: json['duration'],
    );
  }
}

class Trend {
  final String id;
  final String platform;
  final String category;
  final String contentType;
  final String title;
  final String? description;
  final Creator creator;
  final Content content;
  final Engagement engagement;
  final double trendScore;
  final List<String> tags;
  final DateTime createdAt;

  Trend({
    required this.id,
    required this.platform,
    required this.category,
    required this.contentType,
    required this.title,
    this.description,
    required this.creator,
    required this.content,
    required this.engagement,
    required this.trendScore,
    required this.tags,
    required this.createdAt,
  });

  factory Trend.fromJson(Map<String, dynamic> json) {
    return Trend(
      id: json['_id'] ?? '',
      platform: json['platform'] ?? '',
      category: json['category'] ?? '',
      contentType: json['contentType'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      creator: Creator.fromJson(json['creator'] ?? {}),
      content: Content.fromJson(json['content'] ?? {}),
      engagement: Engagement.fromJson(json['engagement'] ?? {}),
      trendScore: (json['trendScore'] ?? 0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class SavedTrend {
  final String id;
  final String userId;
  final String trendId;
  final String platform;
  final String category;
  final DateTime savedAt;

  SavedTrend({
    required this.id,
    required this.userId,
    required this.trendId,
    required this.platform,
    required this.category,
    required this.savedAt,
  });

  factory SavedTrend.fromJson(Map<String, dynamic> json) {
    return SavedTrend(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      trendId: json['trendId'] ?? '',
      platform: json['platform'] ?? '',
      category: json['category'] ?? '',
      savedAt: DateTime.parse(json['savedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
