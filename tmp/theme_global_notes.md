# Theme Global Adjustments Notes

## Research TODOs
- [x] Revisar `home_screen.dart` para identificar colores hardcodeados (background, botones, appbar avatars).
- [x] Revisar `add_motorcycle_screen.dart` para detectar acentos (sliders, iconos, botones, fecha container).
- [x] Revisar `money_balance_screen.dart` para containers en modo oscuro y botón “Establecer presupuesto”.
- [x] Revisar `edit_profile_screen.dart` estilos de campos deshabilitados y AppBar button color.
- [ ] Confirmar cómo otras pantallas usan `Theme.of(context).colorScheme` para replicar contraste.

## Findings
- Home usa `AppColors.pureWhite` para body y `AppColors.accentCoral`/`surfaceAlt` para CTAs; avatar/botones usan colores fijos y no respetan `accentColor` (logout debe seguir rojo).
- Dialog y lista de gestionar motos tienen múltiples `AppColors.primaryBlue`/`accentCoral`; contenedor de fecha está en `AppColors.surfaceSoft` (debe permanecer blanco aunque haya tema oscuro).
- Pantalla de gastos mantiene contenedores blancos y botón rojo sin importar modo; necesita usar `colorScheme` y `accentColor`.
- Editar perfil: `TextFormField` deshabilitado se ve gris al usar `enabled=false`; AppBar `TextButton` usa rojo fijo en vez de `accentColor`.

## Implementation TODOs
- [x] Vincular home body/background/cards/botones al tema dinámico + color de usuario.
- [x] Sincronizar componentes de gestionar motos (sliders, iconos, botones) con `accentColor`, respetando fondos blancos en contenedores de fechas.
- [x] Ajustar pantalla de gastos para usar colores temáticos y soportar dark mode.
- [x] Actualizar Editar perfil: campos deshabilitados como habilitados, AppBar text button con color de usuario.
- [x] Revisar contraste general (light/dark) para garantizar legibilidad.

