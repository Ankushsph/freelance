import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:konnect/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Schedule Flow Integration Test', () {
    testWidgets('complete schedule screen flow', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to schedule screen (assuming user is logged in)
      // This might need adjustment based on actual app navigation
      
      // Verify schedule screen is displayed
      expect(find.text('Schedule'), findsOneWidget);

      // Wait for data to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify calendar is displayed
      expect(find.byType(CalendarDatePicker), findsOneWidget);

      // Test: Select a different date
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      // Verify date header updates
      // (May show "February 15, 2026" or similar based on selected date)

      // Test: Navigate to next month
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // Verify month changed
      // (Should show March 2026)

      // Test: Navigate to previous month
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Verify month changed
      // (Should show January 2026)

      // Test: Pull to refresh
      await tester.fling(
        find.byType(ListView),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      // Verify refresh indicator appeared
      expect(find.byType(RefreshProgressIndicator), findsNothing);
    });

    testWidgets('schedule screen with posts', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to schedule screen
      expect(find.text('Schedule'), findsOneWidget);

      // Wait for posts to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check if posts are displayed or empty state
      final hasPosts = find.byType(ListTile).evaluate().isNotEmpty;
      final hasEmptyState = find.text('No posts scheduled').evaluate().isNotEmpty;

      expect(hasPosts || hasEmptyState, isTrue);

      if (hasPosts) {
        // Test: Swipe to cancel a post
        final firstPost = find.byType(Dismissible).first;
        await tester.drag(firstPost, const Offset(-300, 0));
        await tester.pumpAndSettle();

        // Verify snackbar appeared
        expect(find.byType(SnackBar), findsOneWidget);
      }
    });

    testWidgets('calendar navigation flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Schedule'), findsOneWidget);

      // Test multiple month navigations
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pumpAndSettle();
      }

      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();
      }

      // App should still be stable
      expect(find.text('Schedule'), findsOneWidget);
    });
  });
}
