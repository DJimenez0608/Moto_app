# Edit Profile Research Notes

## Research TODOs
- [x] Revisar la implementación actual de `edit_profile_screen.dart`.
- [x] Revisar `signup_screen.dart` para entender validaciones existentes y reutilizables.
- [x] Confirmar qué campos expone `UserProvider.user`.
- [ ] Consultar guías de Flutter sobre campos editables/teclados apropiados (pendiente solo si surgen dudas adicionales).

## Hallazgos
- `EditProfileScreen` es actualmente un `StatelessWidget` con contenido placeholder; no utiliza `UserProvider`.
- El modelo `User` expone `fullName`, `email`, `phoneNumber`, `username` y `password`; no hay `documentNumber`.
- `signup_screen.dart` solo valida contraseñas. No hay validación de email/phone, por lo que conviene extraer helpers compartidos.
- `CustomTextField` no expone configuraciones avanzadas (keyboard, enabled), por lo que el perfil puede usar `TextFormField` personalizados.

## Implementation TODOs
- [x] Convertir `EditProfileScreen` en `StatefulWidget` con `TextEditingController`s y estado `isEditing`.
- [x] Construir encabezado con avatar circular y estructura con `SingleChildScrollView`.
- [x] Crear `core/utils/input_validators.dart` con helpers para email, teléfono y nombre.
- [x] Integrar los helpers en la pantalla de perfil mostrando errores bajo cada campo y habilitando teclado correcto.
- [x] Reutilizar el helper de email en `signup_screen.dart` para mantener consistencia.
- [x] Ejecutar lint tras cada bloque significativo de cambios.

