import 'package:dio/dio.dart';
import '../constants/api_routes.dart';
import 'interceptors.dart';
import '../services/token_storage.dart';

class DioClient {
  DioClient(this._tokenStorage) {
    _dio = Dio(BaseOptions(baseUrl: ApiRoutes.baseUrl));
    _dio.interceptors.add(AuthInterceptor(_tokenStorage));
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  late final Dio _dio;
  final TokenStorage _tokenStorage;

  Dio get client => _dio;
}
