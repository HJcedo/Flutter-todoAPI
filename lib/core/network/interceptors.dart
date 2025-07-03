import 'package:dio/dio.dart';
import '../services/token_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);
  final TokenStorage _tokenStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.token;
    print('>>> TOKEN NO INTERCEPTOR: $token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final creds = await _tokenStorage.credentials;
      if (creds != null) {
        try {
          // reautentica
          final response = await Dio().post(
            'http://10.0.2.2:3000/auth/login',
            data: {'email': creds.$1, 'password': creds.$2},
          );

          final newToken = response.data['access_token'];
          await _tokenStorage.saveToken(newToken);

          // repete a requisição original com novo token
          final newRequest = err.requestOptions;
          newRequest.headers['Authorization'] = 'Bearer $newToken';
          final clone = await Dio().fetch(newRequest);
          return handler.resolve(clone);
        } catch (_) {
          await _tokenStorage.clear();
        }
      }
    }

    return handler.next(err);
  }
}
