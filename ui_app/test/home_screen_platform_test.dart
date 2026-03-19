import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:konnect/providers/platform_provider.dart';
import 'package:konnect/screens/home_screen.dart';

void main() {
  group('HomeScreen Platform Selector Tests', () {
    testWidgets('Platform selector button shows current platform icon', (WidgetTester tester) async {
      final platformProvider = PlatformProvider();
      await platformProvider.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: platformProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('Tapping platform selector opens bottom sheet', (WidgetTester tester) async {
      final platformProvider = PlatformProvider();
      await platformProvider.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: platformProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_drop_down));
      await tester.pumpAndSettle();

      expect(find.text('Select Platform'), findsOneWidget);
    });

    testWidgets('Selecting platform updates provider', (WidgetTester tester) async {
      final platformProvider = PlatformProvider();
      await platformProvider.initialize();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: platformProvider),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_drop_down));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Facebook'));
      await tester.pumpAndSettle();

      expect(platformProvider.selectedPlatform, 'FB');
    });
  });
}
