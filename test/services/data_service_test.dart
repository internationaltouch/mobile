import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:fit_mobile_app/services/data_service.dart';
import 'package:fit_mobile_app/services/api_service.dart';
import 'package:fit_mobile_app/services/database_service.dart';
import 'package:fit_mobile_app/services/database.dart' show createTestDatabase;
import 'package:fit_mobile_app/config/config_service.dart';
import 'package:fit_mobile_app/models/event.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'data_service_test.mocks.dart';

void main() {
  group('DataService Tests', () {
    late MockClient mockClient;

    setUp(() {
      // Set up test database
      DatabaseService.setTestDatabase(createTestDatabase());

      // Set up mock config for testing
      ConfigService.setTestConfig();

      mockClient = MockClient();
      DataService.setHttpClient(mockClient);
      ApiService.setHttpClient(mockClient);
      DataService.clearCache(); // Clear cache before each test
    });

    tearDown(() {
      DataService.resetHttpClient();
      ApiService.resetHttpClient();
      DataService.clearCache(); // Clear cache after each test
      DatabaseService.clearTestDatabase();
      reset(mockClient);
    });

    group('testConnectivity', () {
      test('returns true when connection successful', () async {
        when(mockClient.get(
          Uri.parse('https://www.google.com'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('OK', 200));

        final result = await DataService.testConnectivity();

        expect(result, isTrue);
      });

      test('returns false when connection fails', () async {
        when(mockClient.get(
          Uri.parse('https://www.google.com'),
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        final result = await DataService.testConnectivity();

        expect(result, isFalse);
      });
    });

    group('getEvents', () {
      test('handles API failures gracefully', () async {
        // Mock the competitions API call to return empty array
        when(mockClient.get(
          Uri.parse(
              'https://test.example.com/api/v1/competitions/?format=json'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        final events = await DataService.getEvents();
        expect(events, isA<List<Event>>());
      });
    });

    group('parameter validation', () {
      test('getDivisions throws exception for empty parameters', () async {
        expect(
          () => DataService.getDivisions('', ''),
          throwsA(isA<Exception>()),
        );
      });

      test('getFixtures throws exception for empty parameters', () async {
        expect(
          () => DataService.getFixtures(''),
          throwsA(isA<Exception>()),
        );
      });

      test('getLadder throws exception for missing required parameters',
          () async {
        expect(
          () => DataService.getLadder('test-division'),
          throwsA(isA<Exception>()),
        );
      });

      test('getLadderStages throws exception for missing required parameters',
          () async {
        expect(
          () => DataService.getLadderStages('test-division'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
