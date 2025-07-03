import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/task_model.dart';
import '../data/tasks_repository.dart';
import 'task_form_sheet.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({
    super.key,
    required this.taskId,
    this.task,
    required this.repo,
  });
  final String taskId;
  final Task? task;
  final TasksRepository repo;

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Future<Task> _future;
  late Task _task;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _task = widget.task!;
      _future = Future.value(_task);
    } else {
      _future = widget.repo.fetchById(widget.taskId);
    }
  }

  Future<void> _delete() async {
    await widget.repo.delete(_task.id!);
    if (mounted) {
      context.pop(
        Task(
          id: '',
          title: '',
          description: '',
          completed: false,
          imageUrl: '',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: FutureBuilder<Task>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Tarefa não encontrada'));
          }

          _task = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox.adaptive(
                      value: _task.completed,
                      onChanged: (val) async {
                        final updated = await widget.repo.update(
                          _task.copyWith(completed: val),
                        );
                        setState(() => _task = updated);
                        context.pop(updated);
                      },
                    ),
                    Expanded(
                      child: Text(
                        _task.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                if (_task.imageUrl != null && _task.imageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'http://10.0.2.2:3000${_task.imageUrl!}',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                  ),
                Text(
                  _task.description ?? '',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    onPressed: () async {
                      final updated = await showModalBottomSheet<Task>(
                        context: context,
                        isScrollControlled: true,
                        builder:
                            (_) =>
                                TaskFormSheet(repo: widget.repo, task: _task),
                      );
                      if (updated != null) {
                        setState(() => _task = updated);
                        context.pop(updated);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
