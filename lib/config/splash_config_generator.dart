import 'dart:io';
import 'package:flutter/material.dart';
import 'config_service.dart';

class SplashConfigGenerator {
  static Future<void> generateSplashConfig({
    String outputPath = 'splash_config.yaml',
  }) async {
    final config = ConfigService.config;
    final splash = config.branding.splashScreen;
    
    final splashConfigContent = '''
flutter_native_splash:
  color: "${_colorToHex(splash.backgroundColor)}"
  image: "${splash.image}"
  color_dark: "${_colorToHex(splash.backgroundColor)}"
  image_dark: "${splash.image}"
  adaptive_icon_background: "${_colorToHex(splash.imageBackgroundColor)}"
  adaptive_icon_foreground: "${splash.image}"
''';

    final file = File(outputPath);
    await file.writeAsString(splashConfigContent);
  }

  static String _colorToHex(Color color) {
    final r = ((color.r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    final g = ((color.g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    final b = ((color.b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }
}

// Extension to convert Color to hex string
extension ColorToHex on Color {
  String toHex() {
    final r = ((this.r * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    final g = ((this.g * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    final b = ((this.b * 255.0).round() & 0xff).toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }
}