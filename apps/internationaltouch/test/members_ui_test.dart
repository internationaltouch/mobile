import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internationaltouch/main_navigation_view.dart';
import 'package:touchtech_core/theme/fit_theme.dart';
import 'package:touchtech_core/config/config_service.dart';

void main() {
  group('Navigation UI Configuration Tests', () {
    setUp(() {
      // Initialize ConfigService for all navigation tests
      ConfigService.setTestConfig();
    });

    testWidgets(
        'Should render navigation with configuration-based labels and icons',
        (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: FITTheme.lightTheme,
          home: const MainNavigationView(
              initialSelectedIndex: 1), // Second tab selected
        ),
      ));

      await tester.pump();

      // Get configuration-based labels
      final config = ConfigService.config.navigation;
      final enabledTabs = config.tabs.where((tab) => tab.enabled).toList();

      // Verify all configured navigation items are present
      for (final tab in enabledTabs) {
        expect(find.text(tab.label), findsOneWidget);
        expect(find.byIcon(tab.iconData), findsOneWidget);
      }

      // Verify correct number of tabs in navigation bar
      final bottomNavBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.items.length, equals(enabledTabs.length));
      expect(bottomNavBar.currentIndex, equals(1)); // Second tab selected
    });
  });
}
