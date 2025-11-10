import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moto_app/core/constants/app_constants.dart';
import 'package:moto_app/core/theme/app_colors.dart';
import 'package:moto_app/domain/providers/motorcycle_provider.dart';
import 'package:moto_app/domain/providers/user_provider.dart';
import 'package:moto_app/features/auth/presentation/screens/profile/actions/add_motorcycle_screen.dart';
import 'package:moto_app/features/auth/presentation/screens/profile/actions/compare_screen.dart';
import 'package:moto_app/features/auth/presentation/screens/profile/actions/edit_profile_screen.dart';
import 'package:moto_app/features/auth/presentation/screens/profile/actions/money_balance_screen.dart';
import 'package:moto_app/features/auth/presentation/screens/profile/actions/settings_screen.dart';
import 'package:moto_app/features/auth/presentation/widgets/profile_action_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final motorcycleProvider = context.watch<MotorcycleProvider>();

    final user = userProvider.user;
    final fullName = user?.fullName ?? 'Usuario invitado';
    final motorcycleCount = motorcycleProvider.motorcycles.length;
    void openScreen(Widget screen) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screen),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
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
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    Text(
                      'Acciones rápidas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ProfileActionTile(
                      title: 'Agregar moto',
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
                    const SizedBox(height: 12),
                    ProfileActionTile(
                      title: 'Configuraciones',
                      icon: Icons.settings,
                      onTap: () => openScreen(const SettingsScreen()),
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
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.primaryBlue,
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

    Widget buildStat(String value, String label) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      );
    }

    final motorcyclesValue = hasUser ? '$motorcycleCount' : '--';
    final racesValue = hasUser ? '0' : '--';

    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildStat(motorcyclesValue, 'Motos'),
              const SizedBox(
                height: 48,
                child: VerticalDivider(
                  thickness: 1,
                  color: AppColors.surfaceAlt,
                ),
              ),
              buildStat(racesValue, '# Carreras'),
              const SizedBox(
                height: 48,
                child: VerticalDivider(
                  thickness: 1,
                  color: AppColors.surfaceAlt,
                ),
              ),
              buildStat(racesValue, 'Ganadas'),
            ],
          ),
        ),
      ),
    );
  }
}
