import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internationaltouch/main.dart';
import 'package:internationaltouch/services/database_service.dart';
import 'package:internationaltouch/services/database.dart'
    show createTestDatabase, AppDatabase;
import 'package:internationaltouch/views/competitions_view_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:internationaltouch/services/data_service.dart';
import 'package:internationaltouch/services/api_service.dart';
import 'package:touchtech_core/config/config_service.dart';

@GenerateMocks([http.Client])
import 'widget_test.mocks.dart';

void main() {
  late MockClient mockClient;
  late AppDatabase testDb;

  setUpAll(() {
    // Create a single test database instance for all tests
    testDb = createTestDatabase();
    DatabaseService.setTestDatabase(testDb);

    // Initialize ConfigService with test config
    ConfigService.setTestConfig();
  });

  setUp(() {
    mockClient = MockClient();
    DataService.setHttpClient(mockClient);
    ApiService.setHttpClient(mockClient);
    DataService.clearCache();

    // Mock RSS feed requests
    when(mockClient.get(
      Uri.parse('https://test.example.com/news/rss'),
      headers: anyNamed('headers'),
    )).thenAnswer(
        (_) async => http.Response('''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Test News</title>
    <item>
      <title>Test News Item</title>
      <link>https://example.com/test</link>
      <description>Test description</description>
      <pubDate>Mon, 01 Jan 2024 12:00:00 +0000</pubDate>
    </item>
  </channel>
</rss>''', 200));

    // Mock API calls to return empty/valid data
    when(mockClient.get(
      argThat(predicate((Uri uri) => uri.path.contains('/api/'))),
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response('[]', 200));

    // Fallback for any other requests
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('[]', 200));
  });

  tearDown(() {
    DataService.resetHttpClient();
    ApiService.resetHttpClient();
    DataService.clearCache();
    reset(mockClient);
  });

  tearDownAll(() {
    DatabaseService.clearTestDatabase();
  });

  testWidgets('FIT Mobile App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: FITMobileApp()));

    // Allow time for initial data loading attempts
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify that the app loads (check for bottom navigation tabs since title is now a logo)
    expect(find.text('News'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
  });

  testWidgets('Navigation to events works', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FITMobileApp()));

    // Allow time for initial data loading attempts
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Tap the 'Events' tab
    await tester.tap(find.text('Events'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify we're now on the events page by checking for CompetitionsViewRiverpod
    expect(find.byType(CompetitionsViewRiverpod), findsOneWidget);
  });
}
