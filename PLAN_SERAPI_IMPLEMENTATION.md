# Plan de Implementación: Consumo de API SerAPI para Noticias

## Objetivo
Implementar el consumo de la API SerAPI para obtener noticias sobre motos y mostrarlas en un PageView en la pantalla home, siguiendo arquitectura limpia.

## Archivos a Modificar/Crear

1. **pubspec.yaml**: Agregar dependencias flutter_dotenv e intl
2. **.env**: Crear archivo con SERAPI_KEY
3. **app_constants.dart**: Agregar método para obtener API key
4. **news.dart** (nuevo): Crear modelo News
5. **news_provider.dart** (nuevo): Crear provider para noticias
6. **serApi_http_service.dart**: Implementar método getNews()
7. **main.dart**: Agregar NewsProvider y cargar .env
8. **home_screen.dart**: Modificar PageView para mostrar noticias reales

## Pasos de Implementación

### 1. Configuración de Dependencias

#### 1.1. Agregar dependencias a pubspec.yaml
- `flutter_dotenv: ^5.1.0`
- `intl: ^0.19.0`

#### 1.2. Configurar assets en pubspec.yaml
- Agregar `.env` a la sección de assets

#### 1.3. Crear archivo .env
- Crear archivo `.env` en la raíz del proyecto moto_app
- Agregar: `SERAPI_KEY=tu_api_key_aqui`

### 2. Crear Modelo News

#### 2.1. Crear archivo `lib/domain/models/news.dart`
- Clase News con atributos: title, link, thumbnailSmall, date (DateTime)
- Método fromJson para parsear respuesta de API
- Método para formatear fecha usando intl

### 3. Crear NewsProvider

#### 3.1. Crear archivo `lib/domain/providers/news_provider.dart`
- Extender ChangeNotifier
- Lista privada de News
- Getter público para la lista
- Método loadNews() que llama a SerApiHttpService
- Filtrar solo las primeras 5 noticias (position 1-5)
- Manejo de estados de carga y error

### 4. Implementar SerApiHttpService

#### 4.1. Agregar imports necesarios
- `dart:convert`
- `package:http/http.dart`
- `package:flutter_dotenv/flutter_dotenv.dart`
- `package:moto_app/core/constants/app_constants.dart`
- `package:moto_app/domain/models/news.dart`

#### 4.2. Implementar método getNews()
- Construir URL completa: `serApiBaseUrl + "&q=motos&gl=co&hl=es&api_key=${dotenv.env['SERAPI_KEY']}"`
- Hacer petición GET
- Parsear JSON response
- Extraer news_results
- Filtrar por position 1-5
- Convertir a List<News>
- Manejo de errores

### 5. Modificar AppConstants

#### 5.1. Agregar método para obtener API key
- Método estático que lea de dotenv
- Retornar string vacío si no existe

### 6. Modificar main.dart

#### 6.1. Cargar .env al inicio
- `await dotenv.load(fileName: ".env");` en main() antes de runApp()

#### 6.2. Agregar NewsProvider
- Agregar ChangeNotifierProvider para NewsProvider en MultiProvider

### 7. Modificar HomeScreen

#### 7.1. Cargar noticias en initState
- Llamar a newsProvider.loadNews() después de _loadMotorcycles()

#### 7.2. Modificar PageView
- Cambiar itemCount de 4 a 5 (o usar newsProvider.news.length)
- Modificar itemBuilder para mostrar noticias reales
- Diseño:
  - Container con imagen de fondo (thumbnail_small) usando DecorationImage
  - Título en la parte inferior izquierda con padding
  - Fecha en la parte superior derecha con padding
  - GestureDetector con onTap (por ahora vacío para uso futuro)
- Usar AnimatedPage con FadeEffect
- Manejar caso cuando no hay noticias (mostrar placeholder)

### 8. Formateo de Fecha

#### 8.1. Parsear fecha de API
- Formato: "11/12/2024, 09:03 AM, +0200 EET"
- Usar DateTime.parse() o crear parser personalizado
- Guardar como DateTime en el modelo

#### 8.2. Formatear para mostrar
- Usar DateFormat de intl
- Formato: "dd/MM/yyyy" o similar
- Crear método en News para formatear fecha

## Estructura de Datos

### Respuesta JSON de SerAPI
```json
{
  "news_results": [{
    "position": 1,
    "title": "...",
    "link": "...",
    "thumbnail_small": "...",
    "date": "11/12/2024, 09:03 AM, +0200 EET"
  }]
}
```

### Modelo News
```dart
class News {
  final String title;
  final String link;
  final String thumbnailSmall;
  final DateTime date;
  
  String get formattedDate => DateFormat('dd/MM/yyyy').format(date);
}
```

## Detalles de Implementación

### URL Completa de SerAPI
```
https://serpapi.com/search.json?engine=google_news&q=motos&gl=co&hl=es&api_key=${SERAPI_KEY}
```

### Parseo de Fecha
- El formato "11/12/2024, 09:03 AM, +0200 EET" puede necesitar parsing personalizado
- Alternativa: usar iso_date si está disponible en la respuesta
- Si no, crear función helper para parsear el formato

### Diseño del Card de Noticia
- Container con BoxDecoration
- DecorationImage con thumbnail_small
- Stack para superponer texto sobre imagen
- Gradiente oscuro en la parte inferior para legibilidad del título
- Padding y estilos consistentes con la app

## Verificaciones Post-Implementación
- Verificar que no haya errores de lint
- Probar carga de noticias al iniciar sesión
- Verificar que se muestren solo 5 noticias
- Verificar formato de fecha
- Verificar diseño responsive
- Verificar manejo de errores (sin API key, sin conexión, etc.)

