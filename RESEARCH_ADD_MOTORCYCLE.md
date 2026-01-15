# Investigación: Agregar Motocicleta Completa

## TO-DO de Investigación

### 1. Estructura de Modelos Existentes
- [x] Revisar modelo Motorcycle - tiene: id, make, model, year, power, torque, type, displacement, fuelCapacity, weight, userId
- [x] Revisar modelo Soat - tiene: id, motorcycleId, startDate, endDate, cost
- [x] Revisar modelo Technomechanical - tiene: id, motorcycleId, startDate, endDate, cost
- [ ] Determinar qué campos son obligatorios vs opcionales en Motorcycle
- [ ] Determinar valores "fantasma" para campos vacíos

### 2. Estructura de Base de Datos
- [x] Tabla motorcycles: make, model, year, power, torque, type, displacement, fuel_capacity, weight, user_id
- [x] Tabla soat: id, motorcycle_id, start_date, end_date, cost
- [x] Tabla technomechanical: id, motorcycle_id, start_date, end_date, cost
- [ ] Verificar formato de fecha esperado (YYYY-MM-DD)

### 3. Frontend - Diálogo de Agregar Moto
- [x] Revisar estructura actual de _AddMotorcycleDialogState
- [x] TextFields actuales: make, model, year
- [x] Fechas: _soatDate, _tecnomecanicaDate
- [ ] Agregar TextField para costo SOAT
- [ ] Agregar TextField para costo Technomechanical
- [ ] Verificar que los TextFields mantengan su estado al cambiar de página

### 4. Backend - Endpoint POST /users/:id/motorcycles
- [x] Endpoint existe pero está vacío
- [ ] Implementar verificación de usuario
- [ ] Implementar inserción en tabla motorcycles
- [ ] Recuperar ID de moto insertada
- [ ] Insertar en tabla soat
- [ ] Insertar en tabla technomechanical
- [ ] Manejo de errores y respuestas

### 5. MotorcycleHttpService
- [x] Revisar estructura actual
- [ ] Crear método addMotorcycle()
- [ ] Construir body con modelos
- [ ] Manejo de errores
- [ ] Retornar mensaje de respuesta

### 6. Flujo de Usuario
- [ ] Al hacer click en "CREAR":
  - Construir modelos con datos del formulario
  - Llamar a MotorcycleHttpService.addMotorcycle()
  - Mostrar SnackBar según respuesta
  - Cerrar diálogo si es exitoso

## Preguntas Pendientes
1. ¿Qué valores usar para campos vacíos (power, torque, type, displacement, fuel_capacity, weight)?
2. ¿Todos los campos de Motorcycle son obligatorios o algunos pueden ser null?
3. ¿El formato de fecha debe ser YYYY-MM-DD para el backend?

## Notas
- UserProvider tiene el usuario logueado con su ID
- Los TextFields ya mantienen su estado (son controllers)
- El endpoint del backend está en server.js línea 237
- Los modelos ya tienen métodos toJson() implementados

