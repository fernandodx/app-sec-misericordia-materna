import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/utils/formatters.dart';
import '../../signals/auth_signal.dart';
import '../../widgets/theme_selector_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authSignal.registerWithEmail(
      _emailController.text,
      _passwordController.text,
      nome: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      final invite = authSignal.activeInvite.value;
      final current = authSignal.currentUser.value;

      if (invite != null && current != null) {
        final updated = current.copyWith(
          role: invite.targetRole,
          tipoVida: invite.tipoVida,
          localidade: invite.localidade ?? current.localidade,
        );
        await sl.userRepository.updateUser(updated);
        authSignal.refreshUser(updated);
        try {
          await sl.inviteRepository.acceptInvite(invite.id, current.id);
        } catch (_) {}
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            invite != null
                ? 'Cadastro realizado com sucesso! Convite vinculado. Bem-vindo(a)!'
                : 'Cadastro realizado com sucesso! Bem-vindo(a) à fraternidade!',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );

      context.go(AppRoutes.memberForm);
      return;
    }

    if (authSignal.errorMessage.value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authSignal.errorMessage.value!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleGoogleRegister() async {
    final success = await authSignal.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      final invite = authSignal.activeInvite.value;
      final current = authSignal.currentUser.value;

      if (invite != null && current != null) {
        final updated = current.copyWith(
          role: invite.targetRole,
          tipoVida: invite.tipoVida,
          localidade: invite.localidade ?? current.localidade,
        );
        await sl.userRepository.updateUser(updated);
        authSignal.refreshUser(updated);
        try {
          await sl.inviteRepository.acceptInvite(invite.id, current.id);
        } catch (_) {}
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            invite != null
                ? 'Conta vinculada com sucesso ao convite! Bem-vindo(a)!'
                : 'Login realizado com sucesso! Bem-vindo(a) à fraternidade!',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );

      context.go(AppRoutes.memberForm);
      return;
    }

    if (authSignal.errorMessage.value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authSignal.errorMessage.value!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SignalBuilder(
      builder: (context) {
        final isLoading = authSignal.isLoading.value;
        final invite = authSignal.activeInvite.value;

        return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: const [
          ThemeSelectorButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/img/logo_fraternidade.png',
                        height: 75,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Junte-se à Fraternidade',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crie sua conta para preencher sua ficha de membro e acessar a secretaria.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Notificação de Convite Ativo
                    if (invite != null) ...[
                      Card(
                        color: colorScheme.surfaceContainerHigh,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                radius: 20,
                                child: const Icon(Icons.mail_outline_rounded, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Convite Vinculado!',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      'Perfil: ${invite.targetRole.label}${invite.localidade != null ? " • ${invite.localidade}" : ""}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Campo Nome Completo
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Nome Completo',
                        hintText: 'Seu nome e sobrenome',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe seu nome completo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo E-mail
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'seuemail@exemplo.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe seu e-mail';
                        }
                        if (!AppFormatters.isValidEmail(value)) {
                          return 'Informe um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Senha
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        helperText: 'Mínimo de 6 caracteres',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Confirmar Senha
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
                        prefixIcon: const Icon(Icons.lock_reset),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botão Cadastrar
                    FilledButton(
                      onPressed: isLoading ? null : _handleRegister,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Cadastrar',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Divisor OU
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OU',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Botão Google
                    OutlinedButton.icon(
                      onPressed: isLoading ? null : _handleGoogleRegister,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: const Text('Cadastrar com Google'),
                    ),
                    const SizedBox(height: 16),

                    // Voltar ao Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Já possui conta?', style: theme.textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('Fazer Login'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  },
);
}
}
