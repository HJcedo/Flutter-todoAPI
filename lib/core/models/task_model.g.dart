// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  id: json['id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  completed: json['completed'] as bool,
  imageUrl: json['imageUrl'] as String? ?? '',
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  if (instance.id case final value?) 'id': value,
  'title': instance.title,
  if (instance.description case final value?) 'description': value,
  'completed': instance.completed,
  if (instance.imageUrl case final value?) 'imageUrl': value,
};
