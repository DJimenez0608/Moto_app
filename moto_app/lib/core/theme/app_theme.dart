import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.neonCyan,
        onPrimary: AppColors.pureWhite,
        secondary: AppColors.darkPurple,
        onSecondary: AppColors.pureWhite,
        error: Colors.red,
        onError: AppColors.pureWhite,
        surface: AppColors.bluishGray,
        onSurface: AppColors.pureWhite,
        surfaceTint: AppColors.pureBlack,
        onSurfaceVariant: AppColors.pureWhite,
      ),
      textTheme: const TextTheme(
        // Títulos principales: aumentados aprox. 25%
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
        // Subtítulos: aumentados aprox. 25%
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
        // Párrafos: 14-16px, Regular, height 1.4-1.6
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: AppColors.pureWhite,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.4,
          color: AppColors.pureWhite,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.bluishGray,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.neonCyan),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.neonCyan, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.neonCyan),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonCyan,
          foregroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
