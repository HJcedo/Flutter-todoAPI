import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _kTokenKey = 'token';
  static const _kEmailKey = 'email';
  static const _kPasswordKey = 'password';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
  }

  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmailKey, email);
    await prefs.setString(_kPasswordKey, password);
  }

  Future<String?> get token async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTokenKey);
  }

  Future<(String, String)?> get credentials async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_kEmailKey);
    final password = prefs.getString(_kPasswordKey);
    if (email != null && password != null) return (email, password);
    return null;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kEmailKey);
    await prefs.remove(_kPasswordKey);
  }
}
