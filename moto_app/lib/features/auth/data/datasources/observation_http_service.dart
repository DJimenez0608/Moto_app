import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';

class ObservationHttpService {
  final String _baseUrl = AppConstants.apiBaseUrl;

  Future<List<Map<String, dynamic>>> getObservations(int motorcycleId) async {
    try {
      final uri = Uri.parse('$_baseUrl/motorcycle/$motorcycleId/observations');

      if (kDebugMode) {
        debugPrint('=== GET Observations Request ===');
        debugPrint('URL: $uri');
        debugPrint('Motorcycle ID: $motorcycleId');
      }

      http.Response response;
      try {
        response = await http
            .get(uri)
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                if (kDebugMode) {
                  debugPrint('Timeout: La petición tardó más de 15 segundos');
                  debugPrint('URL intentada: $uri');
                }
                throw Exception(
                  'Tiempo de espera agotado. Verifique que el servidor esté corriendo en el puerto 3000.',
                );
              },
            );
      } on SocketException catch (e) {
        if (kDebugMode) {
          debugPrint('SocketException: ${e.message}');
          debugPrint('URL intentada: $uri');
        }
        throw Exception(
          'No se pudo conectar al servidor. Verifique que el servidor esté corriendo en el puerto 3000.',
        );
      } on Exception catch (e) {
        // Re-lanzar excepciones de timeout u otras excepciones
        if (kDebugMode) {
          debugPrint('Exception durante la petición: ${e.toString()}');
        }
        rethrow;
      }

      if (kDebugMode) {
        debugPrint('Response Status: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);

          if (kDebugMode) {
            debugPrint('Decoded type: ${decoded.runtimeType}');
            if (decoded is List) {
              debugPrint('List length: ${decoded.length}');
              if (decoded.isNotEmpty) {
                debugPrint('First item: ${decoded.first}');
              }
            }
          }

          if (decoded is List) {
            final result =
                decoded.map((item) {
                  try {
                    return Map<String, dynamic>.from(item as Map);
                  } catch (e) {
                    if (kDebugMode) {
                      debugPrint('Error converting item to Map: $e');
                      debugPrint('Item: $item');
                    }
                    rethrow;
                  }
                }).toList();

            if (kDebugMode) {
              debugPrint(
                'Successfully converted ${result.length} observations',
              );
            }

            return result;
          }

          if (kDebugMode) {
            debugPrint('Response is not a List, returning empty list');
          }

          return [];
        } catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint('Error parsing JSON: $e');
            debugPrint('Stack trace: $stackTrace');
            debugPrint('Response body: ${response.body}');
          }
          throw Exception('Error al parsear la respuesta del servidor: $e');
        }
      } else if (response.statusCode == 404) {
        try {
          final responseData = jsonDecode(response.body);
          throw Exception(
            responseData['message'] ?? 'Motocicleta no encontrada',
          );
        } catch (e) {
          throw Exception('Motocicleta no encontrada');
        }
      } else if (response.statusCode == 500) {
        try {
          final responseData = jsonDecode(response.body);
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
      }
      throw Exception(
        'Error de conexión: ${e.message}. Verifique que el servidor esté corriendo.',
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Exception: ${e.toString()}');
      }
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unexpected error: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      throw Exception('Error inesperado: ${e.toString()}');
    }
  }

  Future<bool> addObservation(int motorcycleId, String observation) async {
    var uri = Uri.parse('$_baseUrl/motorcycle/$motorcycleId/observations');
    final body = {'observation': observation};
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 400) {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['message'] ?? 'Faltan datos requeridos');
    } else if (response.statusCode == 404) {
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['message'] ?? 'Motocicleta no encontrada');
    } else if (response.statusCode == 500) {
      final responseData = jsonDecode(response.body);
      throw Exception(
        responseData['message'] ?? 'Error del servidor: ${response.statusCode}',
      );
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }
}
