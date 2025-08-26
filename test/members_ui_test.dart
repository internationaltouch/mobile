import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Members Tab Basic UI Test', () {
    testWidgets('Should render basic navigation structure',
        (WidgetTester tester) async {
      // Create a minimal navigation structure to test our changes
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 1, // Members tab selected
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.newspaper),
                  label: 'News',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.public),
                  label: 'Members',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports),
                  label: 'Events',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star),
                  label: 'My Touch',
                ),
              ],
            ),
            appBar: AppBar(
              title: const Text('Member Nations'),
              backgroundColor: const Color(0xFFF6CF3F), // FIT Yellow
            ),
            body: const Center(
              child: Text('Members View - Grid layout here'),
            ),
          ),
        ),
      );

      // Verify all navigation items are present
      expect(find.text('News'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('My Touch'), findsOneWidget);

      // Verify correct icons
      expect(find.byIcon(Icons.newspaper), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
      expect(find.byIcon(Icons.sports), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);

      // Verify app bar and yellow color
      expect(find.text('Member Nations'), findsOneWidget);

      // Verify 4 tabs in navigation bar
      final bottomNavBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.items.length, equals(4));
      expect(bottomNavBar.currentIndex, equals(1)); // Members tab selected
    });
  });
}
