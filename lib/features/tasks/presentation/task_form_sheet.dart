import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/task_model.dart';
import '../data/tasks_repository.dart';

class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({super.key, required this.repo, this.task});
  final TasksRepository repo;
  final Task? task;

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late bool _completed;
  File? _image;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _completed = widget.task?.completed ?? false;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    String? uploadedImageUrl;

    // Só faz o upload se for nova imagem
    if (_image != null) {
      uploadedImageUrl = await widget.repo.uploadImage(_image!);
    } else if (widget.task != null && widget.task!.imageUrl != null) {
      uploadedImageUrl = widget.task!.imageUrl;
    }

    final taskToSave = Task(
      id: widget.task?.id ?? '',
      title: _title,
      description: _description,
      completed: _completed,
      imageUrl: uploadedImageUrl,
    );

    final result =
        widget.task == null
            ? await widget.repo.create(taskToSave)
            : await widget.repo.update(taskToSave);

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                widget.task == null ? 'Nova Tarefa' : 'Editar Tarefa',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator:
                    (v) => v == null || v.isEmpty ? 'Informe um título' : null,
                onSaved: (v) => _title = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                maxLines: 3,
                onSaved: (v) => _description = v ?? '',
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Tarefa Concluída'),
                value: _completed,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _completed = val);
                  }
                },
              ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Selecionar Imagem'),
              ),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Image.file(_image!, height: 150),
                )
              else if (widget.task?.imageUrl != null &&
                  widget.task!.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Image.network(
                    'http://10.0.2.2:3000${widget.task!.imageUrl}',
                    height: 150,
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _save, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
