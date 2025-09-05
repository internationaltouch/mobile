import 'package:flutter/material.dart';
import '../config/config_service.dart';

class ConfigurableTheme {
  static ThemeData get lightTheme {
    final config = ConfigService.config;
    final branding = config.branding;

    final ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: branding.primaryColor,
      onPrimary: branding.backgroundColor,
      secondary: branding.secondaryColor,
      onSecondary: branding.textColor,
      tertiary: branding.accentColor,
      onTertiary: branding.backgroundColor,
      error: branding.errorColor,
      onError: branding.backgroundColor,
      surface: branding.backgroundColor,
      onSurface: branding.textColor,
      surfaceContainerHighest: const Color(0xFFF3F3F3),
      onSurfaceVariant: const Color(0xFF424242),
      outline: const Color(0xFFE0E0E0),
      outlineVariant: const Color(0xFF9E9E9E),
      shadow: const Color(0x1F000000),
      scrim: const Color(0x80000000),
      inverseSurface: branding.textColor,
      onInverseSurface: branding.backgroundColor,
      inversePrimary: _lightenColor(branding.primaryColor, 0.3),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Typography using configured text color
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: branding.textColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: branding.textColor,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: branding.textColor,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: branding.textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: branding.textColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: branding.textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: branding.textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: branding.textColor,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _darkenColor(branding.textColor, 0.2),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: branding.textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: branding.textColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: _darkenColor(branding.textColor, 0.2),
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: branding.textColor,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _darkenColor(branding.textColor, 0.2),
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _darkenColor(branding.textColor, 0.4),
        ),
      ),

      // App Bar theme using configured primary color
      appBarTheme: AppBarTheme(
        backgroundColor: branding.primaryColor,
        foregroundColor: branding.backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: branding.backgroundColor,
        ),
        iconTheme: IconThemeData(
          color: branding.backgroundColor,
        ),
      ),

      // Navigation Bar theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: branding.backgroundColor,
        indicatorColor: branding.primaryColor,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: branding.primaryColor,
          ),
        ),
      ),

      // Elevated Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: branding.primaryColor,
          foregroundColor: branding.backgroundColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Other theme components remain similar but using configured colors...
      cardTheme: CardThemeData(
        color: branding.backgroundColor,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: branding.primaryColor,
        linearTrackColor: _lightenColor(branding.textColor, 0.8),
        circularTrackColor: _lightenColor(branding.textColor, 0.8),
      ),
    );
  }

  static Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}