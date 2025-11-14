import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moto_app/core/theme/app_colors.dart';
import 'package:moto_app/core/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _loadPreferences();
  }

  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';

  ThemeMode _themeMode = ThemeMode.light;
  Color _accentColor = AppColors.primaryBlue;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Color get accentColor => _accentColor;

  ThemeData get lightTheme => AppTheme.buildLightTheme(_accentColor);
  ThemeData get darkTheme => AppTheme.buildDarkTheme(_accentColor);

  Future<void> toggleThemeMode() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, isDarkMode ? 'dark' : 'light');
  }

  Future<void> updateAccentColor(Color color) async {
    if (color == _accentColor) return;
    _accentColor = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.value);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMode = prefs.getString(_themeModeKey);
    final storedColorValue = prefs.getInt(_accentColorKey);

    if (storedMode != null) {
      _themeMode = storedMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }

    if (storedColorValue != null) {
      _accentColor = Color(storedColorValue);
    }

    notifyListeners();
  }
}
