import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:konnect/providers/platform_provider.dart';
import 'package:konnect/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen platform selector test', (WidgetTester tester) async {
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
  });
}
