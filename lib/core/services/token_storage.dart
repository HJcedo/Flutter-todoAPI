// Importa o pacote SharedPreferences para armazenar dados localmente no dispositivo
import 'package:shared_preferences/shared_preferences.dart';

// Classe que gerencia o armazenamento do token e credenciais de login
class TokenStorage {
  // Chave usada para salvar o token
  static const _kTokenKey = 'token';
  // Chave usada para salvar o e-mail
  static const _kEmailKey = 'email';
  // Chave usada para salvar a senha
  static const _kPasswordKey = 'password';

  // Salva o token na memória persistente
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
  }

  // Salva as credenciais (email e senha) na memória persistente
  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmailKey, email);
    await prefs.setString(_kPasswordKey, password);
  }

  // Recupera o token salvo
  Future<String?> get token async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTokenKey);
  }

  // Recupera as credenciais salvas como uma tupla (String, String)
  Future<(String, String)?> get credentials async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_kEmailKey);
    final password = prefs.getString(_kPasswordKey);
    if (email != null && password != null) return (email, password);
    return null;
  }

  // Apaga token e credenciais salvos
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kEmailKey);
    await prefs.remove(_kPasswordKey);
  }
}
