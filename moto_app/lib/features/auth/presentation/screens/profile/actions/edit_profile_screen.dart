import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:moto_app/core/constants/app_constants.dart';
import 'package:moto_app/core/utils/input_validators.dart';
import 'package:moto_app/domain/providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _usernameController;

  bool _isEditing = false;
  bool _initialized = false;

  String? _fullNameError;
  String? _emailError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _usernameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final user = context.read<UserProvider>().user;
    _fullNameController.text = user?.fullName ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phoneNumber ?? '';
    _usernameController.text = user?.username ?? '';

    _initialized = true;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    if (_isEditing && !_validateAllFields()) {
      return;
    }
    setState(() {
      if (!_isEditing) {
        _fullNameError = null;
        _emailError = null;
        _phoneError = null;
      }
      _isEditing = !_isEditing;
    });
  }

  bool _validateAllFields() {
    final fullNameError = InputValidators.validateFullName(
      _fullNameController.text,
    );
    final emailError = InputValidators.validateEmail(_emailController.text);
    final phoneError = InputValidators.validatePhoneNumber(
      _phoneController.text,
    );

    setState(() {
      _fullNameError = fullNameError;
      _emailError = emailError;
      _phoneError = phoneError;
    });

    return fullNameError == null && emailError == null && phoneError == null;
  }

  void _handleFullNameChanged(String value) {
    if (!_isEditing) return;
    setState(() {
      _fullNameError = InputValidators.validateFullName(value);
    });
  }

  void _handleEmailChanged(String value) {
    if (!_isEditing) return;
    setState(() {
      _emailError = InputValidators.validateEmail(value);
    });
  }

  void _handlePhoneChanged(String value) {
    if (!_isEditing) return;
    setState(() {
      _phoneError = InputValidators.validatePhoneNumber(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final fallbackName = user?.fullName ?? 'Usuario invitado';
    final displayName =
        _fullNameController.text.isEmpty ? fallbackName : _fullNameController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        actions: [
          TextButton(
            onPressed: _toggleEditing,
            child: Text(
              _isEditing ? 'Guardar cambios' : 'Editar perfil',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Align(
                child: Column(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Nombre completo',
                controller: _fullNameController,
                enabled: _isEditing,
                textCapitalization: TextCapitalization.words,
                onChanged: _handleFullNameChanged,
                errorText: _fullNameError,
              ),
              _buildTextField(
                label: 'Usuario',
                controller: _usernameController,
                enabled: _isEditing,
                textCapitalization: TextCapitalization.none,
              ),
              _buildTextField(
                label: 'Correo electrónico',
                controller: _emailController,
                enabled: _isEditing,
                keyboardType: TextInputType.emailAddress,
                onChanged: _handleEmailChanged,
                errorText: _emailError,
              ),
              _buildTextField(
                label: 'Número de celular',
                controller: _phoneController,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
                onChanged: _handlePhoneChanged,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                errorText: _phoneError,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            onChanged: onChanged,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              filled: !enabled,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                errorText,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
