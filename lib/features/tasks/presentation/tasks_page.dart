// Importa o Flutter
import 'package:flutter/material.dart';
// Importa o go_router para navegação
import 'package:go_router/go_router.dart';
// Modelo da tarefa
import '../../../core/models/task_model.dart';
// Repositório de tarefas
import '../data/tasks_repository.dart';
// Formulário de criação/edição de tarefa
import 'task_form_sheet.dart';

// Tela que lista todas as tarefas
class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.repo});

  // Repositório de tarefas injetado
  final TasksRepository repo;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  // Future que carrega as tarefas na inicialização
  late Future<List<Task>> _future;

  // Lista de tarefas exibidas
  final List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    // Carrega tarefas ao iniciar
    _future = widget.repo.fetchAll();
  }

  // Método para atualizar a lista manualmente
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
          // Enquanto carrega
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Se deu erro
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          // Se ainda não populou _tasks, preenche
          if (_tasks.isEmpty) _tasks.addAll(snapshot.data ?? []);
          // Se não tem tarefas
          if (_tasks.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa.'));
          }

          // Lista de tarefas com pull to refresh
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
                    // Título com riscado se concluída
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(task.description ?? ''),
                    // Checkbox de concluído
                    leading: Checkbox.adaptive(
                      value: task.completed,
                      onChanged: (val) async {
                        // Atualiza o status no servidor e local
                        final updated = await widget.repo.update(
                          task.copyWith(completed: val ?? false),
                        );
                        setState(() => _tasks[index] = updated);
                      },
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    // Ao clicar, abre detalhes
                    onTap: () async {
                      final updated = await context.push<Task>(
                        '/tasks/${task.id}',
                        extra: task,
                      );
                      if (updated == null) return;
                      // Se retornou uma tarefa com id vazio, foi deletada
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
      // Botão adicionar nova tarefa
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
