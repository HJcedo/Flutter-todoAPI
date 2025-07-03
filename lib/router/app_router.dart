// Importa o Flutter
import 'package:flutter/material.dart';
// Importa telas de login e registro
import 'package:flutter_todo/features/auth/presentation/login_page.dart';
import 'package:flutter_todo/features/auth/presentation/register_page.dart';
// Importa o go_router para rotas declarativas
import 'package:go_router/go_router.dart';
// Importa dependências do core
import '../core/network/dio_client.dart';
import '../core/services/auth_service.dart';
// Importa repositório de tarefas
import '../features/tasks/data/tasks_repository.dart';
// Importa telas de tarefas
import '../features/tasks/presentation/task_detail_page.dart';
import '../features/tasks/presentation/tasks_page.dart';
// Importa a tela de perfil
import '../features/profile/presentation/profile_page.dart';

// Função que cria e configura o GoRouter
GoRouter buildRouter(DioClient dioClient, AuthService authService) {
  // Cria o repositório de tarefas com Dio
  final tasksRepo = TasksRepository(dioClient.client);

  return GoRouter(
    routes: [
      // Rota de login
      GoRoute(
        path: '/login',
        builder: (c, s) => LoginPage(authService: authService),
      ),
      // Rota de registro
      GoRoute(
        path: '/register',
        builder: (c, s) => RegisterPage(authService: authService),
      ),
      // Rota principal "/"
      GoRoute(
        path: '/',
        builder: (c, s) => Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              // Botão de logout
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () async {
                  await authService.logout();
                  if (c.mounted) c.go('/login');
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.list_alt),
                  onPressed: () => c.go('/tasks'),
                  label: const Text('Ir para Tarefas'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        // Rotas filhas da home
        routes: [
          // Rota de lista de tarefas
          GoRoute(
            path: 'tasks',
            builder: (c, s) => TasksPage(repo: tasksRepo),
          ),
          // Rota de detalhe de tarefa
          GoRoute(
            path: 'tasks/:id',
            builder: (c, s) => TaskDetailPage(
              taskId: s.pathParameters['id']!,
              task: s.extra as dynamic, // pode ser null
              repo: tasksRepo,
            ),
          ),
          // Rota de perfil
          GoRoute(
            path: 'profile',
            builder: (c, s) => ProfilePage(authService: authService),
          ),
        ],
      ),
    ],
    // Função de redirecionamento automático
    redirect: (context, state) async {
      // Busca o token salvo
      final token = await authService.tokenStorage.token;
      // Verifica se está na tela de login ou registro
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      // Se não estiver logado e tentar acessar qualquer página protegida, vai para login
      if (token == null && !loggingIn) return '/login';
      // Se estiver logado e tentar ir para login ou registro, redireciona para /tasks
      if (token != null && loggingIn) return '/tasks';
      // Caso contrário, não redireciona
      return null;
    },
  );
}
