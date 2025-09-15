import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/main_navigation_view.dart';
import 'theme/configurable_theme.dart';
import 'config/config_service.dart';
import 'services/user_preferences_service.dart';
import 'services/favorites_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize configuration
  await ConfigService.initialize();

  // Initialize user preferences
  await UserPreferencesService.init();

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: FITMobileApp()));
}

class FITMobileApp extends StatelessWidget {
  const FITMobileApp({super.key});

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
