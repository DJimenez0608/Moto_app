# Investigación: FAB Expandible para Agregar Mantenimientos y Observaciones

## Estructura Actual
- `MotorcycleDetailScreen` es un `StatelessWidget`
- Usa `Scaffold` con `AppBar` y `body` con `SingleChildScrollView`
- Tiene un widget `_MotorcycleDetails` que muestra las especificaciones en un `Card`

## Requisitos
1. Convertir `MotorcycleDetailScreen` a `StatefulWidget` para manejar el estado del FAB
2. Agregar un FAB expandible usando `AnimatedContainer`
3. El FAB debe mostrar dos opciones al expandirse:
   - "Agregar observación"
   - "Agregar mantenimiento"
4. Por ahora, los botones no harán nada (solo mostrar)

## Implementación del FAB Expandible
- Usar `AnimatedContainer` para animar la expansión/contracción
- Usar `Stack` para posicionar el FAB principal y los botones expandidos
- Usar `FloatingActionButton` como botón principal
- **Posicionamiento**: El FAB debe estar centrado en la parte inferior de la pantalla (no en la esquina)
- Los botones expandidos deben aparecer arriba del FAB principal
- Usar colores del tema (`colorScheme.primary`, `colorScheme.onPrimary`)
- Usar `AppConstants.borderRadius` para mantener consistencia
- Para centrar: usar `Positioned` con `left: 0, right: 0` y `bottom` o usar `Align` con `Alignment.bottomCenter`

## Estructura del Widget
```
Stack(
  children: [
    // Contenido principal (body)
    // FAB expandible con AnimatedContainer
    // Botones de opciones (Agregar observación, Agregar mantenimiento)
  ]
)
```

## Animación
- Usar `AnimatedContainer` con `duration` apropiado (300-400ms)
- Cambiar `height` y `width` para expandir/contraer
- Usar `Curves.easeInOut` para transición suave

