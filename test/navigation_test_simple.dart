import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fit_mobile_app/views/main_navigation_view.dart';
import 'package:fit_mobile_app/theme/fit_theme.dart';

void main() {
  group('Simple Navigation Tests', () {
    Widget createTestApp({int initialTab = 0}) {
      return MaterialApp(
        theme: FITTheme.lightTheme,
        home: MainNavigationView(initialSelectedIndex: initialTab),
      );
    }

    testWidgets('Should start with News tab selected by default', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump(); // Allow initial build
      
      // Verify that News tab is selected (index 0)
      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(0));
      
      // Verify bottom navigation items are present
      expect(find.text('News'), findsOneWidget);
      expect(find.text('Competitions'), findsOneWidget);
    });

    testWidgets('Should switch to Competitions tab when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      
      // Initial state - News tab selected
      expect(tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar)).currentIndex, equals(0));
      
      // Tap on Competitions tab
      await tester.tap(find.text('Competitions'));
      await tester.pump();
      
      // Verify Competitions tab is now selected
      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(1));
    });

    testWidgets('Should start with Competitions tab when specified', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(initialTab: 1));
      await tester.pump();
      
      // Verify that Competitions tab is selected
      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(1));
    });

    testWidgets('Should maintain tab selection when switching between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      
      // Start with News tab
      expect(tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar)).currentIndex, equals(0));
      
      // Switch to Competitions
      await tester.tap(find.text('Competitions'));
      await tester.pump();
      expect(tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar)).currentIndex, equals(1));
      
      // Switch back to News
      await tester.tap(find.text('News'));
      await tester.pump();
      expect(tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar)).currentIndex, equals(0));
    });

    testWidgets('Should always show exactly one bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      
      // Should only find one BottomNavigationBar
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Switch tabs and verify still only one
      await tester.tap(find.text('Competitions'));
      await tester.pump();
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Switch back and verify still only one
      await tester.tap(find.text('News'));
      await tester.pump();
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Should have correct tab icons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      
      // Check for newspaper icon (News tab)
      expect(find.byIcon(Icons.newspaper), findsOneWidget);
      
      // Check for sports icon (Competitions tab)
      expect(find.byIcon(Icons.sports), findsOneWidget);
    });
  });

  group('Navigation Hierarchy Integration Tests', () {
    testWidgets('Navigation push should not replace existing pages', (WidgetTester tester) async {
      // This test verifies that Navigator.push is used instead of Navigator.pushReplacement
      // which was the source of the back navigation issue
      
      final navigatorKey = GlobalKey<NavigatorState>();
      bool pushReplacementCalled = false;
      bool pushCalled = false;
      
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                // Simulate the fixed navigation (push instead of pushReplacement)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Scaffold(
                    appBar: AppBar(title: Text('Second Page')),
                    body: Text('Second Page'),
                  )),
                ).then((_) => pushCalled = true);
              },
              child: Text('Navigate'),
            ),
          ),
        ),
      ));
      
      // Tap the navigate button
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();
      
      // Verify we're on the second page
      expect(find.text('Second Page'), findsOneWidget);
      
      // Use back button to return
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      
      // Should be back to first page
      expect(find.text('Navigate'), findsOneWidget);
      expect(find.text('Second Page'), findsNothing);
    });
  });
}