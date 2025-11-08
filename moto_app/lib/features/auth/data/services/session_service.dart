import 'package:moto_app/domain/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'username';
  static const String _userIdKey = 'user_id';
  static const String _fullNameKey = 'full_name';
  static const String _emailKey = 'email';
  static const String _phoneNumberKey = 'phone_number';

  static Future<void> saveSession({
    required String token,
    required User user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_usernameKey, user.username);
    await prefs.setString(_userIdKey, user.id.toString());
    await prefs.setString(_fullNameKey, user.fullName);
    await prefs.setString(_emailKey, user.email);
    await prefs.setString(_phoneNumberKey, user.phoneNumber);
    await prefs.reload(); // Force reload to ensure persistence
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Ensure we have latest data
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    final hasToken = prefs.getString(_tokenKey) != null;
    // User is logged in only if both flag and token exist
    return isLoggedIn && hasToken;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  static Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final userId = prefs.getString(_userIdKey);
    final fullName = prefs.getString(_fullNameKey);
    final email = prefs.getString(_emailKey);
    final phoneNumber = prefs.getString(_phoneNumberKey);
    final username = prefs.getString(_usernameKey);

    if (userId == null ||
        fullName == null ||
        email == null ||
        phoneNumber == null ||
        username == null) {
      return null;
    }

    final parsedId = int.tryParse(userId);
    if (parsedId == null) return null;

    return User(
      id: parsedId,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      username: username,
      password: '',
    );
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneNumberKey);
  }
}
