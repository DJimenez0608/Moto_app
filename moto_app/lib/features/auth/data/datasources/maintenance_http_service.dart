import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:moto_app/core/constants/app_constants.dart';

class MaintenanceHttpService {
  final String _baseUrl = AppConstants.apiBaseUrl;

  Future<List<Map<String, dynamic>>> getMaintenance(int motorcycleId) async {
    final uri = Uri.parse('$_baseUrl/motorcycle/$motorcycleId/maintenance');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Error del servidor al obtener mantenimientos: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded == null) {
      return [];
    }

    if (decoded is List) {
      return decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    if (decoded is Map<String, dynamic>) {
      final maintenanceList = decoded['maintenanceRows'];
      if (maintenanceList is List) {
        return maintenanceList
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
    }

    throw const FormatException('Formato de datos de mantenimiento inválido');
  }
}

