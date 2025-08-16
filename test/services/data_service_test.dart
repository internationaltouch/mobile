import 'package:flutter_test/flutter_test.dart';
import 'package:fit_mobile_app/services/data_service.dart';

void main() {
  group('DataService Tests', () {
    test('getEvents returns a list of events', () {
      final events = DataService.getEvents();
      
      expect(events, isNotEmpty);
      expect(events.length, greaterThan(0));
      expect(events.first.name, isNotEmpty);
    });

    test('getNewsItems returns a list of news items', () {
      final newsItems = DataService.getNewsItems();
      
      expect(newsItems, isNotEmpty);
      expect(newsItems.length, greaterThan(0));
      expect(newsItems.first.title, isNotEmpty);
    });

    test('getDivisions returns divisions for an event', () {
      final divisions = DataService.getDivisions('1', '2024');
      
      expect(divisions, isNotEmpty);
      expect(divisions.length, greaterThan(0));
      expect(divisions.first.name, isNotEmpty);
    });

    test('getFixtures returns fixtures for a division', () {
      final fixtures = DataService.getFixtures('1');
      
      expect(fixtures, isNotEmpty);
      expect(fixtures.length, greaterThan(0));
      expect(fixtures.first.homeTeamName, isNotEmpty);
      expect(fixtures.first.awayTeamName, isNotEmpty);
    });

    test('getLadder returns sorted ladder entries', () {
      final ladder = DataService.getLadder('1');
      
      expect(ladder, isNotEmpty);
      expect(ladder.length, greaterThan(0));
      
      // Check that ladder is sorted by points (descending)
      for (int i = 0; i < ladder.length - 1; i++) {
        expect(ladder[i].points, greaterThanOrEqualTo(ladder[i + 1].points));
      }
    });
  });
}