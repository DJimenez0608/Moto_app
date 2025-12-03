import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';

class UserHttpService {
  final String _baseUrl = '${AppConstants.apiBaseUrl}/users';

  Future<Map<String, String>?> loginUser(
    String username,
    String password,
  ) async {
    var uri = Uri.parse('$_baseUrl/login');
    final body = {'username': username, 'password': password};
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return {
        'token': responseData['token'] as String,
        'username': responseData['username'] as String,
        "fullName": responseData['fullName'] as String,
        "email": responseData['email'] as String,
        "phoneNumber": responseData['phoneNumber'] as String,
        "id": (responseData['id'] as int).toString(),
      };
    } else if (response.statusCode == 401) {
      return null;
    } else if (response.statusCode == 400) {
      throw Exception('Faltan datos: ${response.body}');
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  Future<bool> logoutUser() async {
    var uri = Uri.parse('$_baseUrl/logout');
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> signupUser(
    String fullName,
    String email,
    String phoneNumber,
    String username,
    String password,
  ) async {
    var uri = Uri.parse(_baseUrl);
    final body = {
      'fullname': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'username': username,
      'password': password,
    };
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      throw Exception('Faltan datos: ${response.body}');
    } else if (response.statusCode == 409) {
      throw Exception('Usuario ya existente: ${response.body}');
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }

  Future<bool> updateUserProfile(
    int userId,
    Map<String, dynamic> updates,
  ) async {
    var uri = Uri.parse('$_baseUrl/$userId');
    var response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );
    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      try {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? response.body;
        throw Exception(message);
      } catch (e) {
        throw Exception(response.body);
      }
    } else if (response.statusCode == 409) {
      try {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? response.body;
        throw Exception(message);
      } catch (e) {
        throw Exception(response.body);
      }
    } else if (response.statusCode == 404) {
      try {
        final responseData = jsonDecode(response.body);
        final message = responseData['message'] ?? 'Usuario no encontrado';
        throw Exception(message);
      } catch (e) {
        throw Exception('Usuario no encontrado');
      }
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  }
}
