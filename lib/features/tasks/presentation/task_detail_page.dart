// Importa o Flutter
import 'package:flutter/material.dart';
// Importa o go_router para navegação
import 'package:go_router/go_router.dart';
// Importa o modelo Task
import '../../../core/models/task_model.dart';
// Importa o TasksRepository
import '../data/tasks_repository.dart';
// Importa o formulário de edição
import 'task_form_sheet.dart';

// Tela de detalhes da tarefa
class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({
    super.key,
    required this.taskId,
    this.task,
    required this.repo,
  });

  // ID da tarefa a carregar
  final String taskId;

  // Tarefa opcional (pode ser passada se já tiver os dados)
  final Task? task;

  // Repositório de tarefas
  final TasksRepository repo;

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  // Future que vai buscar a tarefa
  late Future<Task> _future;

  // Instância da tarefa que está sendo exibida
  late Task _task;

  @override
  void initState() {
    super.initState();
    // Se a tarefa já foi passada, usa ela direto
    if (widget.task != null) {
      _task = widget.task!;
      _future = Future.value(_task);
    } else {
      // Se não, busca do repositório
      _future = widget.repo.fetchById(widget.taskId);
    }
  }

  // Método que exclui a tarefa
  Future<void> _delete() async {
    await widget.repo.delete(_task.id!);
    if (mounted) {
      // Fecha a tela e retorna uma tarefa "vazia"
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
          // Botão de exclusão
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: FutureBuilder<Task>(
        future: _future,
        builder: (context, snapshot) {
          // Enquanto carrega, mostra spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Se deu erro, mostra mensagem
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          // Se não encontrou dados
          if (!snapshot.hasData) {
            return const Center(child: Text('Tarefa não encontrada'));
          }

          // Quando carregou, guarda a tarefa
          _task = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + checkbox de completado
                Row(
                  children: [
                    Checkbox.adaptive(
                      value: _task.completed,
                      onChanged: (val) async {
                        // Atualiza tarefa ao marcar/desmarcar
                        final updated = await widget.repo.update(
                          _task.copyWith(completed: val),
                        );
                        setState(() => _task = updated);
                        // Fecha a tela e passa a tarefa atualizada
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
                // Imagem, se existir
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
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                  ),
                // Descrição
                Text(
                  _task.description ?? '',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                // Botão de editar
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    onPressed: () async {
                      // Abre o formulário em um bottom sheet
                      final updated = await showModalBottomSheet<Task>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) =>
                            TaskFormSheet(repo: widget.repo, task: _task),
                      );
                      // Se foi editado, atualiza o estado
                      if (updated != null) {
                        setState(() => _task = updated);
                        // Fecha a tela e passa a tarefa atualizada
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
