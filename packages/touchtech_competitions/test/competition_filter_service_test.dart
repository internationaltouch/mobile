import 'package:flutter_test/flutter_test.dart';
import 'package:touchtech_competitions/services/competition_filter_service.dart';
import 'package:touchtech_core/config/config_service.dart';
import 'package:touchtech_competitions/models/event.dart';
import 'package:touchtech_competitions/models/season.dart';
import 'package:touchtech_competitions/models/division.dart';

void main() {
  group('CompetitionFilterService Tests', () {
    setUp(() {
      // Initialize ConfigService with test config that has competition filtering
      ConfigService.setTestConfig();
    });

    group('Event Filtering', () {
      test('should filter out competitions by slug', () {
        final events = [
          Event(
            id: '1',
            name: 'World Cup',
            logoUrl: '',
            seasons: [],
            description: '',
            slug: 'world-cup',
            seasonsLoaded: false,
          ),
          Event(
            id: '2',
            name: 'Home Nations',
            logoUrl: '',
            seasons: [],
            description: '',
            slug: 'home-nations',
            seasonsLoaded: false,
          ),
          Event(
            id: '3',
            name: 'European Championships',
            logoUrl: '',
            seasons: [],
            description: '',
            slug: 'euros',
            seasonsLoaded: false,
          ),
        ];

        final filteredEvents = CompetitionFilterService.filterEvents(events);

        // home-nations should be filtered out per test config
        expect(filteredEvents.length, equals(2));
        expect(filteredEvents.any((e) => e.slug == 'world-cup'), isTrue);
        expect(filteredEvents.any((e) => e.slug == 'euros'), isTrue);
        expect(filteredEvents.any((e) => e.slug == 'home-nations'), isFalse);
      });

      test('should handle events with null slugs', () {
        final events = [
          Event(
            id: '1',
            name: 'Event without slug',
            logoUrl: '',
            seasons: [],
            description: '',
            slug: null,
            seasonsLoaded: false,
          ),
        ];

        final filteredEvents = CompetitionFilterService.filterEvents(events);
        expect(filteredEvents.length, equals(1));
      });
    });

    group('Season Filtering', () {
      test('should filter out seasons by competition+season combo', () {
        final event = Event(
          id: '1',
          name: 'World Cup',
          logoUrl: '',
          seasons: [],
          description: '',
          slug: 'world-cup',
          seasonsLoaded: false,
        );

        final seasons = [
          Season(title: '2020', slug: '2020'),
          Season(
              title: '2018',
              slug: '2018'), // This should be filtered per test config
          Season(title: '2022', slug: '2022'),
        ];

        final filteredSeasons =
            CompetitionFilterService.filterSeasons(event, seasons);

        // world-cup:2018 should be filtered out per test config
        expect(filteredSeasons.length, equals(2));
        expect(filteredSeasons.any((s) => s.slug == '2020'), isTrue);
        expect(filteredSeasons.any((s) => s.slug == '2022'), isTrue);
        expect(filteredSeasons.any((s) => s.slug == '2018'), isFalse);
      });

      test('should filter out all seasons if competition is excluded', () {
        final event = Event(
          id: '1',
          name: 'Home Nations',
          logoUrl: '',
          seasons: [],
          description: '',
          slug: 'home-nations', // This competition is excluded
          seasonsLoaded: false,
        );

        final seasons = [
          Season(title: '2020', slug: '2020'),
          Season(title: '2021', slug: '2021'),
        ];

        final filteredSeasons =
            CompetitionFilterService.filterSeasons(event, seasons);

        // All seasons should be filtered because competition is excluded
        expect(filteredSeasons.length, equals(0));
      });
    });

    group('Division Filtering', () {
      test('should filter out divisions by competition+season+division combo',
          () {
        final event = Event(
          id: '1',
          name: 'World Cup',
          logoUrl: '',
          seasons: [],
          description: '',
          slug: 'world-cup',
          seasonsLoaded: false,
        );

        final divisions = [
          Division(
            id: '1',
            name: 'Mens Open',
            eventId: '1',
            season: '2022',
            slug: 'mens-open',
            color: '#1976D2',
          ),
          Division(
            id: '2',
            name: 'Womens 30+',
            eventId: '1',
            season: '2022',
            slug: 'womens-30',
            color: '#1976D2',
          ),
        ];

        final filteredDivisions =
            CompetitionFilterService.filterDivisions(event, '2022', divisions);

        // world-cup:2022:womens-30 should be filtered out per test config
        expect(filteredDivisions.length, equals(1));
        expect(filteredDivisions.any((d) => d.slug == 'mens-open'), isTrue);
        expect(filteredDivisions.any((d) => d.slug == 'womens-30'), isFalse);
      });

      test('should filter out all divisions if competition is excluded', () {
        final event = Event(
          id: '1',
          name: 'Home Nations',
          logoUrl: '',
          seasons: [],
          description: '',
          slug: 'home-nations', // This competition is excluded
          seasonsLoaded: false,
        );

        final divisions = [
          Division(
            id: '1',
            name: 'Mens Open',
            eventId: '1',
            season: '2022',
            slug: 'mens-open',
            color: '#1976D2',
          ),
        ];

        final filteredDivisions =
            CompetitionFilterService.filterDivisions(event, '2022', divisions);

        // All divisions should be filtered because competition is excluded
        expect(filteredDivisions.length, equals(0));
      });
    });

    group('Competition Image Mapping', () {
      test('should return configured image path for competition slug', () {
        final imagePath = CompetitionFilterService.getCompetitionImage('euros');
        expect(imagePath, equals('assets/images/competitions/ETC.png'));
      });

      test('should return null for unknown competition slug', () {
        final imagePath =
            CompetitionFilterService.getCompetitionImage('unknown-competition');
        expect(imagePath, isNull);
      });
    });

    group('Debug Properties', () {
      test('should provide access to excluded slugs', () {
        final excludedSlugs = CompetitionFilterService.excludedSlugs;
        expect(excludedSlugs, contains('home-nations'));
      });

      test('should provide access to excluded season combos', () {
        final excludedCombos = CompetitionFilterService.excludedSeasonCombos;
        expect(excludedCombos, contains('world-cup:2018'));
      });

      test('should provide access to excluded division combos', () {
        final excludedCombos = CompetitionFilterService.excludedDivisionCombos;
        expect(excludedCombos, contains('world-cup:2022:womens-30'));
      });
    });
  });
}
