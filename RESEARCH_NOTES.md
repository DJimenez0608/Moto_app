# Investigación - Sistema de Persistencia de Sesión

## Contexto Actual
- Backend: Express.js con PostgreSQL
- Login actual solo devuelve "usuario logueado" (texto)
- No hay sistema de tokens ni sesiones
- Flutter usa http package para requests

## Opciones de Implementación

### Opción 1: Solo Persistencia Local (SharedPreferences)
- Pros: Simple, rápido, no requiere cambios en backend de validación
- Contras: No hay validación real del servidor, fácil de manipular
- Backend: No necesita cambios para validación, solo emitir respuesta en login
- Flutter: Guarda flag "isLoggedIn" + username en SharedPreferences

### Opción 2: JWT Tokens
- Pros: Validación real del servidor, estándar de la industria
- Contras: Requiere middleware de validación en backend
- Backend: Emite JWT en login, valida en requests protegidos
- Flutter: Guarda token en SharedPreferences, envía en headers

### Opción 3: Sesiones en Base de Datos
- Pros: Control total sobre sesiones activas
- Contras: Más complejo, requiere tabla de sesiones
- Backend: Crea tabla de sesiones, guarda al login, valida en requests
- Flutter: Guarda session_id en SharedPreferences

## Archivos a Modificar

### Backend (server.js)
- Endpoint /users/login: Debe emitir token/sesión
- Endpoint /users/logout: Debe invalidar token/sesión
- Middleware de autenticación (si usa JWT/sesiones)

### Flutter
- user_http_service.dart: Manejar tokens/headers
- login_screen.dart: Guardar sesión después de login exitoso
- splash_screen.dart: Verificar sesión activa y redirigir
- home_screen.dart: Botón de logout que limpie sesión
- Nuevo archivo: session_service.dart o auth_service.dart

## Dependencias Necesarias
- Flutter: shared_preferences (para persistencia local)
- Backend (si JWT): jsonwebtoken
- Backend (si sesiones): Tabla de sesiones en PostgreSQL

## Flujo Esperado
1. Usuario hace login → Backend valida → Guarda sesión localmente
2. Usuario cierra app → Al abrir, SplashScreen verifica sesión → Redirige a HomeScreen
3. Usuario hace logout → Limpia sesión local → Redirige a InitialScreen

