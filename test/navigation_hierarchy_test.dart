import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fit_mobile_app/views/main_navigation_view.dart';
import 'package:fit_mobile_app/views/competitions_view.dart';
import 'package:fit_mobile_app/views/event_detail_view.dart';
import 'package:fit_mobile_app/views/divisions_view.dart';
import 'package:fit_mobile_app/views/fixtures_results_view.dart';
import 'package:fit_mobile_app/theme/fit_theme.dart';
import 'package:fit_mobile_app/models/event.dart';
import 'package:fit_mobile_app/models/season.dart';
import 'package:fit_mobile_app/models/division.dart';

void main() {
  group('Navigation Hierarchy Tests', () {
    final testEvent = Event(
      id: 'test-event',
      name: 'Test Competition',
      logoUrl: '',
      seasons: [
        Season(title: '2024', slug: '2024'),
      ],
      description: 'Test competition description',
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

    testWidgets(
        'Navigation hierarchy: Competitions -> Event -> Divisions -> Back to Event',
        (WidgetTester tester) async {
      // Create a test navigation stack
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: FITTheme.lightTheme,
        home: CompetitionsView(),
      ));

      // Should start at CompetitionsView
      expect(find.byType(CompetitionsView), findsOneWidget);

      // Navigate to EventDetailView
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: FITTheme.lightTheme,
        home: Navigator(
          pages: [
            MaterialPage(child: CompetitionsView()),
            MaterialPage(child: EventDetailView(event: testEvent)),
          ],
          onPopPage: (route, result) => route.didPop(result),
        ),
      ));
      await tester.pumpAndSettle();

      // Should show EventDetailView
      expect(find.byType(EventDetailView), findsOneWidget);
      expect(find.text('Test Competition'), findsOneWidget);

      // Navigate to DivisionsView
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: FITTheme.lightTheme,
        home: Navigator(
          pages: [
            MaterialPage(child: CompetitionsView()),
            MaterialPage(child: EventDetailView(event: testEvent)),
            MaterialPage(
                child: DivisionsView(event: testEvent, season: '2024')),
          ],
          onPopPage: (route, result) => route.didPop(result),
        ),
      ));
      await tester.pumpAndSettle();

      // Should show DivisionsView
      expect(find.byType(DivisionsView), findsOneWidget);

      // Simulate back navigation
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: FITTheme.lightTheme,
        home: Navigator(
          pages: [
            MaterialPage(child: CompetitionsView()),
            MaterialPage(child: EventDetailView(event: testEvent)),
          ],
          onPopPage: (route, result) => route.didPop(result),
        ),
      ));
      await tester.pumpAndSettle();

      // Should be back to EventDetailView (Season list)
      expect(find.byType(EventDetailView), findsOneWidget);
      expect(find.byType(DivisionsView), findsNothing);
    });

    testWidgets(
        'Navigation hierarchy: Divisions -> Fixtures -> Back to Divisions',
        (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      // Start at DivisionsView
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: FITTheme.lightTheme,
        home: Navigator(
          pages: [
            MaterialPage(child: CompetitionsView()),
            MaterialPage(child: EventDetailView(event: testEvent)),
            MaterialPage(
                child: DivisionsView(event: testEvent, season: '2024')),
          ],
          onPopPage: (route, result) => route.didPop(result),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DivisionsView), findsOneWidget);

      // Navigate to FixturesResultsView
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: FITTheme.lightTheme,
        home: Navigator(
          pages: [
            MaterialPage(child: CompetitionsView()),
            MaterialPage(child: EventDetailView(event: testEvent)),
            MaterialPage(
                child: DivisionsView(event: testEvent, season: '2024')),
            MaterialPage(
                child: FixturesResultsView(
              event: testEvent,
              season: '2024',
              division: testDivision,
            )),
          ],
          onPopPage: (route, result) => route.didPop(result),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FixturesResultsView), findsOneWidget);

      // Simulate back navigation
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: FITTheme.lightTheme,
        home: Navigator(
          pages: [
            MaterialPage(child: CompetitionsView()),
            MaterialPage(child: EventDetailView(event: testEvent)),
            MaterialPage(
                child: DivisionsView(event: testEvent, season: '2024')),
          ],
          onPopPage: (route, result) => route.didPop(result),
        ),
      ));
      await tester.pumpAndSettle();

      // Should be back to DivisionsView
      expect(find.byType(DivisionsView), findsOneWidget);
      expect(find.byType(FixturesResultsView), findsNothing);
    });

    testWidgets('Complete navigation hierarchy with proper back navigation',
        (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      // Test the complete flow: Competitions -> Event -> Divisions -> Fixtures -> Back -> Back -> Back

      // Start at CompetitionsView
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: FITTheme.lightTheme,
        home: CompetitionsView(),
      ));
      expect(find.byType(CompetitionsView), findsOneWidget);

      // Navigate through the hierarchy
      final pages = <MaterialPage>[
        MaterialPage(child: CompetitionsView()),
      ];

      // Add EventDetailView
      pages.add(MaterialPage(child: EventDetailView(event: testEvent)));
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: FITTheme.lightTheme,
        home: Navigator(
          pages: List.from(pages),
          onPopPage: (route, result) => route.didPop(result),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(EventDetailView), findsOneWidget);

      // Add DivisionsView
      pages.add(
          MaterialPage(child: DivisionsView(event: testEvent, season: '2024')));
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: FITTheme.lightTheme,
        home: Navigator(
          pages: List.from(pages),
          onPopPage: (route, result) => route.didPop(result),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(DivisionsView), findsOneWidget);

      // Add FixturesResultsView
      pages.add(MaterialPage(
          child: FixturesResultsView(
        event: testEvent,
        season: '2024',
        division: testDivision,
      )));
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: FITTheme.lightTheme,
        home: Navigator(
          pages: List.from(pages),
          onPopPage: (route, result) => route.didPop(result),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(FixturesResultsView), findsOneWidget);

      // Now test back navigation step by step

      // Back to DivisionsView
      pages.removeLast();
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: FITTheme.lightTheme,
        home: Navigator(
          pages: List.from(pages),
          onPopPage: (route, result) => route.didPop(result),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(DivisionsView), findsOneWidget);
      expect(find.byType(FixturesResultsView), findsNothing);

      // Back to EventDetailView
      pages.removeLast();
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: FITTheme.lightTheme,
        home: Navigator(
          pages: List.from(pages),
          onPopPage: (route, result) => route.didPop(result),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(EventDetailView), findsOneWidget);
      expect(find.byType(DivisionsView), findsNothing);

      // Back to CompetitionsView
      pages.removeLast();
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: FITTheme.lightTheme,
        home: Navigator(
          pages: List.from(pages),
          onPopPage: (route, result) => route.didPop(result),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(CompetitionsView), findsOneWidget);
      expect(find.byType(EventDetailView), findsNothing);
    });
  });

  group('Tab Switching During Navigation', () {
    final testEvent = Event(
      id: 'test-event',
      name: 'Test Competition',
      logoUrl: '',
      seasons: [Season(title: '2024', slug: '2024')],
      description: 'Test competition description',
      slug: 'test-event',
      seasonsLoaded: true,
    );

    testWidgets('Should preserve navigation state when switching tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: FITTheme.lightTheme,
        home: MainNavigationView(initialSelectedIndex: 1),
      ));

      // Start on Competitions tab
      expect(find.byType(CompetitionsView), findsOneWidget);

      // Switch to News tab
      await tester.tap(find.text('News'));
      await tester.pumpAndSettle();

      // Switch back to Competitions tab
      await tester.tap(find.text('Competitions'));
      await tester.pumpAndSettle();

      // Should still be on CompetitionsView (navigation state preserved)
      expect(find.byType(CompetitionsView), findsOneWidget);
    });
  });
}
