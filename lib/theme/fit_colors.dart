import 'package:flutter/material.dart';

/// Official FIT brand colors based on FIT Brandbook (Updated 23 Mar 2015)
class FITColors {
  // Primary brand colors
  static const Color primaryBlue = Color(0xFF003A70); // Pantone 654C
  static const Color primaryBlack = Color(0xFF222222); // Natural Black C
  static const Color accentYellow = Color(0xFFF6CF3F); // Pantone 129C
  static const Color errorRed = Color(0xFFB12128); // Pantone 7621C
  static const Color successGreen = Color(0xFF73A950); // Pantone 7489C

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);

  // Surface colors for Material 3
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceVariant = Color(0xFFF3F3F3);
  static const Color outline = Color(0xFFE0E0E0);

  // Color scheme for Material 3 theming
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryBlue,
    onPrimary: white,
    secondary: accentYellow,
    onSecondary: primaryBlack,
    tertiary: successGreen,
    onTertiary: white,
    error: errorRed,
    onError: white,
    surface: surface,
    onSurface: primaryBlack,
    surfaceContainerHighest: surfaceVariant,
    onSurfaceVariant: darkGrey,
    outline: outline,
    outlineVariant: mediumGrey,
    shadow: Color(0x1F000000),
    scrim: Color(0x80000000),
    inverseSurface: primaryBlack,
    onInverseSurface: white,
    inversePrimary: Color(0xFF7BB3FF),
  );
}
