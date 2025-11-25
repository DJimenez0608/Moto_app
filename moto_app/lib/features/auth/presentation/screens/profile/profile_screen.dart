import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moto_app/core/constants/app_constants.dart';
import 'package:moto_app/core/theme/app_colors.dart';
import 'package:moto_app/domain/providers/motorcycle_provider.dart';
import 'package:moto_app/domain/providers/theme_provider.dart';
import 'package:moto_app/domain/providers/user_provider.dart';
import 'package:moto_app/features/auth/presentation/screens/profile/actions/add_motorcycle_screen.dart';
import 'package:moto_app/features/auth/presentation/screens/profile/actions/compare_screen.dart';
import 'package:moto_app/features/auth/presentation/screens/profile/actions/edit_profile_screen.dart';
import 'package:moto_app/features/auth/presentation/screens/profile/actions/money_balance_screen.dart';
import 'package:moto_app/features/auth/presentation/widgets/profile_action_tile.dart';
import 'package:moto_app/features/auth/data/datasources/user_http_service.dart';
import 'package:moto_app/features/auth/data/services/session_service.dart';
import 'package:moto_app/features/auth/presentation/screens/initial_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isThemePanelOpen = false;

  static const List<Color> _accentOptions = [
    Colors.redAccent,
    Colors.deepOrangeAccent,
    Color(0xFFF59E0B),
    Color(0xFF22C55E),
    Color(0xFF0D9488),
    Colors.blueAccent,
    Colors.indigoAccent,
    Colors.deepPurpleAccent,
  ];

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await UserHttpService().logoutUser();
      await SessionService.clearSession();

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.clearUser();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const InitialScreen()),
        (route) => false,
      );
    } catch (e) {
      await SessionService.clearSession();

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

  void _toggleThemePanel() {
    setState(() {
      _isThemePanelOpen = !_isThemePanelOpen;
    });
  }

  Future<void> _showColorPicker(ThemeProvider themeProvider) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecciona un color'),
          content: SizedBox(
            width: double.maxFinite,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _accentOptions
                  .map((color) => _ColorOption(
                        color: color,
                        isSelected: color.value == themeProvider.accentColor.value,
                        onTap: () {
                          themeProvider.updateAccentColor(color);
                          Navigator.of(context).pop();
                        },
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final motorcycleProvider = context.watch<MotorcycleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final user = userProvider.user;
    final fullName = user?.fullName ?? 'Usuario invitado';
    final motorcycleCount = motorcycleProvider.motorcycles.length;
    void openScreen(Widget screen) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _ProfileHeader(fullName: fullName),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatsCard(
                      motorcycleCount: motorcycleCount,
                      hasUser: user != null,
                    ),
                    const SizedBox(height: 24),
                    if (user == null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Inicia sesión nuevamente para ver y editar tu información.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    Text(
                      'Acciones rápidas',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildThemePanel(themeProvider),
                    const SizedBox(height: 12),
                    ProfileActionTile(
                      title: 'Gestionar motos',
                      icon: Icons.add,
                      onTap: () => openScreen(const AddMotorcycleScreen()),
                    ),
                    const SizedBox(height: 12),
                    ProfileActionTile(
                      title: 'Gastos',
                      icon: Icons.attach_money,
                      onTap: () => openScreen(const MoneyBalanceScreen()),
                    ),
                    const SizedBox(height: 12),
                    ProfileActionTile(
                      title: 'Comparar',
                      icon: Icons.compare_arrows_outlined,
                      onTap: () => openScreen(const CompareScreen()),
                    ),
                    const SizedBox(height: 12),
                    ProfileActionTile(
                      title: 'Editar perfil',
                      icon: Icons.edit,
                      onTap: () => openScreen(const EditProfileScreen()),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.85),
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                        ),
                        onPressed: () => _handleLogout(context),
                        child: const Text('Cerrar sesión'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemePanel(ThemeProvider themeProvider) {
    final radiusValue = AppConstants.borderRadius;
    final colorScheme = Theme.of(context).colorScheme;

    final BorderRadius tileRadius = _isThemePanelOpen
        ? BorderRadius.only(
            topLeft: Radius.circular(radiusValue),
            topRight: Radius.circular(radiusValue),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          )
        : BorderRadius.circular(radiusValue);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radiusValue),
        boxShadow: _isThemePanelOpen
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          ProfileActionTile(
            title: 'Colores y tema de la aplicación',
            icon: Icons.wb_sunny_outlined,
            onTap: _toggleThemePanel,
            trailing: Icon(
              _isThemePanelOpen ? Icons.expand_less : Icons.expand_more,
              color: colorScheme.onSurfaceVariant,
            ),
            borderRadius: tileRadius,
            backgroundColor: colorScheme.surface,
          ),
          AnimatedCrossFade(
            crossFadeState: _isThemePanelOpen
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
            firstChild: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(radiusValue),
                  bottomRight: Radius.circular(radiusValue),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildColorRow(themeProvider),
                  const SizedBox(height: 12),
                  Divider(color: colorScheme.onSurface.withOpacity(0.1)),
                  const SizedBox(height: 12),
                  _buildModeRow(themeProvider),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow(ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Color de tu app',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Define el acento para íconos y botones.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: themeProvider.accentColor,
            border: Border.all(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: themeProvider.accentColor.withOpacity(0.15),
            foregroundColor: themeProvider.accentColor,
            shape: const StadiumBorder(),
          ),
          onPressed: () => _showColorPicker(themeProvider),
          child: const Text('Cambiar'),
        ),
      ],
    );
  }

  Widget _buildModeRow(ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    final isDark = themeProvider.isDarkMode;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Claro/Oscuro',
            style: theme.textTheme.titleMedium,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface.withOpacity(0.2),
          ),
          child: IconButton(
            icon: Icon(
              isDark ? Icons.nightlight_round : Icons.wb_sunny_outlined,
              color: themeProvider.accentColor,
            ),
            onPressed: () => themeProvider.toggleThemeMode(),
          ),
        ),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.fullName});

  final String fullName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppConstants.borderRadius * 3),
                bottomRight: Radius.circular(AppConstants.borderRadius * 3),
              ),
              child: Image.asset(
                'assets/images/red_and_dark_diagonal_grunge_background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.borderRadius * 3),
                  bottomRight: Radius.circular(AppConstants.borderRadius * 3),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.black,

                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius * 3,
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  fullName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.motorcycleCount, required this.hasUser});

  final int motorcycleCount;
  final bool hasUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final motorcyclesValue = hasUser ? '$motorcycleCount' : '--';

    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Motos registradas',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(
                height: 54,
                child: VerticalDivider(
                  thickness: 3,
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    motorcyclesValue,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
