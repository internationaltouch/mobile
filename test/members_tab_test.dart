import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fit_mobile_app/views/main_navigation_view.dart';
import 'package:fit_mobile_app/theme/fit_theme.dart';
import 'package:fit_mobile_app/config/config_service.dart';

void main() {
  group('Navigation Tab Configuration Tests', () {
    setUp(() {
      // Initialize ConfigService for all navigation tests
      ConfigService.setTestConfig();
    });
    Widget createTestApp({int initialTab = 0}) {
      return MaterialApp(
        theme: FITTheme.lightTheme,
        home: MainNavigationView(initialSelectedIndex: initialTab),
      );
    }

    testWidgets('Should have correct number of navigation tabs from config',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Get configuration-based labels
      final config = ConfigService.config.navigation;
      final enabledTabs = config.tabs.where((tab) => tab.enabled).toList();

      // Check for all enabled tabs from configuration
      for (final tab in enabledTabs) {
        expect(find.text(tab.label), findsOneWidget);
      }

      // Check bottom navigation bar has correct number of enabled tabs
      final bottomNavBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.items.length, equals(enabledTabs.length));
    });

    testWidgets('Should start with News tab selected by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      final bottomNavBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(0));
    });

    testWidgets('Should switch to second tab when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Get the second enabled tab from config
      final config = ConfigService.config.navigation;
      final enabledTabs = config.tabs.where((tab) => tab.enabled).toList();
      if (enabledTabs.length > 1) {
        final secondTab = enabledTabs[1];
        
        // Tap on second tab
        await tester.tap(find.text(secondTab.label));
        await tester.pump();

        // Verify second tab is selected (index 1)
        final bottomNavBar =
            tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(1));
      }
    });

    testWidgets('Should switch to third tab when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Get the third enabled tab from config
      final config = ConfigService.config.navigation;
      final enabledTabs = config.tabs.where((tab) => tab.enabled).toList();
      if (enabledTabs.length > 2) {
        final thirdTab = enabledTabs[2];
        
        // Tap on third tab
        await tester.tap(find.text(thirdTab.label));
        await tester.pump();

        // Verify third tab is selected (index 2)
        final bottomNavBar =
            tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(2));
      }
    });

    testWidgets('Should switch to fourth tab when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Get the fourth enabled tab from config
      final config = ConfigService.config.navigation;
      final enabledTabs = config.tabs.where((tab) => tab.enabled).toList();
      if (enabledTabs.length > 3) {
        final fourthTab = enabledTabs[3];
        
        // Tap on fourth tab
        await tester.tap(find.text(fourthTab.label));
        await tester.pump();

        // Verify fourth tab is selected (index 3)
        final bottomNavBar =
            tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(3));
      }
    });

    testWidgets('Should display icons matching configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      // Get configuration-based icons
      final config = ConfigService.config.navigation;
      final enabledTabs = config.tabs.where((tab) => tab.enabled).toList();

      // Verify each configured tab has its expected icon
      for (final tab in enabledTabs) {
        expect(find.byIcon(tab.iconData), findsOneWidget);
      }
    });
  });
}
