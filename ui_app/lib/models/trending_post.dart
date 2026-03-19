import 'package:intl/intl.dart';

class PlatformEngagement {
  final int likes;
  final int comments;
  final int? shares;
  final int? retweets;
  final int? views;

  PlatformEngagement({
    required this.likes,
    required this.comments,
    this.shares,
    this.retweets,
    this.views,
  });

  factory PlatformEngagement.fromJson(Map<dynamic, dynamic> json) {
    return PlatformEngagement(
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int?,
      retweets: json['retweets'] as int?,
      views: json['views'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likes': likes,
      'comments': comments,
      if (shares != null) 'shares': shares,
      if (retweets != null) 'retweets': retweets,
      if (views != null) 'views': views,
    };
  }

  int get totalEngagement => likes + comments + (shares ?? 0) + (retweets ?? 0);
}

class TrendingUser {
  final String id;
  final String? name;
  final String? username;
  final String? avatar;

  TrendingUser({
    required this.id,
    this.name,
    this.username,
    this.avatar,
  });

  factory TrendingUser.fromJson(Map<String, dynamic> json) {
    return TrendingUser(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String?,
      username: json['username'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  String get displayName => name ?? username ?? 'Unknown User';

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'username': username,
      'avatar': avatar,
    };
  }
}

class TrendingPost {
  final String id;
  final String postId;
  final TrendingUser? user;
  final String content;
  final List<String> mediaUrls;
  final List<String> platforms;
  final DateTime publishedAt;
  

  final int likes;
  final int comments;
  final int shares;
  final int views;
  

  final Map<String, PlatformEngagement> platformEngagement;
  

  final double trendingScore;
  final int rank;
  final int previousRank;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  TrendingPost({
    required this.id,
    required this.postId,
    this.user,
    required this.content,
    required this.mediaUrls,
    required this.platforms,
    required this.publishedAt,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.views,
    required this.platformEngagement,
    required this.trendingScore,
    required this.rank,
    required this.previousRank,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrendingPost.fromJson(Map<String, dynamic> json) {
    return TrendingPost(
      id: json['_id'] as String? ?? json['id'] as String,
      postId: json['postId'] as String? ?? json['_id'] as String,
      user: json['userId'] != null && json['userId'] is Map<String, dynamic>
          ? TrendingUser.fromJson(json['userId'] as Map<String, dynamic>)
          : null,
      content: json['content'] as String,
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      platforms: (json['platforms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      platformEngagement: json['platformEngagement'] != null
          ? Map<String, PlatformEngagement>.from(
              (json['platformEngagement'] as Map<dynamic, dynamic>).map(
                (key, value) => MapEntry(
                  key.toString(),
                  PlatformEngagement.fromJson(value as Map<dynamic, dynamic>),
                ),
              ),
            )
          : {},
      trendingScore: (json['trendingScore'] as num?)?.toDouble() ?? 0.0,
      rank: json['rank'] as int? ?? 0,
      previousRank: json['previousRank'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'postId': postId,
      'userId': user?.toJson(),
      'content': content,
      'mediaUrls': mediaUrls,
      'platforms': platforms,
      'publishedAt': publishedAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'views': views,
      'platformEngagement': platformEngagement
          .map((key, value) => MapEntry(key, value.toJson())),
      'trendingScore': trendingScore,
      'rank': rank,
      'previousRank': previousRank,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }


  int get totalEngagement => likes + comments + shares + views;
  
  int get rankChange => previousRank - rank;
  
  bool get isRising => rankChange > 0;
  bool get isFalling => rankChange < 0;
  bool get isStable => rankChange == 0;
  
  String get formattedPublishedAt {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(publishedAt);
    }
  }
  
  String get formattedEngagement {
    if (totalEngagement >= 1000000) {
      return '${(totalEngagement / 1000000).toStringAsFixed(1)}M';
    } else if (totalEngagement >= 1000) {
      return '${(totalEngagement / 1000).toStringAsFixed(1)}K';
    }
    return totalEngagement.toString();
  }
  
  String get formattedLikes => _formatNumber(likes);
  String get formattedComments => _formatNumber(comments);
  String get formattedShares => _formatNumber(shares);
  String get formattedViews => _formatNumber(views);
  
  static String _formatNumber(int num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toString();
  }


  PlatformEngagement? getEngagementForPlatform(String platform) {
    return platformEngagement[platform];
  }
  

  bool hasPlatform(String platform) {
    return platforms.contains(platform.toLowerCase());
  }
  

  String? get primaryPlatform {
    return platforms.isNotEmpty ? platforms.first : null;
  }
}

class TrendingStats {
  final int totalPosts;
  final Map<String, int> totalEngagement;
  final List<Map<String, dynamic>> topPlatforms;

  TrendingStats({
    required this.totalPosts,
    required this.totalEngagement,
    required this.topPlatforms,
  });

  factory TrendingStats.fromJson(Map<String, dynamic> json) {
    return TrendingStats(
      totalPosts: json['totalPosts'] as int? ?? 0,
      totalEngagement: {
        'likes': json['totalEngagement']?['likes'] as int? ?? 0,
        'comments': json['totalEngagement']?['comments'] as int? ?? 0,
        'shares': json['totalEngagement']?['shares'] as int? ?? 0,
        'views': json['totalEngagement']?['views'] as int? ?? 0,
      },
      topPlatforms: (json['topPlatforms'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}