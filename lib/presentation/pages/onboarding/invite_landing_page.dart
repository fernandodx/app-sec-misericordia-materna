import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../domain/entities/invite_entity.dart';
import '../../signals/auth_signal.dart';

class InviteLandingPage extends StatefulWidget {
  final String? codigo;

  const InviteLandingPage({super.key, this.codigo});

  @override
  State<InviteLandingPage> createState() => _InviteLandingPageState();
}

class _InviteLandingPageState extends State<InviteLandingPage> {
  bool _isLoading = true;
  InviteEntity? _invite;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _validateAndLoadInvite();
  }

  Future<void> _validateAndLoadInvite() async {
    final code = widget.codigo?.trim();
    if (code == null || code.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Código de convite não informado.';
      });
      return;
    }

    try {
      final invite = await sl.validateInviteUseCase(code);
      if (invite != null) {
        authSignal.setActiveInvite(invite);
        setState(() {
          _invite = invite;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Convite não encontrado, já utilizado ou expirado. Verifique o link ou contate a secretaria.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao validar convite: $e';
      });
    }
  }

  Future<void> _openNativeApp() async {
    final code = widget.codigo?.trim() ?? '';
    final nativeUri = Uri.parse('misericordiamaterna://convite?codigo=$code');
    try {
      final launched = await launchUrl(
        nativeUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'O aplicativo nativo não foi detectado neste dispositivo. Continue pelo navegador!',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível abrir o aplicativo diretamente. Continue pelo navegador!',
            ),
          ),
        );
      }
    }
  }

  void _goToRegister() {
    context.push(AppRoutes.register);
  }

  void _goToLogin() {
    context.push(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SignalBuilder(
      builder: (context) {
        final currentUser = authSignal.currentUser.value;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Convite Fraternidade'),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Emblema
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.mail_outline_rounded,
                                size: 56,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Text(
                            'Fraternidade Misericórdia Materna',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (_isLoading) ...[
                            const SizedBox(height: 24),
                            const Center(child: CircularProgressIndicator()),
                            const SizedBox(height: 16),
                            Text(
                              'Validando seu convite...',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ] else if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colorScheme.error),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: colorScheme.error),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: () => context.go(AppRoutes.login),
                              child: const Text('Ir para o Login'),
                            ),
                          ] else if (_invite != null) ...[
                            Text(
                              'Você recebeu um convite oficial para fazer parte da comunidade!',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Detalhes do Convite
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: colorScheme.outlineVariant),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow(
                                    context,
                                    Icons.badge_outlined,
                                    'Perfil Atribuído',
                                    _invite!.targetRole.label,
                                    isHighlight: true,
                                  ),
                                  if (_invite!.tipoVida != null) ...[
                                    const Divider(height: 20),
                                    _buildDetailRow(
                                      context,
                                      Icons.favorite_border_rounded,
                                      'Tipo de Vida',
                                      _invite!.tipoVida!.label,
                                    ),
                                  ],
                                  if (_invite!.localidade != null &&
                                      _invite!.localidade!.isNotEmpty) ...[
                                    const Divider(height: 20),
                                    _buildDetailRow(
                                      context,
                                      Icons.location_on_outlined,
                                      'Localidade / Missão',
                                      _invite!.localidade!,
                                    ),
                                  ],
                                  if (_invite!.createdByName != null &&
                                      _invite!.createdByName!.isNotEmpty) ...[
                                    const Divider(height: 20),
                                    _buildDetailRow(
                                      context,
                                      Icons.person_outline_rounded,
                                      'Convidado por',
                                      _invite!.createdByName!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Caso o usuário já esteja logado (ex: o próprio fundador testando o link)
                            if (currentUser != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Conectado como:',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${currentUser.nome.isNotEmpty ? currentUser.nome : currentUser.email} (${currentUser.role.label})',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Para vincular este convite a uma nova conta, encerre a sessão atual.',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (currentUser.role.isVisitante || !currentUser.isProfileComplete)
                                FilledButton(
                                  onPressed: () => context.go(AppRoutes.memberForm),
                                  child: const Text('Vincular ao Meu Perfil'),
                                )
                              else
                                FilledButton(
                                  onPressed: () => context.go(AppRoutes.dashboard),
                                  child: const Text('Continuar para o Meu Painel'),
                                ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.logout, size: 18),
                                label: const Text('Sair para Aceitar com Outra Conta'),
                                onPressed: () async {
                                  await authSignal.signOut();
                                  _validateAndLoadInvite();
                                },
                              ),
                            ] else ...[
                              // Ações para quem não está logado
                              if (kIsWeb) ...[
                                FilledButton.icon(
                                  onPressed: _openNativeApp,
                                  icon: const Icon(Icons.open_in_new_rounded),
                                  label: const Text(
                                    'Abrir no Aplicativo Nativo',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: _goToRegister,
                                  icon: const Icon(Icons.person_add_outlined),
                                  label: const Text('Continuar pelo Navegador (Criar Conta)'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _goToLogin,
                                  child: const Text('Já possuo conta? Entrar'),
                                ),
                              ] else ...[
                                FilledButton.icon(
                                  onPressed: _goToRegister,
                                  icon: const Icon(Icons.person_add_outlined),
                                  label: const Text(
                                    'Criar Minha Conta',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: _goToLogin,
                                  child: const Text('Já possuo conta? Entrar'),
                                ),
                              ],
                            ],
                          ],
                        ],
                      ),
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

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: isHighlight ? colorScheme.primary : colorScheme.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                  color: isHighlight ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
