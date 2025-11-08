import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.pureWhite,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryBlue,
        onPrimary: AppColors.pureWhite,
        secondary: AppColors.accentCoral,
        onSecondary: AppColors.pureWhite,
        error: Colors.redAccent,
        onError: AppColors.pureWhite,
        surface: AppColors.surfaceSoft,
        onSurface: AppColors.neutralText,
        surfaceTint: AppColors.primaryBlue,
        onSurfaceVariant: AppColors.mutedText,
      ),
      textTheme: const TextTheme(
        // Títulos principales: aumentados aprox. 25%
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
        // Subtítulos: aumentados aprox. 25%
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
        // Párrafos: 14-16px, Regular, height 1.4-1.6
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
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceSoft,
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
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.mutedText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.pureBlack,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.pureWhite,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.mutedText,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
