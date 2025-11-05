import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Por ahora no hay providers, cuando se agreguen usar MultiProvider
    // return MultiProvider(
    //   providers: [
    //     // Aquí se pueden agregar más providers en el futuro
    //   ],
    //   child: MaterialApp(...),
    // );

    return MaterialApp(
      title: 'MotoApp',
      theme: AppTheme.theme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
