import 'package:flutter_test/flutter_test.dart';
import 'package:fit_mobile_app/main.dart';

void main() {
  testWidgets('FIT Mobile App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FITMobileApp());

    // Verify that the app loads with the correct title.
    expect(find.text('FIT Mobile App'), findsOneWidget);

    // Verify that bottom navigation is present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Competitions'), findsOneWidget);
  });

  testWidgets('Navigation to competitions works', (WidgetTester tester) async {
    await tester.pumpWidget(const FITMobileApp());

    // Tap the 'Competitions' tab
    await tester.tap(find.text('Competitions'));
    await tester.pumpAndSettle();

    // Verify we're now on the competitions page
    expect(find.text('Competitions & Results'), findsOneWidget);
  });
}
