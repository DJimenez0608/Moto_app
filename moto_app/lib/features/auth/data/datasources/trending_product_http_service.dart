import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moto_app/domain/models/trending_product.dart';

class TrendingProductHttpService {
  Future<List<TrendingProduct>> getTrendingProducts() async {
    final apiKey = dotenv.env['SERAPI_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'API key de SerAPI no configurada. Verifica que el archivo .env contenga SERAPI_KEY',
      );
    }

    final url =
        'https://serpapi.com/search.json?engine=google_shopping&q=motos+colombia&api_key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final shoppingResults = jsonData['shopping_results'] as List<dynamic>?;

        if (shoppingResults == null || shoppingResults.isEmpty) {
          if (kDebugMode) {
            debugPrint(
              'SerAPI: No se encontraron productos en la respuesta',
            );
          }
          return [];
        }

        final products = shoppingResults
            .map(
              (item) => TrendingProduct.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();

        if (kDebugMode) {
          debugPrint('SerAPI: Se cargaron ${products.length} productos');
        }

        return products;
      } else {
        if (kDebugMode) {
          debugPrint(
            'SerAPI Error: Status ${response.statusCode} - ${response.body}',
          );
        }
        throw Exception(
          'Error al obtener productos: ${response.statusCode}. ${response.body}',
        );
      }
    } catch (error) {
      if (error is Exception) {
        if (kDebugMode) {
          debugPrint('SerAPI Exception: $error');
        }
        rethrow;
      }
      if (kDebugMode) {
        debugPrint('SerAPI Error desconocido: $error');
      }
      throw Exception('Error al consumir API SerAPI: $error');
    }
  }
}

