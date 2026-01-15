# Investigación - Actualización de Perfil de riouario

## Contexto Actual

### Frontend (Flutter)
- **Pantalla de edición**: `moto_app/lib/features/auth/presentation/screens/profile/actions/edit_profile_screen.dart`
  - Tiene 4 campos: fullName, username, email, phoneNumber
  - Tiene un botón "Editar perfil" que habilita/deshabilita los campos (_isEditing)
  - Cuando se presiona "Guardar cambios", solo valida los campos pero no hace ninguna actualización
  - Los campos se inicializan con los valores del UserProvider

### Backend (Express.js)
- **Endpoint existente**: `/users/:id` (GET) - actualmente vacío
- **Schema de base de datos**: 
  - Tabla `users` con campos: id, full_name, email, phone_number, username, password
  - `email`, `phone_number`, `username` tienen constraint UNIQUE
- **No existe endpoint PATCH** para actualizar riorio

### Servicio HTTP (Flutter)
- **Archivo**: `moto_app/lib/features/auth/data/datasources/user_http_service.dart`
  - Tiene métodos: loginUser, logoutUser, signupUser
  - **No tiene método** para actualizar perfil

### Modelo de Usuario
- **Archivo**: `moto_app/lib/domain/models/user.dart`
  - Campos: id, fullName, email, phoneNumber, username, password
  - Tiene métodos fromJson y toJson

### UserProvider
- **Archivo**: `moto_app/lib/domain/providers/user_provider.dart`
  - Tiene método `setUser(User user)` para actualizar el usuario
  - Tiene método `clearUser()` para limpiar

## Requerimientos

1. **Al presionar "Editar perfil"**:
   - Guardar los valores actuales de los TextFields en variables temporales
   - Habilitar los campos para edición

2. **Al presionar "Guardar cambios"**:
   - Comparar los valores actuales con los valores guardados
   - Si no hay cambios: solo deshabilitar los campos (no hacer llamado HTTP)
   - Si hay cambios: llamar a función HTTP con solo los campos que cambiaron
   - Endpoint: PATCH `/users/:id`
   - Body: JSON con campos que cambiaron (nombre, username, email, cellphone)

3. **Backend - Validaciones**:
   - Si el body contiene campo `username`:
     - Verificar que no exista otro usuario con ese username (excluyendo el usuario actual)
     - Si existe, devolver error: "El nombre de usuario que elegiste ya existe"
   - Si no hay conflictos, actualizar solo los campos que vienen en el JSON
   - Los campos en la BD son: full_name, email, phone_number, username

4. **Clean Architecture**:
   - Seguir la estructura existente
   - Datasource: user_http_service.dart
   - Posiblemente necesitar repository (verificar si existe)

## Campos a Mapear

### Frontend → Backend
- `nombre` → `full_name`
- `username` → `username`
- `email` → `email`
- `cellphone` → `phone_number`

## Estructura de Archivos a Modificar/Crear

### Flutter
1. `moto_app/lib/features/auth/presentation/screens/profile/actions/edit_profile_screen.dart`
   - Agregar variables para guardar valores iniciales
   - Modificar `_toggleEditing()` para guardar valores al activar edición
   - Modificar lógica de guardado para comparar y llamar HTTP
   - Actualizar UserProvider después de actualización exitosa

2. `moto_app/lib/features/auth/data/datasources/user_http_service.dart`
   - Agregar método `updateUserProfile(int userId, Map<String, dynamic> updates)`

### Backend
1. `moto_app/backend/server.js`
   - Crear endpoint `app.patch("/users/:id", ...)`
   - Validar que el usuario existe
   - Si hay username en body, verificar que no exista otro usuario con ese username
   - Construir query UPDATE dinámico con solo los campos que vienen en el body
   - Retornar usuario actualizado o error apropiado

## Preguntas/Consideraciones

1. ¿Necesitamos actualizar el UserProvider después de actualizar el perfil?
   - Sí, para reflejar los cambios en la UI

2. ¿Necesitamos actualizar SessionService después de actualizar?
   - Probablemente sí, para mantener consistencia

3. ¿Qué hacer si el usuario cambia su username pero ya existe?
   - Mostrar mensaje de error al usuario en Flutter

4. ¿Qué hacer si hay error de red?
   - Mostrar SnackBar con mensaje de error

5. ¿Validar campos en backend también?
   - Sí, validar formato de email, longitud de username, etc.

## Mapeo de Nombres

El usuario menciona que el body debe tener: `nombre`, `username`, `email`, `cellphone`
Pero en el schema de BD son: `full_name`, `username`, `email`, `phone_number`

Necesito confirmar si el frontend debe enviar los nombres como los menciona el usuario o como están en la BD.

