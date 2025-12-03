import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:moto_app/core/constants/app_constants.dart';
import 'package:moto_app/core/utils/input_validators.dart';
import 'package:moto_app/domain/providers/user_provider.dart';
import 'package:moto_app/features/auth/data/datasources/user_http_service.dart';
import 'package:moto_app/domain/models/user.dart';

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
  bool _isSaving = false;

  String? _fullNameError;
  String? _emailError;
  String? _phoneError;

  // Variables para almacenar valores originales
  String _originalFullName = '';
  String _originalUsername = '';
  String _originalEmail = '';
  String _originalPhone = '';

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

    // Guardar valores originales
    _originalFullName = user?.fullName ?? '';
    _originalUsername = user?.username ?? '';
    _originalEmail = user?.email ?? '';
    _originalPhone = user?.phoneNumber ?? '';

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
    if (_isEditing) {
      // Estamos guardando cambios
      if (!_validateAllFields()) {
        return;
      }
      _saveChanges();
    } else {
      // Estamos activando edición
      setState(() {
        _fullNameError = null;
        _emailError = null;
        _phoneError = null;
        // Guardar valores originales cuando se activa la edición
        _originalFullName = _fullNameController.text;
        _originalUsername = _usernameController.text;
        _originalEmail = _emailController.text;
        _originalPhone = _phoneController.text;
        _isEditing = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    // Comparar valores actuales con originales
    final hasChanges = _fullNameController.text != _originalFullName ||
        _usernameController.text != _originalUsername ||
        _emailController.text != _originalEmail ||
        _phoneController.text != _originalPhone;

    if (!hasChanges) {
      // No hay cambios, solo deshabilitar campos
      setState(() {
        _isEditing = false;
      });
      return;
    }

    // Hay cambios, construir Map con solo campos modificados
    final Map<String, dynamic> updates = {};
    if (_fullNameController.text != _originalFullName) {
      updates['full_name'] = _fullNameController.text;
    }
    if (_usernameController.text != _originalUsername) {
      updates['username'] = _usernameController.text;
    }
    if (_emailController.text != _originalEmail) {
      updates['email'] = _emailController.text;
    }
    if (_phoneController.text != _originalPhone) {
      updates['phone_number'] = _phoneController.text;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = context.read<UserProvider>().user;
      if (user == null) {
        throw Exception('Usuario no encontrado');
      }

      await UserHttpService().updateUserProfile(user.id, updates);

      // Actualizar UserProvider con los nuevos valores
      final updatedUser = User(
        id: user.id,
        fullName: _fullNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        username: _usernameController.text,
        password: user.password,
      );

      context.read<UserProvider>().setUser(updatedUser);

      // Actualizar valores originales
      _originalFullName = _fullNameController.text;
      _originalUsername = _usernameController.text;
      _originalEmail = _emailController.text;
      _originalPhone = _phoneController.text;

      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });

      if (!mounted) return;
      String errorMessage = 'Error al actualizar perfil';
      if (e is Exception) {
        final message = e.toString();
        // Extraer solo el mensaje sin el prefijo "Exception: "
        errorMessage = message.startsWith('Exception: ')
            ? message.substring(11)
            : message;
      } else {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _toggleEditing,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Guardar cambios' : 'Editar perfil'),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      borderSide: BorderSide(
        color: colorScheme.primary.withOpacity(0.3),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          IgnorePointer(
            ignoring: !enabled,
            child: TextFormField(
              controller: controller,
              readOnly: !enabled,
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              onChanged: onChanged,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surface,
                border: border,
                enabledBorder: border,
                disabledBorder: border,
                focusedBorder: border.copyWith(
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
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
