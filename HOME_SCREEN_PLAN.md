# Plan de Implementación - HomeScreen

## Información Confirmada
- **animated_item: ^0.0.2** - https://pub.dev/packages/animated_item
- **flutter_floating_bottom_bar: ^1.3.0** - https://pub.dev/packages/flutter_floating_bottom_bar
- Texto fijo: "Hola, Nombre" (por ahora)

## Pasos de Implementación

### 1. Agregar dependencias al pubspec.yaml
- Agregar `animated_item: ^0.0.2`
- Agregar `flutter_floating_bottom_bar: ^1.3.0`
- Ejecutar `flutter pub get`

### 2. Crear pantallas simples (CompareScreen y ProfileScreen)
- Crear `compare_screen.dart` con Text título "Comparar motos" centrado
- Crear `profile_screen.dart` con Text título "Perfil" centrado

### 3. Implementar HomeScreen completa

#### 3.1 Scaffold con AppBar
- Row con `MainAxisAlignment.spaceAround`
- Column con:
  - Text "Hola, Nombre" (título)
  - Text "bienvenido" (subtítulo)
- Container negro (foto perfil) envuelto en GestureDetector (onTap vacío)

#### 3.2 Body - Column scrollable
- SingleChildScrollView con Column
- Padding de 10 en todos los lados
- PageView con altura 200, ancho completo
  - 4 páginas: "Noticia 1", "Noticia 2", "Noticia 3", "Noticia 4"
  - Usar `AnimatedPage` con `FadeEffect` de animated_item
  - Cada página como Card con elevación

#### 3.3 Row con texto y botón
- Text "No sabes que moto comprar?" (60% ancho)
- Espacio 10%
- Botón "comparar motos" (30% ancho, sin onPressed por ahora)

#### 3.4 Título "Motos registradas:"
- Text alineado a la izquierda (título)

#### 3.5 Card con GestureDetector
- Row con:
  - Container negro (40% ancho, altura 100 o máximo disponible, margin 5)
  - Column con datos de ejemplo (55% ancho)
  - Container blanco transparente al final del column (efecto fade)

#### 3.6 Floating Bottom Bar
- Usar `BottomBar` de flutter_floating_bottom_bar
- 3 tabs: Comparar (icono), Home (icono), Perfil (icono)
- Navegación a CompareScreen, HomeScreen, ProfileScreen
- Body callback que maneje las pantallas

### 4. Verificar linting
- Verificar errores de linter después de cada componente
- Asegurar que sigue principios minimalistas
- Verificar colores y estilos consistentes

## Archivos a Crear/Modificar

### Nuevos:
- `moto_app/lib/features/auth/presentation/screens/compare_screen.dart`
- `moto_app/lib/features/auth/presentation/screens/profile_screen.dart`

### Modificar:
- `moto_app/pubspec.yaml` - Agregar dependencias
- `moto_app/lib/features/auth/presentation/screens/home_screen.dart` - Implementación completa

## Diseño Minimalista
- Usar colores existentes: pureBlack, neonCyan, bluishGray, pureWhite
- Mantener espaciado consistente
- Tipografía según AppTheme
- Gradientes existentes donde aplique

