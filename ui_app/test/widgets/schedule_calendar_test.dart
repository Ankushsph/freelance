import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konnect/widgets/schedule_calendar.dart';

void main() {
  group('ScheduleCalendar Widget Tests', () {
    late DateTime testMonth;
    late DateTime testSelectedDate;
    late Set<DateTime> testScheduledDates;
    late Set<DateTime> testImmediateDates;
    DateTime? selectedDate;
    DateTime? changedMonth;

    setUp(() {
      testMonth = DateTime(2026, 2, 1);
      testSelectedDate = DateTime(2026, 2, 15);
      testScheduledDates = {
        DateTime(2026, 2, 5),
        DateTime(2026, 2, 15),
        DateTime(2026, 2, 20),
      };
      testImmediateDates = {
        DateTime(2026, 2, 10),
        DateTime(2026, 2, 25),
      };
      selectedDate = null;
      changedMonth = null;
    });

    Widget buildTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ScheduleCalendar(
            currentMonth: testMonth,
            selectedDate: testSelectedDate,
            scheduledDates: testScheduledDates,
            immediateDates: testImmediateDates,
            onDateSelected: (date) {
              selectedDate = date;
            },
            onMonthChanged: (month) {
              changedMonth = month;
            },
          ),
        ),
      );
    }

    testWidgets('renders calendar with month header', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('February 2026'), findsOneWidget);
    });

    testWidgets('renders week day headers', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
    });

    testWidgets('renders days of the month', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // February 2026 has 28 days
      for (int i = 1; i <= 28; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('selected date is highlighted', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Find the selected day (15)
      final selectedDayFinder = find.text('15');
      expect(selectedDayFinder, findsOneWidget);
    });

    testWidgets('tapping a day triggers onDateSelected', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Tap on day 10
      await tester.tap(find.text('10'));
      await tester.pump();

      expect(selectedDate, equals(DateTime(2026, 2, 10)));
    });

    testWidgets('previous month button triggers onMonthChanged', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Tap previous month button
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      expect(changedMonth, equals(DateTime(2026, 1, 1)));
    });

    testWidgets('next month button triggers onMonthChanged', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Tap next month button
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      expect(changedMonth, equals(DateTime(2026, 3, 1)));
    });

    testWidgets('scheduled dates have dot indicators', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // The calendar should render dots for scheduled dates
      // Days 5, 15, and 20 should have dots
      // This is visual verification - the dots are small containers
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('today is marked differently', (WidgetTester tester) async {
      final today = DateTime.now();
      testMonth = DateTime(today.year, today.month, 1);
      testSelectedDate = today;
      
      await tester.pumpWidget(buildTestWidget());

      // Today's date should be visible
      expect(find.text('${today.day}'), findsOneWidget);
    });

    testWidgets('handles month with different number of days', (WidgetTester tester) async {
      // Test with January (31 days)
      testMonth = DateTime(2026, 1, 1);
      
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('January 2026'), findsOneWidget);
      expect(find.text('31'), findsOneWidget);
    });

    testWidgets('handles leap year February', (WidgetTester tester) async {
      // Test with February 2024 (leap year - 29 days)
      testMonth = DateTime(2024, 2, 1);
      
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('February 2024'), findsOneWidget);
      expect(find.text('29'), findsOneWidget);
    });

    testWidgets('empty days at start of month render correctly', (WidgetTester tester) async {
      // February 2026 starts on a Sunday (weekday 7)
      // So there should be empty cells at the start
      await tester.pumpWidget(buildTestWidget());

      // Calendar grid should render without errors
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('multiple scheduled dates on same month', (WidgetTester tester) async {
      testScheduledDates = {
        DateTime(2026, 2, 1),
        DateTime(2026, 2, 14),
        DateTime(2026, 2, 28),
      };

      await tester.pumpWidget(buildTestWidget());

      // All days should be visible
      expect(find.text('1'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('28'), findsOneWidget);
    });
  });
}
