# Plan de Implementación: Consumo de API SerAPI

## TODOs de Implementación

1. **Agregar dependencias**: flutter_dotenv e intl a pubspec.yaml
2. **Configurar .env**: Crear archivo .env con SERAPI_KEY y agregarlo a assets
3. **Crear modelo News**: Crear lib/domain/models/news.dart con atributos y métodos
4. **Crear NewsProvider**: Crear lib/domain/providers/news_provider.dart
5. **Implementar SerApiHttpService**: Método getNews() con manejo de errores
6. **Modificar AppConstants**: Agregar método para obtener API key
7. **Modificar main.dart**: Cargar .env y agregar NewsProvider
8. **Modificar HomeScreen**: Cargar noticias y actualizar PageView con diseño
9. **Verificar lint**: Asegurar que no haya errores

