import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/task_model.dart';
import '../data/tasks_repository.dart';
import 'task_form_sheet.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.repo});
  final TasksRepository repo;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late Future<List<Task>> _future;
  final List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _future = widget.repo.fetchAll();
  }

  Future<void> _refresh() async {
    final data = await widget.repo.fetchAll();
    setState(() {
      _tasks
        ..clear()
        ..addAll(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas')),
      body: FutureBuilder<List<Task>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (_tasks.isEmpty) _tasks.addAll(snapshot.data ?? []);
          if (_tasks.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa.'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration:
                            task.completed ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(task.description ?? ''),
                    leading: Checkbox.adaptive(
                      value: task.completed,
                      onChanged: (val) async {
                        final updated = await widget.repo.update(
                          task.copyWith(completed: val ?? false),
                        );
                        setState(() => _tasks[index] = updated);
                      },
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final updated = await context.push<Task>(
                        '/tasks/${task.id}',
                        extra: task,
                      );
                      if (updated == null) return;
                      if (updated.id!.isEmpty) {
                        setState(() => _tasks.removeAt(index));
                      } else {
                        setState(() => _tasks[index] = updated);
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await showModalBottomSheet<Task>(
            context: context,
            isScrollControlled: true,
            builder: (_) => TaskFormSheet(repo: widget.repo),
          );
          if (newTask != null) {
            setState(() => _tasks.add(newTask));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
