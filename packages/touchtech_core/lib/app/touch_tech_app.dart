import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchtech_core/touchtech_core.dart';

/// Initialize and run a TouchTech application.
///
/// This function handles all common initialization tasks:
/// - Configuration loading
/// - User preferences initialization
/// - Device service initialization
/// - Orientation locking to portrait mode
Future<void> runTouchTechApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize configuration
  await ConfigService.initialize();

  // Initialize user preferences
  await UserPreferencesService.init();

  // Initialize device service
  await DeviceService.instance.initialize();

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: TouchTechApp()));
}

/// The main TouchTech application widget.
///
/// This widget creates a MaterialApp configured from the app's configuration
/// service, with routing set up to use MainNavigationView.
class TouchTechApp extends StatelessWidget {
  const TouchTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = ConfigService.config;
    return MaterialApp(
      title: config.displayName,
      theme: ConfigurableTheme.lightTheme,
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
