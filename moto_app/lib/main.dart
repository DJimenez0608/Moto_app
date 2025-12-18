import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moto_app/domain/providers/gastos_provider.dart';
import 'package:moto_app/domain/providers/maintenance_provider.dart';
import 'package:moto_app/domain/providers/motorcycle_provider.dart';
import 'package:moto_app/domain/providers/news_provider.dart';
import 'package:moto_app/domain/providers/observation_provider.dart';
import 'package:moto_app/domain/providers/soat_provider.dart';
import 'package:moto_app/domain/providers/technomechanical_provider.dart';
import 'package:moto_app/domain/providers/travel_provider.dart';
import 'package:moto_app/domain/providers/trending_product_provider.dart';
import 'package:moto_app/domain/providers/user_provider.dart';
import 'package:moto_app/domain/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // Si no existe el archivo .env, continuar sin él
    debugPrint('No se pudo cargar .env: $e');
  }

  // Inicializar Firebase con manejo de errores
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Si Firebase falla, continuar sin él (para desarrollo/debugging)
    debugPrint('Error al inicializar Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => MotorcycleProvider()),
        ChangeNotifierProvider(create: (context) => TravelProvider()),
        ChangeNotifierProvider(create: (context) => ObservationProvider()),
        ChangeNotifierProvider(create: (context) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (context) => SoatProvider()),
        ChangeNotifierProvider(create: (context) => TechnomechanicalProvider()),
        ChangeNotifierProvider(create: (context) => NewsProvider()),
        ChangeNotifierProvider(create: (context) => GastosProvider()),
        ChangeNotifierProvider(create: (context) => TrendingProductProvider()),
        // Aquí se pueden agregar más providers en el futuro
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'MotoApp',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
