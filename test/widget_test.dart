import 'package:flutter_test/flutter_test.dart';
import 'package:fit_mobile_app/main.dart';
import 'package:fit_mobile_app/services/database_service.dart';
import 'package:fit_mobile_app/services/database.dart' show createTestDatabase;
import 'package:fit_mobile_app/views/competitions_view.dart';
// Temporarily commented out Mockito imports due to dependency compatibility issues
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';
// import 'package:http/http.dart' as http;

// @GenerateMocks([http.Client])
// import 'widget_test.mocks.dart';

void main() {
  // Temporarily commented out due to Mockito dependency issues
  // late MockClient mockClient;

  setUp(() {
    // Set up test database and mock HTTP client
    DatabaseService.setTestDatabase(createTestDatabase());

    // Temporarily commented out due to Mockito dependency issues
    /*
    mockClient = MockClient();
    DataService.setHttpClient(mockClient);
    ApiService.setHttpClient(mockClient);
    DataService.clearCache();

    // Mock all API calls to return empty/valid data
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('[]', 200));
    */
  });

  tearDown(() {
    // Temporarily commented out due to Mockito dependency issues
    /*
    DataService.resetHttpClient();
    ApiService.resetHttpClient();
    DataService.clearCache();
    */
    DatabaseService.clearTestDatabase();
    // reset(mockClient);
  });

  testWidgets('FIT Mobile App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FITMobileApp());

    // Allow time for initial data loading attempts
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify that the app loads (check for bottom navigation tabs since title is now a logo)
    expect(find.text('News'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
  });

  testWidgets('Navigation to events works', (WidgetTester tester) async {
    await tester.pumpWidget(const FITMobileApp());

    // Allow time for initial data loading attempts
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Tap the 'Events' tab
    await tester.tap(find.text('Events'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify we're now on the events page by checking for CompetitionsView
    expect(find.byType(CompetitionsView), findsOneWidget);
  });
}
