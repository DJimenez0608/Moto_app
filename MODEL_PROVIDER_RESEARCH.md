# Investigación: Modelos y Providers - MotoApp

## Fecha de Investigación
Fecha: 2024

## Estructura Actual del Proyecto

### Arquitectura
- **Tipo**: Clean Architecture (Flutter)
- **Ubicación de modelos actuales**: `lib/features/auth/data/models/`
- **Patrón de modelo existente**: `user.dart` (User model)

### Modelo User Existente - Patrón Identificado
```dart
- Factory constructor fromJson(Map<String, dynamic>)
- Método toJson() que retorna Map<String, dynamic>
- Propiedades final
- Conversión snake_case (JSON) ↔ lowerCamelCase (Dart)
- Funciones helper: usersModelFromJson, usersModelToJson
```

### Estructura de Carpetas Actual
```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   └── models/ (NUEVO - todos los modelos aquí)
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/ (user.dart se moverá a core/models/)
│       │   └── services/
│       └── presentation/
│           ├── screens/
│           ├── widgets/
│           └── providers/
└── main.dart
```

## DECISIÓN DEL USUARIO
**Todos los modelos estarán en `lib/core/models/`**

### Dependencias
- `provider: ^6.1.0` - Ya instalado
- `http: ^1.1.0` - Ya instalado
- `shared_preferences: ^2.2.2` - Ya instalado

## Esquema de Base de Datos (schema.sql)

### Tablas Identificadas
1. **users** (ya existe UserModel)
   - id, full_name, email, phone_number, username, password

2. **travels**
   - id, user_id, date, initial_location, final_location, distance

3. **motorcycles**
   - id, make, model, year, power, torque, type, displacement, fuel_capacity, weight, user_id

4. **observations**
   - id, motorcycle_id, observation, created_at, updated_at

5. **maintenance**
   - id, motorcycle_id, date, description, cost

6. **technomechanical**
   - id, motorcycle_id, start_date, end_date, cost

7. **soat**
   - id, motorcycle_id, start_date, end_date, cost

## Modelos a Crear

### 1. UserModel ✅ (Ya existe)
- Ubicación: `lib/features/auth/data/models/user.dart`
- Nombre de archivo: `user.dart`
- Nombre de clase: `User`

### 2. TravelsModel (Nuevo)
- Nombre sugerido: `Travel` o `TravelModel`
- Archivo: `travel.dart` o `travels_model.dart`
- Campos: id, userId, date, initialLocation, finalLocation, distance

### 3. ObservationModel (Nuevo)
- Nombre sugerido: `Observation` o `ObservationModel`
- Archivo: `observation.dart` o `observation_model.dart`
- Campos: id, motorcycleId, observation, createdAt, updatedAt

### 4. MotorcycleModel (Nuevo)
- Nombre sugerido: `Motorcycle` o `MotorcycleModel`
- Archivo: `motorcycle.dart` o `motorcycle_model.dart`
- Campos: id, make, model, year, power, torque, type, displacement, fuelCapacity, weight, userId

### 5. MaintenanceModel (Nuevo)
- Nombre sugerido: `Maintenance` o `MaintenanceModel`
- Archivo: `maintenance.dart` o `maintenance_model.dart`
- Campos: id, motorcycleId, date, description, cost

### 6. TecnicomecanicModel (Nuevo)
- Nombre sugerido: `Technomechanical` o `TechnomechanicalModel`
- Archivo: `technomechanical.dart` o `technomechanical_model.dart`
- Nota: Usuario escribió "Tecnicomecanic" pero en DB es "technomechanical"
- Campos: id, motorcycleId, startDate, endDate, cost

### 7. SoatModel (Nuevo)
- Nombre sugerido: `Soat` o `SoatModel`
- Archivo: `soat.dart` o `soat_model.dart`
- Campos: id, motorcycleId, startDate, endDate, cost

## Providers a Crear

### Convenciones Provider
- Extender `ChangeNotifier`
- Usar `notifyListeners()` para notificar cambios
- Ubicación sugerida: `lib/features/{domain}/presentation/providers/` o `lib/core/providers/`

### Providers Necesarios
1. UserProvider (o UserStateProvider)
2. TravelsProvider (o TravelsStateProvider)
3. ObservationProvider (o ObservationStateProvider)
4. MotorcycleProvider (o MotorcycleStateProvider)
5. MaintenanceProvider (o MaintenanceStateProvider)
6. TechnomechanicalProvider (o TechnomechanicalStateProvider)
7. SoatProvider (o SoatStateProvider)

## Decisiones de Estructura Pendientes

### Preguntas para el Usuario
1. **Organización de Features**:
   - ¿Crear features separadas para cada dominio?
     - `features/motorcycles/`
     - `features/travels/`
     - `features/maintenance/`
     - etc.
   - ¿O crear una feature general como `features/motorcycle_management/`?

2. **Ubicación de Providers**:
   - ¿En cada feature: `features/{domain}/presentation/providers/`?
   - ¿O en una carpeta global: `lib/core/providers/` o `lib/providers/`?

3. **Nomenclatura de Modelos**:
   - ¿Usar `Travel` o `TravelModel`?
   - ¿Archivo `travel.dart` o `travels_model.dart`?

## Referencias
- Clean Architecture en Flutter: Separación por capas (data, domain, presentation)
- Provider Pattern: ChangeNotifier + ChangeNotifierProvider
- Convenciones de nombrado: snake_case para archivos, UpperCamelCase para clases

## Notas
- El modelo User ya existe y sigue el patrón identificado
- Todos los modelos deben seguir el mismo patrón (fromJson, toJson)
- Los providers deben estar vacíos (solo estructura) según instrucciones del usuario

