// Importa o Flutter
import 'package:flutter/material.dart';
// Importa o go_router para navegação
import 'package:go_router/go_router.dart';
// Importa o AuthService para obter dados do usuário e fazer logout
import '../../../core/services/auth_service.dart';
// Importa o modelo User
import '../../../core/models/user_model.dart';

// Tela de perfil do usuário
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.authService});

  // Serviço de autenticação injetado
  final AuthService authService;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Future que vai buscar o usuário logado
  late Future<User> _future;

  @override
  void initState() {
    super.initState();
    // Inicializa o Future chamando /auth/me
    _future = widget.authService.me();
  }

  // Método de logout
  Future<void> _logout() async {
    // Limpa o token
    await widget.authService.logout();
    // Navega para a tela de login
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<User>(
        future: _future,
        builder: (context, snapshot) {
          // Enquanto carrega, mostra o spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Se deu erro, exibe mensagem
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          // Quando carrega, pega o usuário
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Nome do usuário
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // E-mail do usuário
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.email),
                  title: Text(user.email),
                ),
                const Spacer(),
                // Botão de logout
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair'),
                  onPressed: _logout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
