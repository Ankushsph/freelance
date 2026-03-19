import 'package:flutter_test/flutter_test.dart';
import 'package:konnect/models/trending_post.dart';

void main() {
  group('TrendingPost Model Tests', () {
    test('should create TrendingPost from JSON correctly', () {
      final json = {
        '_id': '123',
        'postId': 'post456',
        'userId': {
          '_id': 'user789',
          'name': 'Test User',
          'username': 'testuser',
        },
        'content': 'Test post content',
        'mediaUrls': ['https://example.com/image.jpg'],
        'platforms': ['instagram', 'facebook'],
        'publishedAt': '2024-02-17T10:00:00.000Z',
        'likes': 100,
        'comments': 20,
        'shares': 10,
        'views': 5000,
        'platformEngagement': {
          'instagram': {
            'likes': 50,
            'comments': 10,
            'views': 2000,
          },
          'facebook': {
            'likes': 50,
            'comments': 10,
            'shares': 10,
            'views': 3000,
          },
        },
        'trendingScore': 15.5,
        'rank': 1,
        'previousRank': 3,
        'createdAt': '2024-02-17T10:00:00.000Z',
        'updatedAt': '2024-02-17T10:00:00.000Z',
      };

      final post = TrendingPost.fromJson(json);

      expect(post.id, '123');
      expect(post.postId, 'post456');
      expect(post.content, 'Test post content');
      expect(post.likes, 100);
      expect(post.comments, 20);
      expect(post.shares, 10);
      expect(post.views, 5000);
      expect(post.trendingScore, 15.5);
      expect(post.rank, 1);
      expect(post.platforms.length, 2);
    });

    test('should format engagement numbers correctly', () {
      // Test via creating a post with specific values
      final json = {
        '_id': '123',
        'postId': 'post456',
        'content': 'Test',
        'mediaUrls': [],
        'platforms': ['instagram'],
        'publishedAt': '2024-02-17T10:00:00.000Z',
        'likes': 1500,
        'comments': 2000,
        'shares': 3000000,
        'views': 500,
        'platformEngagement': {},
        'trendingScore': 0.0,
        'rank': 0,
        'previousRank': 0,
        'createdAt': '2024-02-17T10:00:00.000Z',
        'updatedAt': '2024-02-17T10:00:00.000Z',
      };
      
      final post = TrendingPost.fromJson(json);
      
      expect(post.formattedLikes, '1.5K');
      expect(post.formattedComments, '2.0K');
      expect(post.formattedShares, '3.0M');
      expect(post.formattedViews, '500');
    });

    test('should check platform correctly', () {
      final json = {
        '_id': '123',
        'postId': 'post456',
        'content': 'Test',
        'mediaUrls': [],
        'platforms': ['instagram', 'facebook'],
        'publishedAt': '2024-02-17T10:00:00.000Z',
        'likes': 0,
        'comments': 0,
        'shares': 0,
        'views': 0,
        'platformEngagement': {},
        'trendingScore': 0.0,
        'rank': 0,
        'previousRank': 0,
        'createdAt': '2024-02-17T10:00:00.000Z',
        'updatedAt': '2024-02-17T10:00:00.000Z',
      };

      final post = TrendingPost.fromJson(json);

      expect(post.hasPlatform('instagram'), true);
      expect(post.hasPlatform('facebook'), true);
      expect(post.hasPlatform('twitter'), false);
    });
  });

  group('TrendingStats Model Tests', () {
    test('should create TrendingStats from JSON correctly', () {
      final json = {
        'totalPosts': 100,
        'totalEngagement': {
          'likes': 5000,
          'comments': 1000,
          'shares': 500,
          'views': 100000,
        },
        'topPlatforms': [
          {'platform': 'instagram', 'count': 60},
          {'platform': 'facebook', 'count': 40},
        ],
      };

      final stats = TrendingStats.fromJson(json);

      expect(stats.totalPosts, 100);
      expect(stats.totalEngagement['likes'], 5000);
      expect(stats.totalEngagement['comments'], 1000);
      expect(stats.topPlatforms.length, 2);
    });
  });
}
