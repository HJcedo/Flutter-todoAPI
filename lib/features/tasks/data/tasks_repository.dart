import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../core/models/task_model.dart';

class TasksRepository {
  TasksRepository(this._client);
  final Dio _client;

  Future<List<Task>> fetchAll() async {
    final res = await _client.get('/tasks');
    return (res.data as List).map((e) => Task.fromJson(e)).toList();
  }

  Future<Task> fetchById(String id) async {
    final res = await _client.get('/tasks/$id');
    return Task.fromJson(res.data);
  }

  Future<String?> uploadImage(File image) async {
    try {
      final fileName = image.path.split('/').last;

      if (!await image.exists()) {
        throw Exception('Arquivo de imagem não encontrado.');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await _client.post('/tasks/upload', data: formData);

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

  Future<Task> create(Task task) async {
    final data = task.toJson();

    // Remove o campo 'id', pois ele não deve ser enviado na criação
    data.remove('id');

    final res = await _client.post(
      '/tasks',
      data: data,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return Task.fromJson(res.data);
  }

  Future<Task> update(Task task) async {
    final data = task.toJson();
    data.remove('id'); // <- Remover o ID do payload, ele está na URL

    final res = await _client.put(
      '/tasks/${task.id}',
      data: data,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return Task.fromJson(res.data);
  }

  Future<void> delete(String id) async {
    await _client.delete('/tasks/$id');
  }
}
