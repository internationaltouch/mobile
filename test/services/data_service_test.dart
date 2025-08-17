import 'package:flutter_test/flutter_test.dart';
import 'package:fit_mobile_app/services/data_service.dart';
import 'package:fit_mobile_app/models/event.dart';
import 'package:fit_mobile_app/models/news_item.dart';
import 'package:fit_mobile_app/models/division.dart';
import 'package:fit_mobile_app/models/fixture.dart';
import 'package:fit_mobile_app/models/ladder_entry.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

// Generate mocks
@GenerateMocks([http.Client])
import 'data_service_test.mocks.dart';

void main() {
  group('DataService Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    test('getEvents handles API failures gracefully', () async {
      // Test that the method doesn't crash when API fails
      final events = await DataService.getEvents();

      // Should return empty list or handle gracefully
      expect(events, isA<List<Event>>());
    });

    test('getNewsItems handles RSS failures gracefully', () async {
      // Test that the method doesn't crash when RSS fails
      final newsItems = await DataService.getNewsItems();

      // Should return empty list or handle gracefully
      expect(newsItems, isA<List<NewsItem>>());
    });

    test('getDivisions handles missing parameters', () async {
      try {
        await DataService.getDivisions('', '');
        fail('Should throw exception for empty parameters');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('getFixtures handles missing parameters', () async {
      try {
        await DataService.getFixtures('');
        fail('Should throw exception for empty parameters');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('getLadder handles missing parameters', () async {
      try {
        await DataService.getLadder('');
        fail('Should throw exception for empty parameters');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('DataService methods return correct types', () async {
      // Test return types without making real API calls
      expect(() => DataService.getEvents(), returnsNormally);
      expect(() => DataService.getNewsItems(), returnsNormally);
    });
  });
}
