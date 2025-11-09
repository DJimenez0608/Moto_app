import 'package:flutter/material.dart';
import 'package:moto_app/core/theme/app_colors.dart';
import 'package:moto_app/core/constants/app_constants.dart';
import 'package:animated_item/animated_item.dart';
import 'package:moto_app/domain/models/maintenance.dart';
import 'package:moto_app/domain/models/motorcycle.dart';
import 'package:moto_app/domain/providers/maintenance_provider.dart';
import 'package:moto_app/domain/providers/motorcycle_provider.dart';
import 'package:moto_app/domain/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:moto_app/features/auth/data/datasources/user_http_service.dart';
import 'package:moto_app/features/auth/data/services/session_service.dart';
import 'compare_screen.dart';
import 'profile_screen.dart';
import 'initial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _currentTab = 1; // Home es el tab central

  @override
  void initState() {
    super.initState();
    _loadMotorcycles();
  }

  Future<void> _loadMotorcycles() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final motorcycleProvider = Provider.of<MotorcycleProvider>(
      context,
      listen: false,
    );
    final maintenanceProvider = Provider.of<MaintenanceProvider>(
      context,
      listen: false,
    );

    final userId = userProvider.user?.id;
    if (userId == null) return;

    try {
      await motorcycleProvider.getMotorcycles(userId);
      maintenanceProvider.clearMaintenance();

      final motorcycles = motorcycleProvider.motorcycles;
      if (motorcycles.isEmpty) {
        return;
      }

      await Future.wait(
        motorcycles.map(
          (motorcycle) => maintenanceProvider.getMaintenance(motorcycle.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMotorcycleCard(Motorcycle motorcycle) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 100,
                margin: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppConstants.borderRadius),
                  ),
                ),
                child: const Icon(
                  Icons.motorcycle,
                  color: AppColors.primaryBlue,
                  size: 36,
                ),
              ),
            ),
            // Column con datos
            Padding(
              padding: const EdgeInsets.only(right: 6.0, top: 10.0, left: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    motorcycle.make,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Año: ${motorcycle.year}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Cilindrada: ${motorcycle.displacement ?? 'N/A'}cc',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Potencia: ${motorcycle.power}hp',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    MotorcycleProvider motorcycleProvider,
    MaintenanceProvider maintenanceProvider,
  ) {
    final maintenanceList = maintenanceProvider.allMaintenance;
    final errorMessage = maintenanceProvider.errorMessage;
    final motorcycleNameById = {
      for (final motorcycle in motorcycleProvider.motorcycles)
        motorcycle.id: '${motorcycle.make} ${motorcycle.model}',
    };

    final Widget maintenanceContent;
    if (maintenanceProvider.isLoading && maintenanceList.isEmpty) {
      maintenanceContent = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (maintenanceList.isEmpty) {
      maintenanceContent = _buildEmptyMaintenanceCard(context);
    } else {
      maintenanceContent = ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: maintenanceList.length,
        itemBuilder: (context, index) {
          final maintenance = maintenanceList[index];
          final motorcycleName = motorcycleNameById[maintenance.motorcycleId];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _buildMaintenanceCard(context, maintenance, motorcycleName),
          );
        },
      );
    }

    return Container(
      color: AppColors.pureWhite,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PageView con noticias
              SizedBox(
                height: 200,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return AnimatedPage(
                      controller: _pageController,
                      index: index,
                      effect: const FadeEffect(),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        elevation: 4,
                        child: Center(
                          child: Text(
                            'Noticia ${index + 1}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              // Row con texto y botón
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Text(
                        'No sabes que moto comprar?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentTab = 0;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentCoral,
                          foregroundColor: AppColors.pureWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                        ),
                        child: const Text('Comparar'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Título Motos registradas
              Text(
                'Motos registradas:',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),
              // ListView.builder con cards de motocicletas
              motorcycleProvider.motorcycles.isEmpty
                  ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No hay motocicletas registradas',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  )
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: motorcycleProvider.motorcycles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _buildMotorcycleCard(
                          motorcycleProvider.motorcycles[index],
                        ),
                      );
                    },
                  ),
              const SizedBox(height: 30),
              Text(
                "Historial de mantenimientos",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 15),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    errorMessage,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                  ),
                ),
              maintenanceContent,
              const SizedBox(height: 100), // Espacio para el bottom bar
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      // Llamar al backend para logout
      await UserHttpService().logoutUser();

      // Limpiar sesión local
      await SessionService.clearSession();

      // Limpiar provider
      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.clearUser();

      // Navegar a InitialScreen limpiando el stack
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const InitialScreen()),
        (route) => false,
      );
    } catch (e) {
      // Si hay error, igual limpiamos la sesión local
      await SessionService.clearSession();

      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.clearUser();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const InitialScreen()),
        (route) => false,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final motorcycleProvider = Provider.of<MotorcycleProvider>(
      context,
      listen: true,
    );
    final maintenanceProvider = Provider.of<MaintenanceProvider>(
      context,
      listen: true,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: true);

    return Scaffold(
      appBar:
          _currentTab == 1
              ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.logout),
                  color: AppColors.primaryBlue,
                  onPressed: _handleLogout,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hola, ${userProvider.user?.fullName}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Bienvenido',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentTab = 2;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceAlt,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : null,
      body: IndexedStack(
        index: _currentTab,
        children: [
          const CompareScreen(),
          _buildBody(motorcycleProvider, maintenanceProvider),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows),
            label: 'Comparar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

Widget _buildMaintenanceCard(
  BuildContext context,
  Maintenance maintenance,
  String? motorcycleName,
) {
  final theme = Theme.of(context);
  final formattedDate = maintenance.date.toIso8601String().split('T').first;

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.1,
            height: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.all(
                Radius.circular(AppConstants.borderRadius),
              ),
            ),
            child: const Icon(
              Icons.build,
              color: AppColors.pureWhite,
              size: 20,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (motorcycleName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      motorcycleName,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                Text(
                  maintenance.description,
                  style: theme.textTheme.titleSmall,
                ),
                Text('Fecha: $formattedDate', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              '${maintenance.cost.toStringAsFixed(2)} COP',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.pureBlack,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildEmptyMaintenanceCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30.0),
    child: SizedBox(
      height: 100,
      child: Card(
        child: Center(
          child: Text(
            'No hay mantenimientos registrados',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
