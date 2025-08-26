import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fit_mobile_app/views/main_navigation_view.dart';
import 'package:fit_mobile_app/theme/fit_theme.dart';

void main() {
  group('Members Tab Navigation Tests', () {
    Widget createTestApp({int initialTab = 0}) {
      return MaterialApp(
        theme: FITTheme.lightTheme,
        home: MainNavigationView(initialSelectedIndex: initialTab),
      );
    }

    testWidgets('Should have 4 navigation tabs including Members',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Check for all 4 tabs
      expect(find.text('News'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('My Touch'), findsOneWidget);

      // Check bottom navigation bar has 4 items
      final bottomNavBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.items.length, equals(4));
    });

    testWidgets('Should start with News tab selected by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      final bottomNavBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(0));
    });

    testWidgets('Should switch to Members tab when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Tap on Members tab
      await tester.tap(find.text('Members'));
      await tester.pump();

      // Verify Members tab is selected (index 1)
      final bottomNavBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(1));
    });

    testWidgets('Should switch to Events tab when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Tap on Events tab
      await tester.tap(find.text('Events'));
      await tester.pump();

      // Verify Events tab is selected (index 2, shifted due to Members tab)
      final bottomNavBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(2));
    });

    testWidgets('Should switch to My Touch tab when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Tap on My Touch tab
      await tester.tap(find.text('My Touch'));
      await tester.pump();

      // Verify My Touch tab is selected (index 3, shifted due to Members tab)
      final bottomNavBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(3));
    });

    testWidgets('Should have correct icons for each tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Check for correct icons
      expect(find.byIcon(Icons.newspaper), findsOneWidget); // News
      expect(find.byIcon(Icons.public), findsOneWidget); // Members (globe)
      expect(find.byIcon(Icons.sports), findsOneWidget); // Events
      expect(find.byIcon(Icons.star), findsOneWidget); // My Touch
    });
  });
}
