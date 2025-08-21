import 'package:flutter/material.dart';
import 'fit_colors.dart';

/// Official FIT app theme following brand guidelines
class FITTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: FITColors.lightColorScheme,

      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: FITColors.primaryBlack,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: FITColors.primaryBlack,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: FITColors.primaryBlack,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: FITColors.primaryBlack,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: FITColors.primaryBlack,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: FITColors.primaryBlack,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: FITColors.primaryBlack,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: FITColors.primaryBlack,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: FITColors.darkGrey,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: FITColors.primaryBlack,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: FITColors.primaryBlack,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: FITColors.darkGrey,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: FITColors.primaryBlack,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: FITColors.darkGrey,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: FITColors.mediumGrey,
        ),
      ),

      // App Bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: FITColors.primaryBlue,
        foregroundColor: FITColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: FITColors.white,
        ),
        iconTheme: IconThemeData(
          color: FITColors.white,
        ),
      ),

      // Navigation Bar theme
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: FITColors.white,
        indicatorColor: FITColors.primaryBlue,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: FITColors.primaryBlue,
          ),
        ),
      ),

      // Elevated Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FITColors.primaryBlue,
          foregroundColor: FITColors.white,
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

      // Outlined Button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FITColors.primaryBlue,
          side: const BorderSide(color: FITColors.primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: FITColors.primaryBlue,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card theme
      cardTheme: const CardTheme(
        color: FITColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Input Decoration theme
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: FITColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: FITColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: FITColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: FITColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: FITColors.errorRed, width: 2),
        ),
        labelStyle: TextStyle(
          color: FITColors.darkGrey,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          color: FITColors.mediumGrey,
          fontSize: 14,
        ),
      ),

      // Progress Indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: FITColors.primaryBlue,
        linearTrackColor: FITColors.lightGrey,
        circularTrackColor: FITColors.lightGrey,
      ),

      // Snack Bar theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: FITColors.primaryBlack,
        contentTextStyle: TextStyle(
          color: FITColors.white,
          fontSize: 14,
        ),
        actionTextColor: FITColors.accentYellow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: FITColors.outline,
        thickness: 1,
        space: 1,
      ),

      // List Tile theme
      listTileTheme: const ListTileThemeData(
        textColor: FITColors.primaryBlack,
        iconColor: FITColors.darkGrey,
        tileColor: FITColors.white,
        selectedTileColor: FITColors.surfaceVariant,
        selectedColor: FITColors.primaryBlue,
      ),
    );
  }
}
