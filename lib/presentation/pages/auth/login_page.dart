import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/utils/formatters.dart';
import '../../signals/auth_signal.dart';
import '../../widgets/theme_selector_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkAndBindInvite() async {
    final invite = authSignal.activeInvite.value;
    final current = authSignal.currentUser.value;
    if (invite != null && current != null && current.role.isVisitante) {
      try {
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
      } catch (_) {}
    }
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await authSignal.signInWithEmail(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      await _checkAndBindInvite();
      if (!mounted) return;
      final user = authSignal.currentUser.value;
      if (user != null && (!user.isProfileComplete || authSignal.activeInvite.value != null)) {
        context.go(AppRoutes.memberForm);
      } else {
        context.go(AppRoutes.dashboard);
      }
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

  Future<void> _handleGoogleLogin() async {
    final success = await authSignal.signInWithGoogle();
    if (!mounted) return;
    if (success) {
      await _checkAndBindInvite();
      if (!mounted) return;
      final user = authSignal.currentUser.value;
      if (user != null && (!user.isProfileComplete || authSignal.activeInvite.value != null)) {
        context.go(AppRoutes.memberForm);
      } else {
        context.go(AppRoutes.dashboard);
      }
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

  void _showPasswordResetDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Redefinir Senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informe seu e-mail para receber as instruções de redefinição de senha:'),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail cadastrado',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isNotEmpty) {
                try {
                  await sl.authRepository.sendPasswordReset(email);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('E-mail de recuperação enviado! Verifique sua caixa de entrada.'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao enviar e-mail de recuperação: $e'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Enviar Instruções'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SignalBuilder(
      builder: (context) {
        final invite = authSignal.activeInvite.value;
        final isLoading = authSignal.isLoading.value;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: const [
              ThemeSelectorButton(),
              SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 850;

                    if (isDesktop) {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 680),
                        child: Card(
                          elevation: 2,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(color: colorScheme.outlineVariant),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Lado Esquerdo: Banner Vertical da Fraternidade
                              Expanded(
                                flex: 5,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(
                                      'assets/img/banner_vertical.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, error, stackTrace) => Container(
                                        color: colorScheme.surfaceContainerHighest,
                                        child: Center(
                                          child: Icon(Icons.church_rounded, size: 80, color: colorScheme.onSurfaceVariant),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withValues(alpha: 0.1),
                                            Colors.black.withValues(alpha: 0.75),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 32,
                                      left: 24,
                                      right: 24,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Fraternidade Misericórdia Materna',
                                            style: theme.textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Consagrados ao Amor e à Misericórdia de Deus',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: Colors.white.withValues(alpha: 0.85),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Lado Direito: Formulário de Login
                              Expanded(
                                flex: 6,
                                child: Center(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 400),
                                      child: _buildLoginForm(context, theme, colorScheme, invite, isLoading),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Layout Mobile / Telas Estreitas
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: _buildLoginForm(context, theme, colorScheme, invite, isLoading),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    dynamic invite,
    bool isLoading,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Emblema com Logo da Fraternidade
          Center(
            child: Image.asset(
              'assets/img/logo_fraternidade.png',
              height: 95,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.church_rounded,
                  size: 56,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Misericórdia Materna',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Secretaria da Fraternidade',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Notificação de Convite Ativo
          if (invite != null) ...[
            Card(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.mail_outline_rounded, color: colorScheme.secondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Convite Ativo detectado!',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                          Text(
                            'Você foi convidado para o perfil: ${invite.targetRole.label}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
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

          // Campo de E-mail
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'E-mail',
              hintText: 'exemplo@email.com',
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

          // Campo de Senha
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Senha',
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
              if (value == null || value.trim().isEmpty) {
                return 'Informe sua senha';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          // Esqueci a senha
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showPasswordResetDialog,
              child: const Text('Esqueceu a senha?'),
            ),
          ),
          const SizedBox(height: 12),

          // Botão Entrar
          FilledButton(
            onPressed: isLoading ? null : _handleEmailLogin,
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
                    'Entrar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 16),

          // Divisor OU
          Row(
            children: [
              Expanded(child: Divider(color: colorScheme.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OU',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ),
              Expanded(child: Divider(color: colorScheme.outlineVariant)),
            ],
          ),
          const SizedBox(height: 16),

          // Botão Google
          OutlinedButton.icon(
            onPressed: isLoading ? null : _handleGoogleLogin,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: const Text(
              'Continuar com Google',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),

          // Link para Criar Conta
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ainda não tem conta?',
                style: theme.textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.register),
                child: const Text(
                  'Cadastre-se',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
