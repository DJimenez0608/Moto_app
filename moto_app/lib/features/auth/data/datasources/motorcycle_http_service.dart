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

  Future<String> deleteMotorcycle(int id) async {
    final uri = Uri.parse('$_baseUrl/motorcycles/$id');

    try {
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        return 'Motocicleta eliminada correctamente';
      } else {
        final body = response.body.isNotEmpty ? response.body : null;
        String message = 'Moto no eliminada';

        if (body != null) {
          try {
            final data = jsonDecode(body);
            if (data is Map && data['message'] is String) {
              message = data['message'] as String;
            }
          } catch (_) {
            message = body;
          }
        }

        throw Exception(message);
      }
    } catch (error) {
      throw Exception('Error eliminando la moto: $error');
    }
  }

  Future<String> addMotorcycle({
    required int userId,
    required Map<String, dynamic> motorcycleData,
    required Map<String, dynamic> soatData,
    required Map<String, dynamic> technomechanicalData,
  }) async {
    final uri = Uri.parse('$_baseUrl/users/$userId/motorcycles');

    try {
      final body = jsonEncode({
        'motorcycle': motorcycleData,
        'soat': soatData,
        'technomechanical': technomechanicalData,
      });

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map && responseData['message'] != null) {
          return responseData['message'] as String;
        }
        return 'Motocicleta registrada exitosamente';
      } else {
        final responseBody = response.body.isNotEmpty ? response.body : null;
        String errorMessage =
            'No se pudo registrar la moto, inténtelo en otro momento';

        if (responseBody != null) {
          try {
            final data = jsonDecode(responseBody);
            if (data is Map && data['message'] != null) {
              errorMessage = data['message'] as String;
            } else {
              errorMessage = responseBody;
            }
          } catch (_) {
            errorMessage = responseBody;
          }
        }

        throw Exception(errorMessage);
      }
    } catch (error) {
      if (error is Exception) {
        rethrow;
      }
      throw Exception('Error al registrar la moto: $error');
    }
  }
}
