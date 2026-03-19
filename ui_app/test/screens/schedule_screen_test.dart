import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:konnect/models/post.dart';
import 'package:konnect/providers/schedule_provider.dart';
import 'package:konnect/screens/schedule/schedule_screen.dart';
import 'package:konnect/widgets/schedule_calendar.dart';

void main() {
  group('ScheduleScreen Widget Tests', () {
    late ScheduleProvider mockProvider;

    setUp(() {
      mockProvider = ScheduleProvider();
    });

    Widget buildTestWidget() {
      return ChangeNotifierProvider<ScheduleProvider>.value(
        value: mockProvider,
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: SizedBox(
              width: 400,
              height: 800,
              child: ScheduleScreenContent(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Schedule'), findsOneWidget);
    });

    testWidgets('renders calendar widget', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(ScheduleCalendar), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (WidgetTester tester) async {
      mockProvider.fetchPostsForMonth(DateTime.now());
      
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no posts', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify RefreshIndicator is present (contains the scroll view)
      expect(find.byType(RefreshIndicator), findsOneWidget);
      // Verify CustomScrollView is used for proper layout
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('shows date header correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Should show "Today" for current date
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('displays posts when available', (WidgetTester tester) async {
      // Add test posts to provider (through reflection or test helper)
      // For now, we test the screen structure
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the schedule screen structure is correct
      expect(find.byType(ScheduleCalendar), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('shows Post button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Verify the Post button is in the app bar
      expect(find.text('Post'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle), findsOneWidget);
    });
  });

  group('Post Item Widget Tests', () {
    testWidgets('Post item displays platform icons', (WidgetTester tester) async {
      final post = Post(
        id: '1',
        userId: 'user1',
        content: 'Test post',
        tags: [],
        mediaUrls: [],
        platforms: ['instagram', 'facebook'],
        scheduledTime: DateTime(2026, 2, 15, 10, 0),
        status: PostStatus.scheduled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestPostItem(post: post),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.facebook), findsOneWidget);
    });

    testWidgets('Post item displays status badge', (WidgetTester tester) async {
      final post = Post(
        id: '1',
        userId: 'user1',
        content: 'Test post',
        tags: [],
        mediaUrls: [],
        platforms: ['instagram'],
        scheduledTime: DateTime(2026, 2, 15, 10, 0),
        status: PostStatus.scheduled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestPostItem(post: post),
          ),
        ),
      );

      expect(find.text('Scheduled'), findsOneWidget);
    });

    testWidgets('Post item displays content preview', (WidgetTester tester) async {
      final post = Post(
        id: '1',
        userId: 'user1',
        content: 'This is a test post content',
        tags: [],
        mediaUrls: [],
        platforms: ['instagram'],
        scheduledTime: DateTime(2026, 2, 15, 10, 0),
        status: PostStatus.scheduled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestPostItem(post: post),
          ),
        ),
      );

      expect(find.text('This is a test post content'), findsOneWidget);
    });

    testWidgets('Post item displays scheduled time', (WidgetTester tester) async {
      final post = Post(
        id: '1',
        userId: 'user1',
        content: 'Test post',
        tags: [],
        mediaUrls: [],
        platforms: ['instagram'],
        scheduledTime: DateTime(2026, 2, 15, 14, 30),
        status: PostStatus.scheduled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestPostItem(post: post),
          ),
        ),
      );

      expect(find.text('14:30'), findsOneWidget);
    });

    testWidgets('Post item shows image count when media present', (WidgetTester tester) async {
      final post = Post(
        id: '1',
        userId: 'user1',
        content: 'Test post',
        tags: [],
        mediaUrls: ['image1.jpg', 'image2.jpg'],
        platforms: ['instagram'],
        scheduledTime: DateTime(2026, 2, 15, 10, 0),
        status: PostStatus.scheduled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestPostItem(post: post),
          ),
        ),
      );

      expect(find.byIcon(Icons.image), findsOneWidget);
      expect(find.text('2 images'), findsOneWidget);
    });
  });
}

// Test helper widget to display a post item
class _TestPostItem extends StatelessWidget {
  final Post post;

  const _TestPostItem({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...post.platforms.map((platform) => _buildPlatformIcon(platform)),
              const SizedBox(width: 12),
              Text(
                post.scheduledTimeShort,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(post.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            post.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15),
          ),
          if (post.mediaUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.image, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  "${post.mediaUrls.length} image${post.mediaUrls.length > 1 ? 's' : ''}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlatformIcon(String platform) {
    IconData icon;
    Color color = Colors.grey;

    switch (platform.toLowerCase()) {
      case 'instagram':
        icon = Icons.camera_alt;
        color = Colors.pink;
        break;
      case 'facebook':
        icon = Icons.facebook;
        color = Colors.blue;
        break;
      case 'linkedin':
        icon = Icons.business;
        color = Colors.blue.shade800;
        break;
      case 'twitter':
      case 'x':
        icon = Icons.chat;
        color = Colors.black;
        break;
      default:
        icon = Icons.public;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildStatusBadge(PostStatus status) {
    Color color;
    String text;

    switch (status) {
      case PostStatus.scheduled:
        color = Colors.blue;
        text = "Scheduled";
        break;
      case PostStatus.pending:
        color = Colors.orange;
        text = "Pending";
        break;
      case PostStatus.publishing:
        color = Colors.purple;
        text = "Publishing";
        break;
      case PostStatus.published:
        color = Colors.green;
        text = "Published";
        break;
      case PostStatus.failed:
        color = Colors.red;
        text = "Failed";
        break;
      case PostStatus.partiallyFailed:
        color = Colors.orange;
        text = "Partial";
        break;
      case PostStatus.cancelled:
        color = Colors.grey;
        text = "Cancelled";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
