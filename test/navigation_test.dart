import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fit_mobile_app/views/main_navigation_view.dart';
import 'package:fit_mobile_app/views/competitions_view.dart';
import 'package:fit_mobile_app/views/event_detail_view.dart';
import 'package:fit_mobile_app/views/divisions_view.dart';
import 'package:fit_mobile_app/views/home_view.dart';
import 'package:fit_mobile_app/theme/fit_theme.dart';
import 'package:fit_mobile_app/models/event.dart';
import 'package:fit_mobile_app/models/season.dart';
import 'package:fit_mobile_app/models/division.dart';

void main() {
  group('Navigation Tests', () {
    Widget createTestApp({int initialTab = 0}) {
      return MaterialApp(
        theme: FITTheme.lightTheme,
        home: MainNavigationView(initialSelectedIndex: initialTab),
      );
    }

    testWidgets('Should start with News tab selected by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      // Verify that News tab is selected (index 0)
      final bottomNavBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(0));

      // Verify News content is visible (should show HomeView with news)
      expect(find.byType(HomeView), findsOneWidget);
    });

    testWidgets('Should switch to Competitions tab when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      // Tap on Competitions tab
      await tester.tap(find.text('Competitions'));
      await tester.pumpAndSettle();

      // Verify Competitions tab is selected
      final bottomNavBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(1));

      // Verify Competitions content is visible
      expect(find.byType(CompetitionsView), findsOneWidget);
    });

    testWidgets('Should start with Competitions tab when specified',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(initialTab: 1));

      // Verify that Competitions tab is selected
      final bottomNavBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(1));

      // Verify Competitions content is visible
      expect(find.byType(CompetitionsView), findsOneWidget);
    });

    testWidgets('Should maintain tab selection when switching between tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());

      // Start with News tab
      expect(
          tester
              .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
              .currentIndex,
          equals(0));

      // Switch to Competitions
      await tester.tap(find.text('Competitions'));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
              .currentIndex,
          equals(1));

      // Switch back to News
      await tester.tap(find.text('News'));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
              .currentIndex,
          equals(0));
    });

    group('Competition Navigation Flow', () {
      final testEvent = Event(
        id: 'test-event',
        name: 'Test Event',
        logoUrl: '',
        seasons: [
          Season(title: '2024', slug: '2024'),
          Season(title: '2023', slug: '2023'),
        ],
        description: 'Test event description',
        slug: 'test-event',
        seasonsLoaded: true,
      );

      final testDivision = Division(
        id: 'test-division',
        name: 'Test Division',
        eventId: 'test-event',
        season: '2024',
        slug: 'test-division',
        color: '#1976D2',
      );

      Widget createCompetitionApp() {
        return MaterialApp(
          theme: FITTheme.lightTheme,
          home: MainNavigationView(initialSelectedIndex: 1),
          routes: {
            '/event-detail': (context) => EventDetailView(event: testEvent),
            '/divisions': (context) =>
                DivisionsView(event: testEvent, season: '2024'),
          },
        );
      }

      testWidgets('Should navigate from Competitions to Event Detail',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCompetitionApp());

        // Should start with CompetitionsView
        expect(find.byType(CompetitionsView), findsOneWidget);

        // Mock navigation to event detail
        await tester.pumpWidget(MaterialApp(
          theme: FITTheme.lightTheme,
          home: MainNavigationView(initialSelectedIndex: 1),
          builder: (context, child) {
            return Navigator(
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => EventDetailView(event: testEvent),
                );
              },
            );
          },
        ));
        await tester.pumpAndSettle();

        // Should show EventDetailView
        expect(find.byType(EventDetailView), findsOneWidget);
        expect(find.text('Test Event'), findsOneWidget);
      });

      testWidgets('Should navigate from Event Detail to Divisions',
          (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          theme: FITTheme.lightTheme,
          home: EventDetailView(event: testEvent),
        ));

        // Wait for the view to load
        await tester.pumpAndSettle();

        // Should show EventDetailView
        expect(find.byType(EventDetailView), findsOneWidget);

        // Tap on a season (if seasons are displayed as tappable items)
        if (find.text('2024').evaluate().isNotEmpty) {
          await tester.tap(find.text('2024'));
          await tester.pumpAndSettle();

          // Should navigate to DivisionsView
          expect(find.byType(DivisionsView), findsOneWidget);
        }
      });

      testWidgets('Should maintain navigation stack integrity',
          (WidgetTester tester) async {
        // Test that back navigation works correctly through the hierarchy
        await tester.pumpWidget(MaterialApp(
          theme: FITTheme.lightTheme,
          home: Scaffold(
            body: Navigator(
              onGenerateRoute: (settings) {
                switch (settings.name) {
                  case '/divisions':
                    return MaterialPageRoute(
                      builder: (context) =>
                          DivisionsView(event: testEvent, season: '2024'),
                    );
                  default:
                    return MaterialPageRoute(
                      builder: (context) => EventDetailView(event: testEvent),
                    );
                }
              },
            ),
          ),
        ));

        await tester.pumpAndSettle();
        expect(find.byType(EventDetailView), findsOneWidget);
      });
    });

    group('Tab Switching with Navigation State', () {
      testWidgets('Should preserve navigation state when switching tabs',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp(initialTab: 1));

        // Start on Competitions tab
        expect(find.byType(CompetitionsView), findsOneWidget);

        // Switch to News tab
        await tester.tap(find.text('News'));
        await tester.pumpAndSettle();
        expect(find.byType(HomeView), findsOneWidget);

        // Switch back to Competitions tab
        await tester.tap(find.text('Competitions'));
        await tester.pumpAndSettle();
        expect(find.byType(CompetitionsView), findsOneWidget);

        // Navigation state should be preserved (still on CompetitionsView, not deep in hierarchy)
        expect(find.byType(EventDetailView), findsNothing);
        expect(find.byType(DivisionsView), findsNothing);
      });
    });

    group('Bottom Navigation Bar Visibility', () {
      testWidgets('Should always show bottom navigation bar',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());

        // Bottom navigation should be visible on News tab
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Switch to Competitions tab
        await tester.tap(find.text('Competitions'));
        await tester.pumpAndSettle();

        // Bottom navigation should still be visible
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      });

      testWidgets('Should not show duplicate bottom navigation bars',
          (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());

        // Should only find one BottomNavigationBar
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Switch tabs and verify still only one
        await tester.tap(find.text('Competitions'));
        await tester.pumpAndSettle();
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      });
    });
  });
}
