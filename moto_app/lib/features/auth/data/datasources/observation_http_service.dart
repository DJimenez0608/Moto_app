import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';

class ObservationHttpService {
  final String _baseUrl = AppConstants.apiBaseUrl;

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
