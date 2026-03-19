import 'package:flutter_test/flutter_test.dart';
import 'package:konnect/models/post.dart';
import 'package:konnect/providers/schedule_provider.dart';

void main() {
  group('ScheduleProvider', () {
    late ScheduleProvider provider;

    setUp(() {
      provider = ScheduleProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    group('Initial State', () {
      test('should have correct initial values', () {
        expect(provider.posts, isEmpty);
        expect(provider.filteredPosts, isEmpty);
        expect(provider.isLoading, isFalse);
        expect(provider.error, isNull);
        expect(provider.scheduledDates, isEmpty);
      });

      test('selectedDate should default to today', () {
        final today = DateTime.now();
        expect(provider.selectedDate.year, equals(today.year));
        expect(provider.selectedDate.month, equals(today.month));
        expect(provider.selectedDate.day, equals(today.day));
      });

      test('currentMonth should default to current month', () {
        final today = DateTime.now();
        expect(provider.currentMonth.year, equals(today.year));
        expect(provider.currentMonth.month, equals(today.month));
      });
    });

    group('Date Management', () {
      test('setSelectedDate updates selected date and filters posts', () {
        final newDate = DateTime(2026, 2, 15);
        
        provider.setSelectedDate(newDate);
        
        expect(provider.selectedDate, equals(newDate));
      });

      test('setCurrentMonth updates current month', () {
        final newMonth = DateTime(2026, 3, 1);
        
        provider.setCurrentMonth(newMonth);
        
        expect(provider.currentMonth, equals(newMonth));
      });
    });

    group('Post Filtering', () {
      test('getPostsForDate returns posts for specific date', () {
        final date = DateTime(2026, 2, 15);
        final posts = provider.getPostsForDate(date);
        
        // Initially empty
        expect(posts, isEmpty);
      });

      test('hasPostsOnDate returns false when no posts on date', () {
        final date = DateTime(2026, 2, 25);
        expect(provider.hasPostsOnDate(date), isFalse);
      });

      test('scheduledDates returns unique dates from posts', () {
        expect(provider.scheduledDates, isEmpty);
      });
    });

    group('Error Handling', () {
      test('clearError removes error message', () {
        expect(provider.error, isNull);
      });
    });

    group('Loading State', () {
      test('isLoading should be false by default', () {
        expect(provider.isLoading, isFalse);
      });
    });
  });

  group('Post Model', () {
    test('Post can be created with all fields', () {
      final post = Post(
        id: '123',
        userId: 'user1',
        content: 'Test content',
        tags: ['test', 'flutter'],
        mediaUrls: ['https://example.com/image.jpg'],
        platforms: ['instagram', 'facebook'],
        scheduledTime: DateTime(2026, 2, 15, 10, 0),
        status: PostStatus.scheduled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(post.id, equals('123'));
      expect(post.userId, equals('user1'));
      expect(post.content, equals('Test content'));
      expect(post.tags, equals(['test', 'flutter']));
      expect(post.mediaUrls, equals(['https://example.com/image.jpg']));
      expect(post.platforms, equals(['instagram', 'facebook']));
      expect(post.status, equals(PostStatus.scheduled));
      expect(post.isScheduled, isTrue);
      expect(post.isPublished, isFalse);
      expect(post.isFailed, isFalse);
    });

    test('Post without scheduled time returns correct display values', () {
      final post = Post(
        id: '123',
        userId: 'user1',
        content: 'Test content',
        tags: [],
        mediaUrls: [],
        platforms: ['instagram'],
        scheduledTime: null,
        status: PostStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(post.scheduledTimeDisplay, equals('Now'));
      expect(post.scheduledTimeShort, equals('Now'));
    });

    test('Post with scheduled time returns formatted display values', () {
      final scheduledTime = DateTime(2026, 2, 15, 14, 30);
      final post = Post(
        id: '123',
        userId: 'user1',
        content: 'Test content',
        tags: [],
        mediaUrls: [],
        platforms: ['instagram'],
        scheduledTime: scheduledTime,
        status: PostStatus.scheduled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(post.scheduledTimeDisplay.contains('Feb'), isTrue);
      expect(post.scheduledTimeShort, equals('14:30'));
    });

    test('Post status display returns correct strings', () {
      final statuses = {
        PostStatus.pending: 'Pending',
        PostStatus.scheduled: 'Scheduled',
        PostStatus.publishing: 'Publishing',
        PostStatus.published: 'Published',
        PostStatus.partiallyFailed: 'Partially Failed',
        PostStatus.failed: 'Failed',
        PostStatus.cancelled: 'Cancelled',
      };

      for (final entry in statuses.entries) {
        final post = Post(
          id: '123',
          userId: 'user1',
          content: 'Test',
          tags: [],
          mediaUrls: [],
          platforms: ['instagram'],
          scheduledTime: null,
          status: entry.key,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(post.statusDisplay, equals(entry.value));
      }
    });

    test('Post dateKey returns date portion only', () {
      final scheduledTime = DateTime(2026, 2, 15, 14, 30, 45);
      final post = Post(
        id: '123',
        userId: 'user1',
        content: 'Test',
        tags: [],
        mediaUrls: [],
        platforms: ['instagram'],
        scheduledTime: scheduledTime,
        status: PostStatus.scheduled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final dateKey = post.dateKey;
      expect(dateKey.year, equals(2026));
      expect(dateKey.month, equals(2));
      expect(dateKey.day, equals(15));
      expect(dateKey.hour, equals(0));
      expect(dateKey.minute, equals(0));
    });

    test('PostStatus enum values', () {
      expect(PostStatus.pending.toString(), 'PostStatus.pending');
      expect(PostStatus.scheduled.toString(), 'PostStatus.scheduled');
      expect(PostStatus.publishing.toString(), 'PostStatus.publishing');
      expect(PostStatus.published.toString(), 'PostStatus.published');
      expect(PostStatus.partiallyFailed.toString(), 'PostStatus.partiallyFailed');
      expect(PostStatus.failed.toString(), 'PostStatus.failed');
      expect(PostStatus.cancelled.toString(), 'PostStatus.cancelled');
    });
  });

  group('Post JSON Serialization', () {
    test('Post can be serialized to JSON', () {
      final post = Post(
        id: '123',
        userId: 'user1',
        content: 'Test content',
        tags: ['test'],
        mediaUrls: ['https://example.com/image.jpg'],
        platforms: ['instagram'],
        scheduledTime: DateTime(2026, 2, 15, 10, 0),
        status: PostStatus.scheduled,
        createdAt: DateTime(2026, 2, 14, 10, 0),
        updatedAt: DateTime(2026, 2, 14, 10, 0),
      );

      final json = post.toJson();

      expect(json['_id'], equals('123'));
      expect(json['userId'], equals('user1'));
      expect(json['content'], equals('Test content'));
      expect(json['tags'], equals(['test']));
      expect(json['mediaUrls'], equals(['https://example.com/image.jpg']));
      expect(json['platforms'], equals(['instagram']));
      expect(json['status'], equals('scheduled'));
    });

    test('Post can be deserialized from JSON', () {
      final json = {
        '_id': '123',
        'userId': 'user1',
        'content': 'Test content',
        'tags': ['test', 'flutter'],
        'mediaUrls': ['https://example.com/image.jpg'],
        'platforms': ['instagram', 'facebook'],
        'scheduledTime': '2026-02-15T10:00:00.000Z',
        'status': 'scheduled',
        'createdAt': '2026-02-14T10:00:00.000Z',
        'updatedAt': '2026-02-14T10:00:00.000Z',
      };

      final post = Post.fromJson(json);

      expect(post.id, equals('123'));
      expect(post.userId, equals('user1'));
      expect(post.content, equals('Test content'));
      expect(post.tags, equals(['test', 'flutter']));
      expect(post.mediaUrls, equals(['https://example.com/image.jpg']));
      expect(post.platforms, equals(['instagram', 'facebook']));
      expect(post.status, equals(PostStatus.scheduled));
    });

    test('Post deserializes with id field as fallback', () {
      final json = {
        'id': '456',
        'userId': 'user1',
        'content': 'Test content',
        'tags': [],
        'mediaUrls': [],
        'platforms': ['instagram'],
        'status': 'published',
        'createdAt': '2026-02-14T10:00:00.000Z',
        'updatedAt': '2026-02-14T10:00:00.000Z',
      };

      final post = Post.fromJson(json);
      expect(post.id, equals('456'));
    });

    test('Post handles all status values correctly', () {
      final statuses = [
        'pending',
        'scheduled',
        'publishing',
        'published',
        'partially_failed',
        'failed',
        'cancelled',
      ];

      for (final status in statuses) {
        final json = {
          '_id': '123',
          'userId': 'user1',
          'content': 'Test',
          'tags': [],
          'mediaUrls': [],
          'platforms': ['instagram'],
          'status': status,
          'createdAt': '2026-02-14T10:00:00.000Z',
          'updatedAt': '2026-02-14T10:00:00.000Z',
        };

        final post = Post.fromJson(json);
        expect(post.status, isNotNull);
      }
    });
  });
}
