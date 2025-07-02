import 'package:json_annotation/json_annotation.dart';
part 'task_model.g.dart';

@JsonSerializable(includeIfNull: false)
class Task {
  @JsonKey(includeIfNull: false)
  final String? id; // <- Torna `id` opcional, útil na criação

  final String title;

  @JsonKey(defaultValue: '') // <- Evita null em leitura
  final String? description;

  final bool completed;

  @JsonKey(name: 'imageUrl', includeIfNull: false, defaultValue: '')
  final String? imageUrl;

  const Task({
    this.id, // <- Agora pode ser omitido na criação
    required this.title,
    this.description,
    required this.completed,
    this.imageUrl,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);

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

  @override
  String toString() => 'Task($title)';
}
