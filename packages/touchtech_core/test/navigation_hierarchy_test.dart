import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchtech_core/views/main_navigation_view.dart';
import 'package:touchtech_competitions/views/competitions_view_riverpod.dart';
import 'package:touchtech_core/views/favorites_view.dart';
import 'package:touchtech_core/theme/fit_theme.dart';
import 'package:touchtech_core/config/config_service.dart';

void main() {
  group('Navigation Hierarchy Tests', () {
    setUp(() {
      // Initialize ConfigService for all navigation tests
      ConfigService.setTestConfig();
    });
    Widget createTestApp({int initialTab = 0}) {
      return ProviderScope(
        child: MaterialApp(
          theme: FITTheme.lightTheme,
          home: MainNavigationView(initialSelectedIndex: initialTab),
        ),
      );
    }

    testWidgets('Should maintain navigation stack when switching tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(initialTab: 2));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Start on Events tab (Competitions tab)
      expect(find.byType(CompetitionsViewRiverpod), findsOneWidget);

      // Switch to News tab
      await tester.tap(find.text('News'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Switch back to Events tab
      await tester.tap(find.text('Events'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Should still be on CompetitionsViewRiverpod (navigation state preserved)
      expect(find.byType(CompetitionsViewRiverpod), findsOneWidget);
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

      // Switch to My Sport tab
      final config = ConfigService.config.navigation;
      final enabledTabs = config.tabs.where((tab) => tab.enabled).toList();
      final mySportTab = enabledTabs[3]; // Fourth tab (My Sport)
      await tester.tap(find.text(mySportTab.label));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Bottom navigation should still be visible
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(FavoritesView), findsOneWidget);
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
      expect(getNavBar().currentIndex, equals(2));
      expect(find.byType(CompetitionsViewRiverpod), findsOneWidget);

      // Switch to My Sport (index 3)
      final config2 = ConfigService.config.navigation;
      final enabledTabs2 = config2.tabs.where((tab) => tab.enabled).toList();
      final mySportTab2 = enabledTabs2[3]; // Fourth tab (My Sport)
      await tester.tap(find.text(mySportTab2.label));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(getNavBar().currentIndex, equals(3));
      expect(find.byType(FavoritesView), findsOneWidget);

      // Switch back to News (index 0)
      await tester.tap(find.text('News'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(getNavBar().currentIndex, equals(0));
    });

    testWidgets('Should start with correct tab based on initial index',
        (WidgetTester tester) async {
      // Test starting with My Sport tab (index 3)
      await tester.pumpWidget(createTestApp(initialTab: 3));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final navBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.currentIndex, equals(3));
      expect(find.byType(FavoritesView), findsOneWidget);
    });

    group('My Sport Navigation Integration', () {
      testWidgets('Should be able to switch from My Sport to Events tab',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(initialTab: 3));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Start on My Sport tab
        expect(find.byType(FavoritesView), findsOneWidget);

        // Simulate user tapping a favorite (which should switch to Events tab)
        await tester.tap(find.text('Events'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Should now be on Events tab showing CompetitionsViewRiverpod
        expect(find.byType(CompetitionsViewRiverpod), findsOneWidget);
        final navBar = tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(navBar.currentIndex, equals(2));
      });
    });
  });

  group('Navigation State Persistence', () {
    testWidgets('Should maintain separate navigation stacks per tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: FITTheme.lightTheme,
          home: const MainNavigationView(initialSelectedIndex: 0),
        ),
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
      expect(getNavBar().currentIndex, equals(2));

      // Switch to My Sport tab
      final config3 = ConfigService.config.navigation;
      final enabledTabs3 = config3.tabs.where((tab) => tab.enabled).toList();
      final mySportTab3 = enabledTabs3[3]; // Fourth tab (My Sport)
      await tester.tap(find.text(mySportTab3.label));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(getNavBar().currentIndex, equals(3));

      // Switch back to Events - should still be on CompetitionsViewRiverpod root
      await tester.tap(find.text('Events'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(CompetitionsViewRiverpod), findsOneWidget);
    });
  });
}
