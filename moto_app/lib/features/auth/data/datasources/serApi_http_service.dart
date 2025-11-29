import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moto_app/core/constants/app_constants.dart';
import 'package:moto_app/domain/models/news.dart';

class SerApiHttpService {
  Future<List<News>> getNews() async {
    final apiKey = dotenv.env['SERAPI_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key de SerAPI no configurada');
    }

    final url =
        '${AppConstants.serApiBaseUrl}&q=motos&gl=co&hl=es&api_key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final newsResults = jsonData['news_results'] as List<dynamic>?;

        if (newsResults == null || newsResults.isEmpty) {
          return [];
        }

        // Filtrar solo las noticias con position 1-5
        final filteredNews =
            newsResults
                .where((item) {
                  final position = item['position'] as int?;
                  return position != null && position >= 1 && position <= 5;
                })
                .take(5)
                .map((item) => News.fromJson(item as Map<String, dynamic>))
                .toList();

        return filteredNews;
      } else {
        throw Exception('Error al obtener noticias: ${response.statusCode}');
      }
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }
      throw Exception('Error al consumir API SerAPI: $error');
    }
  }
}
