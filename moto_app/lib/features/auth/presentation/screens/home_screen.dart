import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moto_app/core/constants/app_constants.dart';
import 'package:animated_item/animated_item.dart';
import 'package:moto_app/domain/models/maintenance.dart';
import 'package:moto_app/domain/models/motorcycle.dart';
import 'package:moto_app/domain/providers/maintenance_provider.dart';
import 'package:moto_app/domain/providers/motorcycle_provider.dart';
import 'package:moto_app/domain/providers/news_provider.dart';
import 'package:moto_app/domain/providers/user_provider.dart';
import 'package:moto_app/domain/providers/theme_provider.dart';
import 'package:moto_app/domain/providers/gastos_provider.dart';
import 'package:moto_app/features/auth/data/services/budget_service.dart';
import 'package:moto_app/features/auth/presentation/screens/motorcycle_detail_screen.dart';
import 'package:moto_app/features/auth/presentation/screens/trending_screen.dart';
import 'package:provider/provider.dart';
import 'package:moto_app/features/auth/data/datasources/user_http_service.dart';
import 'package:moto_app/features/auth/data/services/session_service.dart';
import 'profile/profile_screen.dart';
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
  double? _budget;
  bool _isBudgetWarningRead = false;
  double? _currentYearTotal;

  @override
  void initState() {
    super.initState();
    _loadMotorcycles();
    _loadNews();
    _loadBudgetInfo();
    // Cargar gastos después del primer frame para evitar problemas durante el build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGastos();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBudgetInfo() async {
    final currentYear = DateTime.now().year;
    final budget = await BudgetService.getBudget(currentYear);
    final isRead = await BudgetService.isBudgetWarningRead(currentYear);
    
    if (mounted) {
      setState(() {
        _budget = budget;
        _isBudgetWarningRead = isRead;
      });
      
      // Cargar el total después de actualizar el estado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateTotal();
      });
    }
  }

  void _updateTotal() {
    if (!mounted) return;
    try {
      final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
      final total = gastosProvider.getTotalByYear(DateTime.now().year);
      
      if (mounted) {
        setState(() {
          _currentYearTotal = total;
        });
      }
    } catch (e) {
      debugPrint('Error updating total: $e');
    }
  }

  Future<void> _loadGastos() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
    
    final user = userProvider.user;
    if (user != null) {
      try {
        await gastosProvider.loadGastos(user.id);
        // Actualizar el total después de cargar los gastos, pero solo después del build
        Future.microtask(() {
          if (mounted) {
            _updateTotal();
          }
        });
      } catch (e) {
        // Silenciar errores de gastos en home screen
        debugPrint('Error al cargar gastos en HomeScreen: $e');
      }
    }
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

    final user = userProvider.user;
    if (user == null) return;

    try {
      await motorcycleProvider.getMotorcycles(user.id, user.username);
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

  Future<void> _loadNews() async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    try {
      await newsProvider.loadNews();
    } catch (e) {
      // Log del error para debugging
      debugPrint('Error al cargar noticias en HomeScreen: $e');
      // No mostrar error al usuario para no molestar
      // Las noticias son opcionales
    }
  }


  void _openMotorcycleDetail(Motorcycle motorcycle) {
    final heroTag = 'motorcycle_${motorcycle.id}';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => MotorcycleDetailScreen(
              motorcycleId: motorcycle.id,
              motorcyclePhotoUrl: motorcycle.photo,
              heroTag: heroTag,
            ),
      ),
    );
  }

  Widget _buildMotorcycleCard(Motorcycle motorcycle) {
    final heroTag = 'motorcycle_${motorcycle.id}';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => _openMotorcycleDetail(motorcycle),
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
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppConstants.borderRadius),
                  ),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.15),
                  ),
                ),
                child: Hero(
                  tag: heroTag,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppConstants.borderRadius),
                    ),
                    child: motorcycle.photo != null
                        ? Image.network(
                            motorcycle.photo!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.motorcycle,
                                size: 50,
                                color: colorScheme.onSurfaceVariant,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          )
                        : Icon(
                            Icons.motorcycle,
                            size: 50,
                            color: colorScheme.onSurfaceVariant,
                          ),
                  ),
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
                  Text(motorcycle.make, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 5),
                  Text(
                    'Año: ${motorcycle.year}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    'Cilindrada: ${motorcycle.displacement ?? 'N/A'}cc',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    'Potencia: ${motorcycle.power}hp',
                    style: theme.textTheme.bodyMedium,
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
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allMaintenanceList = maintenanceProvider.allMaintenance;
    final errorMessage = maintenanceProvider.errorMessage;
    final registeredMotorcycleIds = {
      for (final motorcycle in motorcycleProvider.motorcycles)
        motorcycle.id
    };
    final motorcycleNameById = {
      for (final motorcycle in motorcycleProvider.motorcycles)
        motorcycle.id: '${motorcycle.make} ${motorcycle.model}',
    };

    // Filtrar mantenimientos para mostrar solo los de motos registradas
    final maintenanceList = allMaintenanceList
        .where((maintenance) =>
            registeredMotorcycleIds.contains(maintenance.motorcycleId))
        .toList();

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
      color: colorScheme.surface,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Advertencia de presupuesto excedido
              _BudgetWarningWidget(
                budget: _budget,
                isRead: _isBudgetWarningRead,
                currentYearTotal: _currentYearTotal,
                onMarkAsRead: () {
                  setState(() {
                    _isBudgetWarningRead = true;
                  });
                },
              ),
              // PageView con noticias
              Consumer<NewsProvider>(
                builder: (context, newsProvider, _) {
                  final newsList = newsProvider.news;
                  final itemCount = newsList.isEmpty ? 1 : newsList.length;

                  return SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (newsList.isEmpty) {
                          return AnimatedPage(
                            controller: _pageController,
                            index: index,
                            effect: const FadeEffect(),
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              elevation: 4,
                              child: Center(
                                child: Text(
                                  'Cargando noticias...',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                            ),
                          );
                        }

                        final news = newsList[index];
                        return AnimatedPage(
                          controller: _pageController,
                          index: index,
                          effect: const FadeEffect(),
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                try {
                                  final uri = Uri.parse(news.link);
                                  if (!await launchUrl(
                                    uri,
                                    mode: LaunchMode.platformDefault,
                                  )) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No se pudo abrir el enlace de la noticia',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadius,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(news.thumbnailSmall),
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {
                                      // Manejar error de carga de imagen
                                    },
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Gradiente para legibilidad del título
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            AppConstants.borderRadius,
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.7),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Fecha arriba derecha
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(
                                            AppConstants.borderRadius,
                                          ),
                                        ),
                                        child: Text(
                                          news.formattedDate,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    ),
                                    // Título abajo izquierda
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      right: 8,
                                      child: Text(
                                        news.title,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    final accentColor = themeProvider.accentColor;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar:
          _currentTab == 1
              ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.logout),
                  color: Colors.redAccent,
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
                          'Hola, ${userProvider.user?.username}',
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
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person, color: colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              )
              : null,
      body: IndexedStack(
        index: _currentTab,
        children: [
          const TrendingScreen(),
          _buildBody(motorcycleProvider, maintenanceProvider, accentColor),
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
            icon: Icon(Icons.trending_up),
            label: 'Tendencias',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _BudgetWarningWidget extends StatelessWidget {
  const _BudgetWarningWidget({
    required this.budget,
    required this.isRead,
    required this.currentYearTotal,
    required this.onMarkAsRead,
  });

  final double? budget;
  final bool isRead;
  final double? currentYearTotal;
  final VoidCallback onMarkAsRead;

  @override
  Widget build(BuildContext context) {
    if (budget == null || isRead) {
      return const SizedBox.shrink();
    }

    if (currentYearTotal == null) {
      return const SizedBox.shrink();
    }

    final isExceeded = currentYearTotal! > budget!;

    if (!isExceeded) {
      return const SizedBox.shrink();
    }

    final difference = currentYearTotal! - budget!;
    final theme = Theme.of(context);

    String _getFormattedTotal(double total) {
      final rounded = total.toStringAsFixed(0);
      final buffer = StringBuffer();
      final chars = rounded.split('').reversed.toList();
      for (int i = 0; i < chars.length; i++) {
        if (i != 0 && i % 3 == 0) buffer.write(',');
        buffer.write(chars[i]);
      }
      final formatted = buffer.toString().split('').reversed.join();
      return '\$ $formatted';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
        border: Border.all(
          color: Colors.red.shade300,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade700,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Presupuesto excedido',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Has superado tu presupuesto por ${_getFormattedTotal(difference)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final currentYear = DateTime.now().year;
              await BudgetService.markBudgetWarningAsRead(currentYear);
              onMarkAsRead();
            },
            child: const Text('Leído'),
          ),
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
  final colorScheme = theme.colorScheme;
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
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: const BorderRadius.all(
                Radius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Icon(Icons.build, color: colorScheme.onPrimary, size: 20),
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
                color: colorScheme.onSurface,
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
