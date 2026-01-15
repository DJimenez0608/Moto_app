# Investigación: Consumo de API SerAPI para Noticias

## TO-DO de Investigación

### 1. API SerAPI
- [x] URL base: `https://serpapi.com/search.json?engine=google_news`
- [x] Endpoint completo: `serApiBaseUrl + "&q=motos&gl=co&hl=es"`
- [ ] Verificar si necesita API key (probablemente sí)
- [ ] Formato de respuesta JSON
- [ ] Estructura de news_results

### 2. Modelo News
- [ ] Crear clase News con ChangeNotifier
- [ ] Atributos: title, link, thumbnail_small, date
- [ ] Método fromJson para parsear respuesta
- [ ] Formato de fecha: "11/12/2024, 09:03 AM, +0200 EET" -> DateTime o String formateado

### 3. Provider de Noticias
- [x] Revisar estructura de MotorcycleProvider como referencia
- [ ] Crear NewsProvider con lista de News
- [ ] Método para cargar noticias desde SerApiHttpService
- [ ] Filtrar solo las primeras 5 (position 1-5)

### 4. SerApiHttpService
- [x] Archivo existe pero está vacío
- [ ] Implementar método getNews() que retorne List<News>
- [ ] Manejo de errores
- [ ] Parsear JSON response

### 5. Home Screen
- [x] PageView actual tiene 4 páginas
- [ ] Cambiar itemCount a 5
- [ ] Modificar itemBuilder para mostrar noticias reales
- [ ] Diseño: imagen de fondo (thumbnail_small), título abajo izquierda, fecha arriba derecha
- [ ] Agregar GestureDetector con onTap

### 6. Carga de Noticias
- [x] Cargar cuando usuario inicia sesión
- [ ] Llamar en initState de HomeScreen o después de login exitoso
- [ ] Manejar estados de carga y error

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
class News extends ChangeNotifier {
  final String title;
  final String link;
  final String thumbnailSmall;
  final String date; // o DateTime
  
  News({required this.title, required this.link, 
        required this.thumbnailSmall, required this.date});
}
```

## Respuestas Confirmadas
1. ✅ SerAPI requiere API key en variable SERAPI_KEY del archivo .env (ubicado en backend/.env, pero necesito crear uno en moto_app/)
2. ✅ La fecha debe parsearse a DateTime y formatearse para mostrar usando intl
3. ⚠️ Si hay menos de 5 noticias, mostrar las disponibles

## Notas Importantes
- El .env está en backend/.env pero Flutter necesita uno en la raíz de moto_app/
- Usar iso_date del JSON si está disponible para parsear más fácilmente
- El modelo News será una clase simple (no ChangeNotifier)
- El NewsProvider será el ChangeNotifier que maneje la lista

## Notas
- Mantener arquitectura limpia
- Seguir estructura de providers existentes
- Mantener estética de la aplicación
- Usar GestureDetector para futuras funcionalidades

