import 'package:flutter_test/flutter_test.dart';
import 'package:fit_mobile_app/services/data_service.dart';
import 'package:fit_mobile_app/models/event.dart';
import 'package:fit_mobile_app/models/news_item.dart';
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
      DataService.setHttpClient(mockClient);
      DataService.clearCache(); // Clear cache before each test
    });

    tearDown(() {
      DataService.resetHttpClient();
      DataService.clearCache(); // Clear cache after each test
      reset(mockClient);
    });

    group('getNewsItems', () {
      test('successfully parses RSS feed', () async {
        // Mock RSS response
        const rssXml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/">
  <channel>
    <title>International Touch News</title>
    <item>
      <title>Test News Item</title>
      <link>https://example.com/news/test-item.html</link>
      <description>This is a test news item description.</description>
      <pubDate>Mon, 01 Jan 2024 12:00:00 +0000</pubDate>
      <content:encoded><![CDATA[<p>This is the full content of the news item.</p>]]></content:encoded>
    </item>
  </channel>
</rss>''';

        when(mockClient.get(
          Uri.parse('https://www.internationaltouch.org/news/feeds/rss/'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(rssXml, 200));

        final newsItems = await DataService.getNewsItems();

        expect(newsItems, hasLength(1));
        expect(newsItems.first.title, equals('Test News Item'));
        expect(newsItems.first.summary,
            equals('This is a test news item description.'));
        expect(newsItems.first.content, contains('This is the full content'));
        expect(newsItems.first.link,
            equals('https://example.com/news/test-item.html'));
      });

      test('handles RSS feed failure gracefully', () async {
        when(mockClient.get(
          Uri.parse('https://www.internationaltouch.org/news/feeds/rss/'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Not Found', 404));

        expect(
          () => DataService.getNewsItems(),
          throwsA(isA<Exception>()),
        );
      });

      test('handles network timeout', () async {
        when(mockClient.get(
          Uri.parse('https://www.internationaltouch.org/news/feeds/rss/'),
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Connection timeout'));

        expect(
          () => DataService.getNewsItems(),
          throwsA(isA<Exception>()),
        );
      });

      test('handles malformed XML', () async {
        when(mockClient.get(
          Uri.parse('https://www.internationaltouch.org/news/feeds/rss/'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Invalid XML content', 200));

        expect(
          () => DataService.getNewsItems(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateNewsItemImage', () {
      test('successfully extracts Open Graph image', () async {
        const htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta property="og:image" content="https://example.com/image.jpg" />
</head>
<body>Test content</body>
</html>''';

        final newsItem = NewsItem(
          id: 'test',
          title: 'Test Item',
          summary: 'Test summary',
          imageUrl: 'placeholder.jpg',
          publishedAt: DateTime.now(),
          link: 'https://example.com/article',
        );

        when(mockClient.get(Uri.parse('https://example.com/article')))
            .thenAnswer((_) async => http.Response(htmlContent, 200));

        await DataService.updateNewsItemImage(newsItem);

        expect(newsItem.imageUrl, equals('https://example.com/image.jpg'));
      });

      test('handles missing Open Graph image', () async {
        const htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <title>Test Article</title>
</head>
<body>Test content without og:image</body>
</html>''';

        const originalImageUrl = 'placeholder.jpg';
        final newsItem = NewsItem(
          id: 'test',
          title: 'Test Item',
          summary: 'Test summary',
          imageUrl: originalImageUrl,
          publishedAt: DateTime.now(),
          link: 'https://example.com/article',
        );

        when(mockClient.get(Uri.parse('https://example.com/article')))
            .thenAnswer((_) async => http.Response(htmlContent, 200));

        await DataService.updateNewsItemImage(newsItem);

        // Should remain unchanged when no og:image found
        expect(newsItem.imageUrl, equals(originalImageUrl));
      });

      test('handles HTTP errors when fetching image', () async {
        const originalImageUrl = 'placeholder.jpg';
        final newsItem = NewsItem(
          id: 'test',
          title: 'Test Item',
          summary: 'Test summary',
          imageUrl: originalImageUrl,
          publishedAt: DateTime.now(),
          link: 'https://example.com/article',
        );

        when(mockClient.get(Uri.parse('https://example.com/article')))
            .thenAnswer((_) async => http.Response('Not Found', 404));

        await DataService.updateNewsItemImage(newsItem);

        // Should remain unchanged on HTTP error
        expect(newsItem.imageUrl, equals(originalImageUrl));
      });
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

      test('getLadder throws exception for empty parameters', () async {
        expect(
          () => DataService.getLadder(''),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
