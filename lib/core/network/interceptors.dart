// Importa o pacote Dio
import 'package:dio/dio.dart';

// Importa o serviço de armazenamento do token
import '../services/token_storage.dart';

// Classe que intercepta requisições e respostas para lidar com autenticação
class AuthInterceptor extends Interceptor {
  // Construtor recebe TokenStorage
  AuthInterceptor(this._tokenStorage);

  // Instância de TokenStorage para acessar token e credenciais salvas
  final TokenStorage _tokenStorage;

  // Este método é chamado antes de cada requisição HTTP
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Recupera o token salvo localmente
    final token = await _tokenStorage.token;

    // Mostra o token no console (debug)
    print('>>> TOKEN NO INTERCEPTOR: $token');

    // Se existir um token, adiciona no cabeçalho Authorization
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Continua a requisição normalmente
    return handler.next(options);
  }

  // Este método é chamado quando ocorre um erro na requisição
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Se o erro for 401 (não autorizado)
    if (err.response?.statusCode == 401) {
      // Recupera as credenciais armazenadas (email e senha)
      final creds = await _tokenStorage.credentials;

      if (creds != null) {
        try {
          // Faz login novamente para pegar um novo token
          final response = await Dio().post(
            'http://10.0.2.2:3000/auth/login',
            data: {'email': creds.$1, 'password': creds.$2},
          );

          // Salva o novo token
          final newToken = response.data['access_token'];
          await _tokenStorage.saveToken(newToken);

          // Prepara a requisição original novamente com o novo token
          final newRequest = err.requestOptions;
          newRequest.headers['Authorization'] = 'Bearer $newToken';

          // Reenvia a requisição original
          final clone = await Dio().fetch(newRequest);

          // Retorna a resposta da requisição reexecutada
          return handler.resolve(clone);
        } catch (_) {
          // Se der erro no login, apaga o token salvo
          await _tokenStorage.clear();
        }
      }
    }

    // Se não foi 401 ou não conseguiu resolver, propaga o erro
    return handler.next(err);
  }
}
