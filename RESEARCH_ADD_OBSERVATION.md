# Investigación: Agregar Observaciones a Motocicletas

## Estructura Actual

### Backend
- Endpoint POST `/motorcycle/:id/observations` existe pero está vacío (línea 252)
- Tabla `observations` tiene: id, motorcycle_id, observation, created_at, updated_at
- El endpoint POST de motorcycles (`/users/:id/motorcycles`) es un buen ejemplo de manejo de errores

### Frontend
- Modelo `Observation` existe con todos los campos necesarios
- No existe `observation_http_service.dart`
- `MotorcycleDetailScreen` ya tiene el botón "Agregar observación" en el FAB expandible
- El screen tiene acceso a `motorcycleId` y puede obtener el objeto `Motorcycle` completo

## Requisitos

### Backend
1. Endpoint POST `/motorcycle/:id/observations`
   - Validar que la motocicleta exista
   - Validar que `observation` esté presente en el body
   - Insertar en tabla `observations` con: motorcycle_id, observation, created_at, updated_at
   - Manejo robusto de errores
   - Retornar códigos apropiados (201 éxito, 400 error de validación, 404 moto no encontrada, 500 error servidor)

### Frontend - Capa de Datos
1. Crear `observation_http_service.dart` en `lib/features/auth/data/datasources/`
   - Método `addObservation(int motorcycleId, String observation)`
   - Hacer POST a `/motorcycle/:id/observations`
   - Enviar body con `observation`
   - Manejar respuestas y errores
   - Retornar bool o lanzar Exception

### Frontend - UI
1. Crear diálogo en `motorcycle_detail_screen.dart`
   - Título: Nombre de la motocicleta (make + model)
   - TextField con hint: "anote su observación aca para luego indicarle a su mecánico"
   - Botón "Crear" que llama al servicio HTTP
   - Botón "Cancelar" que hace Navigator.pop()
   - Mostrar loading mientras se procesa
   - Mostrar SnackBar de éxito/error

## Flujo
1. Usuario presiona "Agregar observación" en el FAB
2. Se abre diálogo con TextField
3. Usuario escribe observación y presiona "Crear"
4. Se llama a `ObservationHttpService.addObservation()`
5. Se envía POST al backend con motorcycleId y observation
6. Backend valida, inserta en BD y retorna respuesta
7. Frontend muestra mensaje de éxito/error
8. Se cierra el diálogo

