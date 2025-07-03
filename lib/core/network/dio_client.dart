// Importa o pacote Dio, cliente HTTP poderoso
import 'package:dio/dio.dart';

// Importa as rotas base da API (provavelmente a URL do servidor)
import '../constants/api_routes.dart';

// Importa os interceptadores (por exemplo, para adicionar token nos headers)
import 'interceptors.dart';

// Importa o serviço de armazenamento do token
import '../services/token_storage.dart';

// Classe DioClient responsável por configurar o cliente HTTP
class DioClient {
  // Construtor recebe uma instância de TokenStorage
  DioClient(this._tokenStorage) {
    // Inicializa o Dio com a baseUrl da API
    _dio = Dio(BaseOptions(baseUrl: ApiRoutes.baseUrl));

    // Adiciona o interceptor que insere o token nas requisições
    _dio.interceptors.add(AuthInterceptor(_tokenStorage));

    // Adiciona o interceptor que faz log de requisições e respostas
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  // O Dio que será usado para fazer requisições
  late final Dio _dio;

  // Armazena o TokenStorage recebido no construtor
  final TokenStorage _tokenStorage;

  // Getter para acessar o Dio configurado
  Dio get client => _dio;
}
