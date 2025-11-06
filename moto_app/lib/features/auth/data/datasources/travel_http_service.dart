import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:moto_app/core/constants/app_constants.dart';

class TravelHttpService {
  final String _baseUrl = AppConstants.apiBaseUrl;

  Future<Map<String, String>?> getTravels(int id) async {
    var uri = Uri.parse('$_baseUrl/users/$id/travels');
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return {
        'userid': responseData['user_id'] as String,
        'date': (responseData['date'] as DateTime).toString(),
        'initial_location': responseData['initial_location'] as String,
        'final_location': responseData['final_location'] as String,
        'distance': (responseData['distance'] as int).toString(),
        'id': (responseData['id'] as int).toString(),
      };
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }
}
