import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'views/main_navigation_view.dart';
import 'theme/fit_theme.dart';
import 'services/background_update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize background update service
  try {
    await BackgroundUpdateService.initialize();
    debugPrint('🚀 [Main] ✅ Background update service initialized');
  } catch (e) {
    debugPrint('🚀 [Main] ❌ Failed to initialize background update service: $e');
  }

  runApp(const FITMobileApp());
}

class FITMobileApp extends StatelessWidget {
  const FITMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIT',
      theme: FITTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final initialIndex = args?['selectedIndex'] ?? 0;
          return MainNavigationView(initialSelectedIndex: initialIndex);
        },
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
