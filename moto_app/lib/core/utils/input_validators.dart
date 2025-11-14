class InputValidators {
  static String? validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$', caseSensitive: false);
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  static String? validatePhoneNumber(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Ingresa tu número de celular';
    }
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'Solo se permiten números';
    }
    return null;
  }

  static String? validateFullName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Ingresa tu nombre completo';
    }
    final nameRegex = RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÑñÜü\s]+$');
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Solo se permiten letras';
    }
    return null;
  }
}

