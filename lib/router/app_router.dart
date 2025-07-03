import 'package:flutter/material.dart';
import 'package:flutter_todo/features/auth/presentation/login_page.dart';
import 'package:flutter_todo/features/auth/presentation/register_page.dart';
import 'package:go_router/go_router.dart';
import '../core/network/dio_client.dart';
import '../core/services/auth_service.dart';
import '../features/tasks/data/tasks_repository.dart';
import '../features/tasks/presentation/task_detail_page.dart';
import '../features/tasks/presentation/tasks_page.dart';
import '../features/profile/presentation/profile_page.dart';

GoRouter buildRouter(DioClient dioClient, AuthService authService) {
  final tasksRepo = TasksRepository(dioClient.client);

  return GoRouter(
    routes: [
      GoRoute(
        path: '/login',
        builder: (c, s) => LoginPage(authService: authService),
      ),
      GoRoute(
        path: '/register',
        builder: (c, s) => RegisterPage(authService: authService),
      ),
      GoRoute(
        path: '/',
        builder:
            (c, s) => Scaffold(
              appBar: AppBar(
                title: const Text('Home'),
                actions: [
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

        routes: [
          GoRoute(path: 'tasks', builder: (c, s) => TasksPage(repo: tasksRepo)),
          GoRoute(
            path: 'tasks/:id',
            builder:
                (c, s) => TaskDetailPage(
                  taskId: s.pathParameters['id']!,
                  task: s.extra as dynamic, // pode ser null
                  repo: tasksRepo,
                ),
          ),
          GoRoute(
            path: 'profile',
            builder: (c, s) => ProfilePage(authService: authService),
          ),
        ],
      ),
    ],
    redirect: (context, state) async {
      final token = await authService.tokenStorage.token;
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (token == null && !loggingIn) return '/login';
      if (token != null && loggingIn) return '/tasks';
      return null;
    },
  );
}
