import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import 'initial_screen.dart';
import 'home_screen.dart';
import '../../data/services/session_service.dart';
import '../../../../domain/providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  void _checkSessionAndNavigate() async {
    await Future.delayed(
      const Duration(seconds: AppConstants.splashDurationSeconds),
    );

    if (!mounted) return;

    final isLoggedIn = await SessionService.isLoggedIn();
    final storedUser = isLoggedIn ? await SessionService.loadUser() : null;

    if (!mounted) return;

    if (isLoggedIn) {
      if (storedUser != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(storedUser);
      } else {
        await SessionService.clearSession();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InitialScreen()),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InitialScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.pureWhite,
        child: Center(
          child: Image.asset(
            'assets/animations/race_17904906.gif',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
