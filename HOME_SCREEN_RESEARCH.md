# Investigación - HomeScreen Implementation

## Requisitos del Usuario

### Componentes de HomeScreen:

1. **Scaffold con AppBar:**
   - Row con spaceAround
   - Column con "Hola, Nombre" y "bienvenido"
   - Container negro (foto perfil) con GestureDetector (onClick vacío)

2. **Body → Column scrollable:**
   - Margen 10 todos los lados
   - PageView con Cards que dicen "Noticia 1-4"
   - Usar animated_item de pub.dev con fade effect
   - Ancho completo, altura 200
   
3. **Row:**
   - Text "No sabes que moto comprar?" (60%)
   - Botón "comparar motos" (30%)
   - Espacio 10%
   
4. **Título "Motos registradas:"** alineado izquierda

5. **Card con GestureDetector:**
   - Row con:
     - Container negro (40% ancho, 100 altura o máximo disponible, margin 5)
     - Column con datos de ejemplo (55% ancho)
     - Container blanco transparente al final del column

6. **Floating Bottom Bar:**
   - Usar flutter_floating_bottom_bar
   - 3 tabs: Comparar, Home, Perfil
   - Navegación a CompareScreen y ProfileScreen (simples por ahora)

## Investigaciones Necesarias

### Librerías Confirmadas:
1. **animated_item: ^0.0.2** - https://pub.dev/packages/animated_item
   - Usar `AnimatedPage` con `FadeEffect` para PageView
   - Requiere PageController
   - Fade effect para transiciones

2. **flutter_floating_bottom_bar: ^1.3.0** - https://pub.dev/packages/flutter_floating_bottom_bar
   - Usar `BottomBar` widget
   - Requiere body callback y child widget
   - Para tab bar con 3 elementos

### Colores y Estilos Actuales:
- **Colores:**
  - pureBlack: #000000
  - neonCyan: #00FFFF
  - bluishGray: #1F2937
  - pureWhite: #FFFFFF
  - darkPurple: #7C3AED

- **Gradientes:**
  - LinearGradient: pureBlack → bluishGray (stops: 0.0, 0.7)

- **Tipografía:**
  - displaySmall: 24px, w600, letterSpacing 0.5
  - titleLarge: 18px, w500
  - bodyLarge: 16px, normal

- **Espaciado:**
  - borderRadius: 8.0
  - horizontalMargin: 20.0
  - verticalMargin: 40.0

### Datos del Usuario:
- Texto fijo: "Hola, Nombre" (por ahora)
- "bienvenido" como subtítulo

### Pantallas Nuevas a Crear:
1. **CompareScreen**: Text título centrado
2. **ProfileScreen**: Text título centrado

### Notas:
- Mantener diseño minimalista
- Usar colores y estilos existentes
- GestureDetectors sin acción (vacíos por ahora)
- Botón "comparar motos" sin onclick por ahora

