import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData buildLightTheme(Color accentColor) {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: accentColor,
      onPrimary: AppColors.pureWhite,
      secondary: AppColors.accentCoral,
      onSecondary: AppColors.pureWhite,
      error: Colors.redAccent,
      onError: AppColors.pureWhite,
      surface: AppColors.surfaceSoft,
      onSurface: AppColors.neutralText,
      surfaceTint: accentColor,
      onSurfaceVariant: AppColors.mutedText,
    );

    return _baseTheme(colorScheme, AppColors.pureWhite, _lightTextTheme);
  }

  static ThemeData buildDarkTheme(Color accentColor) {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: accentColor,
      onPrimary: AppColors.pureWhite,
      secondary: accentColor,
      onSecondary: AppColors.pureWhite,
      error: Colors.redAccent,
      onError: AppColors.pureWhite,
      surface: const Color(0xFF1E1E2A),
      onSurface: AppColors.pureWhite,
      surfaceTint: accentColor,
      onSurfaceVariant: Colors.grey.shade400,
    );

    return _baseTheme(
      colorScheme,
      const Color(0xFF0F172A),
      _darkTextTheme,
    );
  }

  static ThemeData _baseTheme(
    ColorScheme colorScheme,
    Color scaffoldBackground,
    TextTheme textTheme,
  ) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      cardTheme: CardTheme(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scaffoldBackground,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colorScheme.surface,
        headerBackgroundColor: colorScheme.primary,
        headerForegroundColor: colorScheme.onPrimary,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.onSurface;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        weekdayStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        yearStyle: TextStyle(color: colorScheme.onSurface),
        dayStyle: TextStyle(color: colorScheme.onSurface),
      ),
    );
  }

  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
      color: AppColors.pureBlack,
    ),
    displayMedium: TextStyle(
      fontSize: 35,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
      color: AppColors.pureBlack,
    ),
    displaySmall: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: AppColors.pureBlack,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: AppColors.pureBlack,
    ),
    headlineSmall: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w500,
      color: AppColors.pureBlack,
    ),
    titleLarge: TextStyle(
      fontSize: 23,
      fontWeight: FontWeight.w500,
      color: AppColors.pureBlack,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
      color: AppColors.neutralText,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.4,
      color: AppColors.mutedText,
    ),
  );

  static const TextTheme _darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
      color: AppColors.pureWhite,
    ),
    displayMedium: TextStyle(
      fontSize: 35,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
      color: AppColors.pureWhite,
    ),
    displaySmall: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: AppColors.pureWhite,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: AppColors.pureWhite,
    ),
    headlineSmall: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w500,
      color: AppColors.pureWhite,
    ),
    titleLarge: TextStyle(
      fontSize: 23,
      fontWeight: FontWeight.w500,
      color: AppColors.pureWhite,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
      color: Colors.white70,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.4,
      color: Colors.white60,
    ),
  );
}
