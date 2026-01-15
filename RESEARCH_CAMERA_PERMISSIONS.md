# Investigación: Permisos de Cámara y Toma de Fotos

## TO-DO de Investigación

### 1. Permisos de Cámara en Android
- [x] Verificar AndroidManifest actual - NO tiene permisos de cámara
- [ ] Investigar permisos necesarios para Android (CAMERA, WRITE_EXTERNAL_STORAGE, READ_EXTERNAL_STORAGE)
- [ ] Verificar si Android 13+ requiere permisos diferentes
- [ ] Revisar documentación de permission_handler para permisos de cámara

### 2. Paquetes Flutter para Cámara
- [x] Verificar pubspec.yaml - Tiene permission_handler: ^12.0.1
- [ ] Investigar image_picker vs camera package
- [ ] Decidir qué paquete usar (image_picker es más simple para este caso)
- [ ] Verificar versión compatible con Flutter SDK ^3.7.2

### 3. Manejo de Estados de Permisos
- [ ] Investigar PermissionStatus enum (granted, denied, permanentlyDenied, etc.)
- [ ] Cómo detectar si es primera vez que se solicita
- [ ] Cómo detectar si está permanentemente denegado
- [ ] Cómo abrir configuración de la app desde Flutter

### 4. Implementación de UI
- [x] Revisar estructura actual de _buildPhotoStep
- [ ] Cómo mostrar imagen tomada (File, Uint8List, Image widget)
- [ ] Dónde almacenar temporalmente la imagen (estado del widget)
- [ ] Cómo mostrar mensaje de error en rojo debajo de los botones

### 5. Flujo de Usuario
- [ ] Primera solicitud: mostrar mensaje explicativo si deniega
- [ ] Segunda solicitud: si deniega nuevamente, mostrar texto en rojo
- [ ] Si permite: abrir cámara y tomar foto
- [ ] Mostrar foto 100x100 encima del row de botones

## Notas de Investigación

### Permisos Android necesarios:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<!-- Para Android 12 y anteriores -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
```

### Paquete image_picker:
- Versión recomendada: ^1.0.0 o superior
- Soporta cámara y galería
- Retorna File o XFile
- Maneja permisos automáticamente pero podemos controlarlos con permission_handler

### PermissionHandler:
- Permission.camera para cámara
- request() retorna PermissionStatus
- PermissionStatus.denied: primera vez denegado
- PermissionStatus.permanentlyDenied: denegado permanentemente
- openAppSettings() para abrir configuración

### Flujo de permisos:
1. Verificar estado actual con checkPermissionStatus()
2. Si denied: solicitar con request()
3. Si denied nuevamente: mostrar mensaje
4. Si permanentlyDenied: mostrar texto rojo y opción de ir a configuraciones
5. Si granted: abrir cámara

## Referencias
- permission_handler: https://pub.dev/packages/permission_handler
- image_picker: https://pub.dev/packages/image_picker
- Android Permissions: https://developer.android.com/training/permissions/requesting

