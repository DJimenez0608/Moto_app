import 'package:flutter/material.dart';
import 'package:moto_app/features/auth/data/datasources/user_http_service.dart';
import 'package:moto_app/features/auth/presentation/screens/login_screen.dart';
import 'package:moto_app/core/utils/input_validators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  String? _passwordError;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _passwordConfirmationController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final passwordConfirmation = _passwordConfirmationController.text;

    // Solo validar si ambos campos tienen contenido
    if (password.isEmpty && passwordConfirmation.isEmpty) {
      setState(() {
        _passwordError = null;
      });
      return;
    }

    if (password != passwordConfirmation) {
      setState(() {
        _passwordError = 'Las contraseñas no coinciden';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _passwordError = 'La contraseña debe tener al menos 6 caracteres';
      });
      return;
    }

    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    if (!hasNumber || !hasSpecialChar) {
      setState(() {
        _passwordError =
            'La contraseña debe tener al menos un número y un carácter especial';
      });
      return;
    }

    setState(() {
      _passwordError = null;
    });
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _validateEmail() {
    setState(() {
      _emailError = InputValidators.validateEmail(_emailController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.pureWhite,
        child: Center(
          child: SizedBox(
            child: Card(
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.horizontalMargin,
                vertical: AppConstants.verticalMargin,
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                          color: AppColors.primaryBlue,
                        ),
                        const Spacer(),
                      ],
                    ),
                    // Indicador de página
                    SizedBox(
                      height: 8.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _currentPage == index
                                      ? AppColors.primaryBlue
                                      : AppColors.surfaceAlt,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // PageView
                    SizedBox(
                      height: 250,
                      width: 400,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        children: [
                          // Página 1: Full Name
                          SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomTextField(
                                  label: 'full name',
                                  controller: _fullNameController,
                                  textCapitalization: TextCapitalization.words,
                                ),
                              ],
                            ),
                          ),
                          // Página 2: Email y Phone Number
                          SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomTextField(
                                  label: 'email',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (_) => _validateEmail(),
                                ),
                                if (_emailError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      _emailError!,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                CustomTextField(
                                  label: 'phone number',
                                  controller: _phoneNumberController,
                                  keyboardType: TextInputType.phone,
                                ),
                              ],
                            ),
                          ),
                          // Página 3: Username, Password y Confirm Password
                          SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomTextField(
                                  label: 'username',
                                  controller: _usernameController,
                                ),
                                CustomTextField(
                                  label: 'password',
                                  controller: _passwordController,
                                  obscureText: true,
                                ),
                                CustomTextField(
                                  label: 'confirm password',
                                  controller: _passwordConfirmationController,
                                  obscureText: true,
                                ),
                                if (_passwordError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _passwordError!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botones de navegación
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage > 0)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: CustomButton(
                                text: 'Anterior',
                                onPressed: _previousPage,
                                margin: EdgeInsets.zero,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        if (_currentPage < 2)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: _currentPage > 0 ? 8.0 : 0.0,
                              ),
                              child: CustomButton(
                                text: 'Siguiente',
                                onPressed: _nextPage,
                                margin: EdgeInsets.zero,
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: _currentPage > 0 ? 8.0 : 0.0,
                              ),
                              child: CustomButton(
                                text: 'Registrarse',
                                onPressed: () async {
                                  _validatePassword();
                                    _validateEmail();
                                    if (_passwordError == null &&
                                        _emailError == null) {
                                    // Por el momento no hace nada
                                    final currentContext = context;
                                    bool isSignedUp = await UserHttpService()
                                        .signupUser(
                                          _fullNameController.text,
                                          _emailController.text,
                                          _phoneNumberController.text,
                                          _usernameController.text,
                                          _passwordController.text,
                                        );
                                    if (!mounted) return;
                                    if (isSignedUp) {
                                      ScaffoldMessenger.of(currentContext)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Registro exitoso. Por favor inicia sesión'),
                                        ),
                                      );
                                      Navigator.pushAndRemoveUntil(
                                        currentContext,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const LoginScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  }
                                },
                                margin: EdgeInsets.zero,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
