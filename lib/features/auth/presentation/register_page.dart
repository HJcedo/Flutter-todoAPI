import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.authService});
  final AuthService authService;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pwdCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'As senhas não coincidem');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.authService.register(
        // ← adicione esse método na API se ainda não existir
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _pwdCtrl.text,
      );
      if (mounted) context.go('/login');
    } catch (_) {
      setState(() => _error = 'Falha ao criar conta');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
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
                    Text(
                      'Criar conta',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Informe seu nome'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'E‑mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Informe seu e‑mail'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pwdCtrl,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      obscureText: _obscure,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Informe sua senha'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmCtrl,
                      decoration: InputDecoration(
                        labelText: 'Confirmar senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      obscureText: _obscure,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Confirme sua senha'
                                  : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: TextStyle(color: cs.error)),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon:
                            _loading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.person_add_alt),
                        label: const Text('Registrar'),
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Já tenho conta'),
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
