import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.authService});
  final AuthService authService;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.authService.me();
  }

  Future<void> _logout() async {
    await widget.authService.logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<User>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.email),
                  title: Text(user.email),
                ),
                const Spacer(),
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
