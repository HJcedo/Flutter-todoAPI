// Importa o pacote Flutter
import 'package:flutter/material.dart';
// Importa o pacote go_router para navegação
import 'package:go_router/go_router.dart';
// Importa o AuthService para fazer login
import '../../../core/services/auth_service.dart';

// Widget de tela de login
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.authService});

  // Serviço de autenticação injetado
  final AuthService authService;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Chave do formulário
  final _formKey = GlobalKey<FormState>();

  // Controllers dos campos de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controle de visibilidade da senha
  bool _obscure = true;

  // Estado de loading (exibir spinner)
  bool _loading = false;

  // Mensagem de erro
  String? _error;

  // Método que faz login
  Future<void> _login() async {
    // Valida formulário
    if (!_formKey.currentState!.validate()) return;
    // Seta loading e limpa erro
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Chama o AuthService para fazer login
      await widget.authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Se a tela ainda estiver montada, navega para /tasks
      if (mounted) context.go('/tasks');
    } catch (_) {
      // Se der erro, mostra mensagem
      setState(() => _error = 'Credenciais inválidas');
    } finally {
      // Para loading
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pega a paleta de cores atual
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        // Gradiente de fundo
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primaryContainer, cs.secondaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título
                    Text(
                      'Bem‑vindo',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    // Campo E-mail
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'E‑mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe seu e‑mail' : null,
                    ),
                    const SizedBox(height: 16),
                    // Campo Senha
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      obscureText: _obscure,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe sua senha' : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(color: cs.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Botão Entrar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: const Text('Entrar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _loading ? null : _login,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Botão Criar conta
                    TextButton.icon(
                      onPressed: () => context.go('/register'),
                      icon: const Icon(Icons.person_add_alt),
                      label: const Text('Criar conta'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
