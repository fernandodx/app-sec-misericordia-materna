import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../signals/auth_signal.dart';

import '../../widgets/theme_selector_widget.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _isChecking = false;
  bool _isResending = false;

  Future<void> _checkEmail() async {
    try {
      setState(() => _isChecking = true);
      final verified = await authSignal.checkEmailVerified();
      if (!verified && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seu e-mail ainda não foi confirmado. Por favor, acesse o link enviado.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _resendEmail() async {
    try {
      setState(() => _isResending = true);
      await authSignal.sendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link de verificação reenviado com sucesso! Verifique sua caixa de entrada e spam.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SignalBuilder(
      builder: (context) {
        final user = authSignal.currentUser.value;

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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mark_email_unread_outlined,
                        size: 56,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Confirme seu E-mail',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enviamos um link de confirmação para o endereço:\n${user?.email ?? ""}\n\nPor favor, clique no link de confirmação antes de acessar o sistema da Fraternidade.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botão Já verifiquei
                  FilledButton.icon(
                    onPressed: _isChecking ? null : _checkEmail,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: const Text(
                      'Já verifiquei meu e-mail',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botão Reenviar e-mail
                  OutlinedButton.icon(
                    onPressed: _isResending ? null : _resendEmail,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reenviar e-mail de confirmação'),
                  ),
                  const SizedBox(height: 16),

                  // Botão Sair
                  TextButton.icon(
                    onPressed: () => authSignal.signOut(),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair desta conta'),
                  ),
                ],
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
