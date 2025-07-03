// Importa suporte a arquivos
import 'dart:io';

// Flutter
import 'package:flutter/material.dart';
// ImagePicker para selecionar imagens
import 'package:image_picker/image_picker.dart';
// Modelo da tarefa
import '../../../core/models/task_model.dart';
// Repositório de tarefas
import '../data/tasks_repository.dart';

// Widget que exibe o formulário para criar ou editar tarefa
class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({super.key, required this.repo, this.task});

  // Repositório injetado
  final TasksRepository repo;

  // Tarefa opcional (se for edição)
  final Task? task;

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  // Chave do formulário
  final _formKey = GlobalKey<FormState>();

  // Campos do formulário
  late String _title;
  late String _description;
  late bool _completed;
  File? _image;

  @override
  void initState() {
    super.initState();
    // Se for edição, inicializa campos com os dados da tarefa
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _completed = widget.task?.completed ?? false;
  }

  // Método que abre o seletor de imagem
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  // Método que salva a tarefa
  Future<void> _save() async {
    // Valida o formulário
    if (!_formKey.currentState!.validate()) return;
    // Salva os campos
    _formKey.currentState!.save();

    String? uploadedImageUrl;

    // Se tiver uma nova imagem, faz upload
    if (_image != null) {
      uploadedImageUrl = await widget.repo.uploadImage(_image!);
    }
    // Se não tem nova imagem mas é edição, usa a antiga
    else if (widget.task != null && widget.task!.imageUrl != null) {
      uploadedImageUrl = widget.task!.imageUrl;
    }

    // Cria objeto Task para salvar
    final taskToSave = Task(
      id: widget.task?.id ?? '',
      title: _title,
      description: _description,
      completed: _completed,
      imageUrl: uploadedImageUrl,
    );

    // Chama criar ou atualizar
    final result = widget.task == null
        ? await widget.repo.create(taskToSave)
        : await widget.repo.update(taskToSave);

    // Fecha o formulário retornando a tarefa salva
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    // Espaço para teclado
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
              // Título do formulário
              Text(
                widget.task == null ? 'Nova Tarefa' : 'Editar Tarefa',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              // Campo título
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe um título' : null,
                onSaved: (v) => _title = v!,
              ),
              const SizedBox(height: 12),
              // Campo descrição
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
              // Checkbox tarefa concluída
              CheckboxListTile(
                title: const Text('Tarefa Concluída'),
                value: _completed,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _completed = val);
                  }
                },
              ),
              // Botão selecionar imagem
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Selecionar Imagem'),
              ),
              // Exibe imagem nova escolhida
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Image.file(_image!, height: 150),
                )
              // Exibe imagem existente da tarefa
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
              // Botão salvar
              ElevatedButton(
                onPressed: _save,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
