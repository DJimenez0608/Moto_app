import 'package:flutter/material.dart';
import 'package:moto_app/domain/providers/maintenance_provider.dart';
import 'package:moto_app/domain/providers/motorcycle_provider.dart';
import 'package:moto_app/domain/providers/observation_provider.dart';
import 'package:moto_app/domain/providers/soat_provider.dart';
import 'package:moto_app/domain/providers/technomechanical_provider.dart';
import 'package:moto_app/domain/providers/travel_provider.dart';
import 'package:moto_app/domain/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => MotorcycleProvider()),
        ChangeNotifierProvider(create: (context) => TravelProvider()),
        ChangeNotifierProvider(create: (context) => ObservationProvider()),
        ChangeNotifierProvider(create: (context) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (context) => SoatProvider()),
        ChangeNotifierProvider(create: (context) => TechnomechanicalProvider()),
        // Aquí se pueden agregar más providers en el futuro
      ],
      child: MaterialApp(
        title: 'MotoApp',
        theme: AppTheme.theme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
