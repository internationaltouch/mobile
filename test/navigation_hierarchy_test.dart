import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fit_mobile_app/views/main_navigation_view.dart';
import 'package:fit_mobile_app/views/competitions_view.dart';
import 'package:fit_mobile_app/views/my_touch_view.dart';
import 'package:fit_mobile_app/theme/fit_theme.dart';

void main() {
  group('Navigation Hierarchy Tests', () {
    Widget createTestApp({int initialTab = 0}) {
      return MaterialApp(
        theme: FITTheme.lightTheme,
        home: MainNavigationView(initialSelectedIndex: initialTab),
      );
    }

    testWidgets('Should maintain navigation stack when switching tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(initialTab: 1));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Start on Events tab (Competitions tab)
      expect(find.byType(CompetitionsView), findsOneWidget);

      // Switch to News tab
      await tester.tap(find.text('News'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Switch back to Events tab
      await tester.tap(find.text('Events'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Should still be on CompetitionsView (navigation state preserved)
      expect(find.byType(CompetitionsView), findsOneWidget);
    });

    testWidgets('Should preserve bottom navigation during navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Bottom navigation should always be visible
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Switch to Events tab
      await tester.tap(find.text('Events'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Bottom navigation should still be visible
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Switch to My Touch tab
      await tester.tap(find.text('My Touch'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Bottom navigation should still be visible
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(MyTouchView), findsOneWidget);
    });

    testWidgets('Should handle tab switching from any tab to any tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Start on News tab (index 0)
      BottomNavigationBar getNavBar() =>
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(getNavBar().currentIndex, equals(0));

      // Switch to Events (index 1)
      await tester.tap(find.text('Events'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(getNavBar().currentIndex, equals(1));
      expect(find.byType(CompetitionsView), findsOneWidget);

      // Switch to My Touch (index 2)
      await tester.tap(find.text('My Touch'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(getNavBar().currentIndex, equals(2));
      expect(find.byType(MyTouchView), findsOneWidget);

      // Switch back to News (index 0)
      await tester.tap(find.text('News'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(getNavBar().currentIndex, equals(0));
    });

    testWidgets('Should start with correct tab based on initial index',
        (WidgetTester tester) async {
      // Test starting with My Touch tab (index 2)
      await tester.pumpWidget(createTestApp(initialTab: 2));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final navBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.currentIndex, equals(2));
      expect(find.byType(MyTouchView), findsOneWidget);
    });

    group('My Touch Navigation Integration', () {
      testWidgets('Should be able to switch from My Touch to Events tab',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(initialTab: 2));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Start on My Touch tab
        expect(find.byType(MyTouchView), findsOneWidget);

        // Simulate user tapping a favorite (which should switch to Events tab)
        await tester.tap(find.text('Events'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Should now be on Events tab showing CompetitionsView
        expect(find.byType(CompetitionsView), findsOneWidget);
        final navBar = tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(navBar.currentIndex, equals(1));
      });
    });
  });

  group('Navigation State Persistence', () {
    testWidgets('Should maintain separate navigation stacks per tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: FITTheme.lightTheme,
        home: const MainNavigationView(initialSelectedIndex: 0),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Each tab should maintain its own navigation state
      // This is verified by checking that switching tabs doesn't affect
      // the content of other tabs

      // Start on News tab
      BottomNavigationBar getNavBar() =>
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(getNavBar().currentIndex, equals(0));

      // Switch to Events tab
      await tester.tap(find.text('Events'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(getNavBar().currentIndex, equals(1));

      // Switch to My Touch tab
      await tester.tap(find.text('My Touch'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(getNavBar().currentIndex, equals(2));

      // Switch back to Events - should still be on CompetitionsView root
      await tester.tap(find.text('Events'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(CompetitionsView), findsOneWidget);
    });
  });
}
