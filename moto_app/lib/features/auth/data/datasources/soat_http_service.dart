import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:moto_app/core/constants/app_constants.dart';

class SoatHttpService {
  final String _baseUrl = AppConstants.apiBaseUrl;

  Future<bool> addSoat(
    int motorcycleId,
    DateTime startDate,
    DateTime endDate,
    double cost,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/motorcycle/$motorcycleId/soat');
      final body = {
        'start_date': startDate.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
        'end_date': endDate.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
        'cost': cost,
      };

      if (kDebugMode) {
        debugPrint('=== SOAT HTTP Request ===');
        debugPrint('URL: $uri');
        debugPrint('Body: ${jsonEncode(body)}');
        debugPrint('Motorcycle ID: $motorcycleId');
      }

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              if (kDebugMode) {
                debugPrint('Timeout: La petición tardó más de 10 segundos');
                debugPrint('URL intentada: $uri');
                debugPrint('Base URL: $_baseUrl');
              }
              throw Exception(
                'Tiempo de espera agotado. Verifique que el servidor esté corriendo en el puerto 3000.',
              );
            },
          );

      if (kDebugMode) {
        debugPrint('Response Status: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
      }

      if (response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 400) {
        try {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(responseData['message'] ?? 'Faltan datos requeridos');
        } catch (e) {
          throw Exception('Faltan datos requeridos');
        }
      } else if (response.statusCode == 404) {
        try {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(
            responseData['message'] ?? 'Motocicleta no encontrada',
          );
        } catch (e) {
          throw Exception('Motocicleta no encontrada');
        }
      } else if (response.statusCode == 500) {
        try {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(
            responseData['message'] ??
                'Error del servidor: ${response.statusCode}',
          );
        } catch (e) {
          throw Exception('Error del servidor: ${response.statusCode}');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('ClientException: ${e.message}');
        debugPrint(
          'URL intentada: $_baseUrl/motorcycle/$motorcycleId/soat',
        );
      }
      throw Exception(
        'Error de conexión: ${e.message}. Verifique que el servidor esté corriendo.',
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Exception capturada: ${e.toString()}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error inesperado: ${e.toString()}');
        debugPrint('Tipo de error: ${e.runtimeType}');
      }
      throw Exception('Error inesperado: ${e.toString()}');
    }
  }
}

