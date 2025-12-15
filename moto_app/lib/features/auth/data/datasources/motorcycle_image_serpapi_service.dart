import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MotorcycleImageSerpapiService {
  Future<String?> getMotorcycleImageUrl(String make, String model, int year) async {
    final apiKey = dotenv.env['SERAPI_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      if (kDebugMode) {
        debugPrint('API key de SerAPI no configurada');
      }
      return null;
    }

    // Construir query: marca+modelo+año (ej: ktmduke2002024)
    final query = '${make.toLowerCase()}${model.toLowerCase()}$year';
    final url = 'https://serpapi.com/search.json?engine=google_images_light&q=$query&api_key=$apiKey';

    try {
      if (kDebugMode) {
        debugPrint('Buscando imagen de moto en SerpAPI: $query');
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final imagesResults = jsonData['images_results'] as List<dynamic>?;

        if (imagesResults != null && imagesResults.isNotEmpty) {
          // Tomar el primer resultado
          final firstResult = imagesResults[0] as Map<String, dynamic>;
          final imageUrl = firstResult['original'] as String?;

          if (imageUrl != null && imageUrl.isNotEmpty) {
            if (kDebugMode) {
              debugPrint('Imagen encontrada en SerpAPI: $imageUrl');
            }
            return imageUrl;
          } else {
            if (kDebugMode) {
              debugPrint('No se encontró URL original en el primer resultado');
            }
          }
        } else {
          if (kDebugMode) {
            debugPrint('No se encontraron imágenes en SerpAPI para: $query');
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint('Error en SerpAPI: Status ${response.statusCode} - ${response.body}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Error al obtener imagen de SerpAPI: $error');
      }
    }

    return null;
  }
}

