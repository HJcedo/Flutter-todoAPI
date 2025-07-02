import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'token_storage.dart';

class AuthService {
  AuthService(this._client, this._tokenStorage);
  final Dio _client;
  final TokenStorage _tokenStorage;
  TokenStorage get tokenStorage => _tokenStorage;

  Future<User> me() async {
    final res = await _client.get('/auth/me');
    return User.fromJson(res.data);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _client.post(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );

    // Se quiser já logar o usuário após o registro:
    final token = res.data['accessToken'] ?? res.data['access_token'];
    if (token != null) {
      await _tokenStorage.saveToken(token);
    }
  }

  Future<void> login({required String email, required String password}) async {
    final res = await _client.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    await _tokenStorage.saveToken(res.data['access_token']);
  }

  Future<void> logout() async => _tokenStorage.clear();
}
