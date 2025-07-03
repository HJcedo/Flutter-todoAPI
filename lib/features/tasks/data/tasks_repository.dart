// Importa suporte a arquivos (File)
import 'dart:io';

// Importa o Dio
import 'package:dio/dio.dart';
// Importa MediaType para enviar o tipo correto do arquivo
import 'package:http_parser/http_parser.dart';
// Importa o modelo Task
import '../../../core/models/task_model.dart';

// Repositório que faz requisições relacionadas a tarefas
class TasksRepository {
  // Construtor recebe Dio configurado
  TasksRepository(this._client);

  // Cliente HTTP
  final Dio _client;

  // Busca todas as tarefas
  Future<List<Task>> fetchAll() async {
    final res = await _client.get('/tasks');
    // Mapeia cada item da lista JSON em um Task
    return (res.data as List).map((e) => Task.fromJson(e)).toList();
  }

  // Busca uma tarefa pelo ID
  Future<Task> fetchById(String id) async {
    final res = await _client.get('/tasks/$id');
    return Task.fromJson(res.data);
  }

  // Envia uma imagem para o servidor e retorna a URL da imagem salva
  Future<String?> uploadImage(File image) async {
    try {
      final fileName = image.path.split('/').last;

      // Verifica se o arquivo existe
      if (!await image.exists()) {
        throw Exception('Arquivo de imagem não encontrado.');
      }

      // Cria o FormData com o arquivo
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      // Faz POST no endpoint de upload
      final response = await _client.post('/tasks/upload', data: formData);

      // Se deu certo, retorna a URL
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['imageUrl'] != null) {
        return response.data['imageUrl'] as String;
      } else {
        throw Exception('Erro ao enviar imagem: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception(
        'Erro Dio ao enviar imagem: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Erro inesperado ao enviar imagem: $e');
    }
  }

  // Cria uma nova tarefa
  Future<Task> create(Task task) async {
    final data = task.toJson();

    // Remove o campo id (não deve ser enviado na criação)
    data.remove('id');

    final res = await _client.post(
      '/tasks',
      data: data,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return Task.fromJson(res.data);
  }

  // Atualiza uma tarefa existente
  Future<Task> update(Task task) async {
    final data = task.toJson();
    // Remove o id do payload (ele vai na URL)
    data.remove('id');

    final res = await _client.put(
      '/tasks/${task.id}',
      data: data,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return Task.fromJson(res.data);
  }

  // Exclui uma tarefa
  Future<void> delete(String id) async {
    await _client.delete('/tasks/$id');
  }
}
