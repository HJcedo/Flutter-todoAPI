// Importa o pacote que permite usar as anotações de serialização JSON
import 'package:json_annotation/json_annotation.dart';

// Faz referência ao arquivo gerado automaticamente (task_model.g.dart)
part 'task_model.g.dart';

// Classe Task que representa uma tarefa
// A anotação diz que ela será serializável para JSON
@JsonSerializable(includeIfNull: false)
class Task {
  // Campo id opcional (pode ser nulo), útil quando criamos uma nova tarefa que ainda não tem ID
  @JsonKey(includeIfNull: false)
  final String? id;

  // Campo obrigatório com o título da tarefa
  final String title;

  // Campo opcional descrição, se for nulo, ao serializar vai ter string vazia
  @JsonKey(defaultValue: '')
  final String? description;

  // Campo obrigatório que indica se a tarefa foi concluída
  final bool completed;

  // Campo opcional com a URL da imagem
  // Será chamado "imageUrl" no JSON
  @JsonKey(name: 'imageUrl', includeIfNull: false, defaultValue: '')
  final String? imageUrl;

  // Construtor da classe
  const Task({
    this.id,
    required this.title,
    this.description,
    required this.completed,
    this.imageUrl,
  });

  // Factory que cria um Task a partir de um Map (JSON)
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  // Método que converte o Task em Map (JSON)
  Map<String, dynamic> toJson() => _$TaskToJson(this);

  // Método copyWith para criar uma cópia da tarefa com campos modificados
  Task copyWith({
    String? title,
    String? description,
    bool? completed,
    String? imageUrl,
  }) => Task(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        completed: completed ?? this.completed,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  // Retorna uma representação em string
  @override
  String toString() => 'Task($title)';
}
