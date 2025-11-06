import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:moto_app/core/constants/app_constants.dart';

class MotorcycleHttpService {
  final String _baseUrl = AppConstants.apiBaseUrl;

  Future<List<Map<String, dynamic>>>? getMotorcycles(int id) async {
    var uri = Uri.parse('$_baseUrl/users/$id/motorcycles');
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // Si el backend devuelve null (cuando no hay motocicletas)
      if (responseData == null) {
        return [];
      }

      // El backend devuelve {userMotorcyclesRows: [...]}
      final Map<String, dynamic> responseMap =
          responseData as Map<String, dynamic>;
      final motorcyclesList =
          responseMap['userMotorcyclesRows'] as List<dynamic>?;

      if (motorcyclesList == null || motorcyclesList.isEmpty) {
        return [];
      }

      return motorcyclesList
          .map((e) {
            final Map<String, dynamic> item = e as Map<String, dynamic>;
            return {
              'id': item['id'],
              'make': item['make'] as String,
              'model': item['model'] as String,
              'year': item['year'],
              'power': item['power'],
              'torque': item['torque'],
              'type': item['type'] as String,
              'displacement': item['displacement'],
              'fuel_capacity': item['fuel_capacity'] as String,
              'weight': item['weight'],
              'user_id': item['user_id'],
            };
          })
          .toList()
          .cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }
}
