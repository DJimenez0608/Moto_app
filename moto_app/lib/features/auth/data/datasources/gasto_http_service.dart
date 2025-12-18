import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:moto_app/core/constants/app_constants.dart';

class GastoHttpService {
  final String _baseUrl = AppConstants.apiBaseUrl;

  Future<Map<String, dynamic>> getGastosTotales(int userId) async {
    try {
      final uri = Uri.parse('$_baseUrl/users/$userId/gastos');
      
      if (kDebugMode) {
        debugPrint('=== Gasto HTTP Request ===');
        debugPrint('URL: $uri');
        debugPrint('User ID: $userId');
      }

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('Timeout: La petición tardó más de 10 segundos');
            debugPrint('URL intentada: $uri');
          }
          throw Exception(
            'Tiempo de espera agotado. Verifique que el servidor esté corriendo.',
          );
        },
      );

      if (kDebugMode) {
        debugPrint('Response Status: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded;
      } else if (response.statusCode == 400) {
        try {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(
            responseData['message'] ?? 'El usuario no tiene motos registradas',
          );
        } catch (e) {
          throw Exception('El usuario no tiene motos registradas');
        }
      } else if (response.statusCode == 404) {
        try {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(
            responseData['message'] ?? 'Usuario no encontrado',
          );
        } catch (e) {
          throw Exception('Usuario no encontrado');
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
        debugPrint('URL intentada: $_baseUrl/users/$userId/gastos');
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

