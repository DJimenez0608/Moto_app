# Investigación: Agregar Mantenimiento a Motocicletas

## Estructura Actual

### Backend
- Endpoint POST `/motorcycle/:id/maintenance` existe pero está vacío (línea 248)
- Tabla `maintenance` tiene: id, motorcycle_id, date, description, cost
- El endpoint POST de observations es un buen ejemplo de manejo de errores

### Frontend
- Modelo `Maintenance` existe con todos los campos necesarios
- `MaintenanceHttpService` existe pero solo tiene método `getMaintenance()`
- Necesita agregar método `addMaintenance()`
- `add_motorcycle_screen.dart` tiene implementación de date picker para SOAT y tecnomecánica

## Requisitos

### Backend
1. Endpoint POST `/motorcycle/:id/maintenance`
   - Validar que la motocicleta exista
   - Validar que `description`, `date`, `cost` estén presentes en el body
   - Validar que `cost` sea un número válido
   - Insertar en tabla `maintenance` con: motorcycle_id, date, description, cost
   - Manejo robusto de errores
   - Retornar códigos apropiados (201 éxito, 400 error de validación, 404 moto no encontrada, 500 error servidor)

### Frontend - Capa de Datos
1. Agregar método `addMaintenance()` en `maintenance_http_service.dart`
   - Parámetros: `int motorcycleId, DateTime date, String description, double cost`
   - Hacer POST a `/motorcycle/:id/maintenance`
   - Enviar body con `date`, `description`, `cost`
   - Manejar respuestas y errores
   - Retornar bool o lanzar Exception

### Frontend - UI
1. Crear método `_showAddMaintenanceDialog()` en `motorcycle_detail_screen.dart`
   - Título: Nombre de la motocicleta (make + model)
   - TextField para descripción con hint: "Haga la descripción de lo que se le hizo a su motocicleta"
   - TextField para costo con:
     - Label: "Costo del mantenimiento"
     - Hint: "COP"
     - Solo acepta números (usar `TextInputType.number` y `FilteringTextInputFormatter`)
   - Campo de fecha similar al de SOAT/tecnomecánica:
     - Usar `showDatePicker` con `firstDate` y `lastDate` apropiados
     - Formato de fecha: DD/MM/YYYY
     - Mostrar fecha seleccionada o "Elegir una fecha"
   - Botones "Crear" y "Cancelar"
   - Validación de campos vacíos
   - Mostrar loading mientras procesa
   - Mostrar SnackBar de éxito/error

## Flujo
1. Usuario presiona "Mantenimiento" en el diálogo de opciones
2. Se abre diálogo de agregar mantenimiento
3. Usuario completa los campos y presiona "Crear"
4. Se llama a `MaintenanceHttpService.addMaintenance()`
5. Se envía POST al backend con motorcycleId, date, description, cost
6. Backend valida, inserta en BD y retorna respuesta
7. Frontend muestra mensaje de éxito/error
8. Se cierra el diálogo

