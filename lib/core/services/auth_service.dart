// Importa o pacote Dio (cliente HTTP)
import 'package:dio/dio.dart';

// Importa o modelo User (provavelmente classe que representa o usuário logado)
import '../models/user_model.dart';

// Importa o TokenStorage (para salvar e limpar tokens)
import 'token_storage.dart';

// Serviço de autenticação: lida com login, cadastro, logout e recuperar perfil
class AuthService {
  // Construtor recebe o Dio e o TokenStorage
  AuthService(this._client, this._tokenStorage);

  // Cliente HTTP
  final Dio _client;

  // Serviço de armazenamento do token
  final TokenStorage _tokenStorage;

  // Getter opcional para expor o tokenStorage
  TokenStorage get tokenStorage => _tokenStorage;

  // Retorna o usuário logado (endpoint /auth/me)
  Future<User> me() async {
    final res = await _client.get('/auth/me');
    return User.fromJson(res.data);
  }

  // Registra um novo usuário
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Faz POST para /auth/register com os dados
    final res = await _client.post(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );

    // Se a API retornar token, salva imediatamente (login automático após cadastro)
    final token = res.data['accessToken'] ?? res.data['access_token'];
    if (token != null) {
      await _tokenStorage.saveToken(token);
    }
  }

  // Faz login do usuário
  Future<void> login({required String email, required String password}) async {
    final res = await _client.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    // Salva o token recebido
    await _tokenStorage.saveToken(res.data['access_token']);
  }

  // Remove o token salvo (logout)
  Future<void> logout() async => _tokenStorage.clear();
}
