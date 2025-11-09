# Investigación: ListView.builder para Motocicletas en HomeScreen

## Fecha de Investigación
Fecha: 2025

## Contexto Actual

### Estructura Actual de _buildBody
- Actualmente muestra solo la primera motocicleta: `motorcycleProvider.motorcycles[0]`
- Usa un operador ternario para mostrar mensaje si está vacío o un Card con la primera motocicleta
- El Card está hardcodeado para mostrar solo un elemento

### Estructura del Card Actual
```dart
Card(
  child: Row(
    children: [
      // Container negro (foto moto) - 40% del ancho
      // Column con datos:
      // - make (titleMedium)
      // - Año: year (bodyMedium)
      // - Cilindrada: displacement ?? 'N/A'cc (bodyMedium)
      // - Potencia: powerhp (bodyMedium)
    ]
  )
)
```

### Datos Disponibles en Motorcycle Model
- `id`: int
- `make`: String
- `model`: String
- `year`: int
- `power`: int
- `torque`: int
- `type`: String
- `displacement`: int? (nullable)
- `fuelCapacity`: String
- `weight`: int
- `userId`: int

## Requerimientos

1. Reemplazar el Card único por un `ListView.builder`
2. Recorrer `motorcycleProvider.motorcycles` (lista completa)
3. Renderizar una Card por cada motocicleta
4. Mantener el mismo diseño de Card actual
5. Mostrar mensaje cuando la lista esté vacía

## Investigación de ListView.builder

### Sintaxis Básica
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Card(...);
  }
)
```

### Consideraciones
- `itemCount`: Longitud de la lista
- `itemBuilder`: Función que construye cada item
- Debe estar dentro de un scrollable (ya está en SingleChildScrollView)
- O mejor: reemplazar SingleChildScrollView con ListView.builder directamente

## Estructura Objetivo

### Opción 1: ListView.builder dentro de Column
- Mantener Column para otros elementos (PageView, Row, Título)
- ListView.builder solo para la sección de motocicletas
- Usar `shrinkWrap: true` y `physics: NeverScrollableScrollPhysics()`

### Opción 2: ListView.builder como scroll principal
- Reemplazar SingleChildScrollView con ListView.builder
- Usar diferentes tipos de items (header, motocicletas, mantenimientos)
- Más complejo pero más eficiente

## Recomendación
**Opción 1**: Mantener la estructura actual pero cambiar la sección de motocicletas a ListView.builder con shrinkWrap.

## Pasos de Implementación

1. Identificar la sección actual que muestra la motocicleta
2. Crear un widget helper para construir cada Card de motocicleta
3. Reemplazar el Card único con ListView.builder
4. Pasar el índice para acceder a `motorcycleProvider.motorcycles[index]`
5. Mantener el mensaje para lista vacía
6. Verificar que no haya errores de lint

## Notas
- El Card actual tiene un GestureDetector con onTap vacío - mantenerlo
- El diseño debe ser idéntico al actual
- Considerar separación entre cards (SizedBox o padding)

