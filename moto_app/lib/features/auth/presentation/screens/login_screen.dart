import 'package:flutter/material.dart';
import 'package:moto_app/features/auth/data/datasources/user_http_service.dart';
import 'package:moto_app/features/auth/presentation/screens/home_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../../data/services/session_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.pureBlack, AppColors.bluishGray],
            stops: [0.0, 0.7],
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalMargin,
              vertical: AppConstants.verticalMargin,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        color: AppColors.neonCyan,
                      ),
                      const Spacer(),
                    ],
                  ),
                  Text(
                    'MotoApp',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.titleSpacing),
                  CustomTextField(
                    label: 'username',
                    controller: _usernameController,
                  ),
                  CustomTextField(
                    label: 'password',
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: AppConstants.formSpacing),
                  CustomButton(
                    text: 'Log in',
                    onPressed: () async {
                      final currentContext = context;
                      final loginResult = await UserHttpService().loginUser(
                        _usernameController.text,
                        _passwordController.text,
                      );
                      if (!mounted) return;
                      if (loginResult != null) {
                        await SessionService.saveSession(
                          loginResult['token']!,
                          loginResult['username']!,
                        );
                        // Verify that session was saved correctly
                        final isSessionSaved =
                            await SessionService.isLoggedIn();
                        if (!mounted) return;
                        if (isSessionSaved) {
                          Navigator.pushReplacement(
                            currentContext,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(currentContext).showSnackBar(
                            SnackBar(
                              content: Text('Error al guardar la sesión'),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(currentContext).showSnackBar(
                          SnackBar(
                            content: Text('Usuario o contraseña incorrectos'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
