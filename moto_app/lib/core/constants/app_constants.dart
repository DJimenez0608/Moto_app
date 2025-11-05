import 'dart:io';

class AppConstants {
  // Border radius
  static const double borderRadius = 8.0;

  // Spacing
  static const double horizontalMargin = 20.0;
  static const double verticalMargin = 40.0;
  static const double buttonHorizontalMargin = 5.0;
  static const double buttonVerticalMargin = 10.0;
  static const double titleSpacing = 20.0;
  static const double formSpacing = 25.0;

  // Splash screen duration (3s GIF + 1s additional)
  static const int splashDurationSeconds = 4;

  // API Base URL
  // Para Android Emulator usar 10.0.2.2 en lugar de localhost
  // Para dispositivos físicos usar la IP local de tu máquina (ej: 192.168.1.100)
  static String get apiBaseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      return 'http://localhost:3000';
    } else {
      return 'http://localhost:3000';
    }
  }
}
