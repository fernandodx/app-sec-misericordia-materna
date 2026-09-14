import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/env_config.dart';
import '../../../core/di/dependency_injection.dart';
import '../../signals/auth_signal.dart';
import '../../widgets/theme_selector_widget.dart';

class InstitutionalPage extends StatefulWidget {
  const InstitutionalPage({super.key});

  @override
  State<InstitutionalPage> createState() => _InstitutionalPageState();
}

class _InstitutionalPageState extends State<InstitutionalPage> {
  bool _isCheckingInvite = false;

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o link.')),
        );
      }
    }
  }

  Future<void> _recheckInvite() async {
    setState(() => _isCheckingInvite = true);
    final user = authSignal.currentUser.value;
    if (user != null) {
      final invite = await sl.inviteRepository.findPendingInviteForEmail(user.email);
      if (invite != null) {
        final updated = user.copyWith(
          role: invite.targetRole,
          tipoVida: invite.tipoVida,
          localidade: invite.localidade,
        );
        await sl.userRepository.saveUser(updated);
        authSignal.refreshUser(updated);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Convite encontrado! Seu perfil foi atualizado para: ${invite.targetRole.label}'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhum convite pendente foi encontrado para o seu e-mail.'),
            ),
          );
        }
      }
    }
    setState(() => _isCheckingInvite = false);
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
        title: const Text('Fraternidade Misericórdia Materna'),
        actions: [
          const ThemeSelectorButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => authSignal.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner Header
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/img/logo_fraternidade.png',
                            height: 80,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.volunteer_activism_rounded,
                              size: 64,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Fraternidade Misericórdia Materna',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bem-vindo(a), ${user?.nome.isNotEmpty == true ? user!.nome : user?.email ?? ""}!',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Acesso Institucional (Visitante)',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mensagem de Convite Pendente
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: colorScheme.secondary,
                                foregroundColor: colorScheme.onSecondary,
                                radius: 18,
                                child: const Icon(Icons.info_outline, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Este aplicativo é destinado à gestão interna e acompanhamento de membros da Fraternidade. Para ter acesso à secretaria, você precisa receber um link de convite oficial.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: _isCheckingInvite ? null : _recheckInvite,
                            icon: _isCheckingInvite
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.sync_rounded),
                            label: const Text('Verificar se recebi um convite recente'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sobre a Fraternidade
                  Text(
                    'Sobre a Nossa Missão',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A Fraternidade Misericórdia Materna é uma comunidade católica vocacionada ao acolhimento, à oração e à vivência fraterna do amor misericordioso de Deus e de Nossa Senhora.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Formada por membros de Vida Interna (dedicados à vida consagrada religiosa, celibatários e casais) e Vida Externa (leigos e servos presentes nas fraternidades locais de Brasília, Araxá e Uberlândia).',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 28),

                  // Redes Sociais e Contato
                  Text(
                    'Conecte-se Conosco',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.camera_alt_outlined, size: 20),
                        label: const Text('Instagram'),
                        onPressed: () => _launchUrl('https://instagram.com/misericordiamaterna'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.video_library_outlined, size: 20),
                        label: const Text('YouTube'),
                        onPressed: () => _launchUrl('https://youtube.com/@misericordiamaterna'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.language_outlined, size: 20),
                        label: const Text('Portal Oficial'),
                        onPressed: () {
                          final baseUrl = EnvConfig.inviteBaseUrl.replaceAll('/convite', '');
                          _launchUrl(baseUrl);
                        },
                      ),
                    ],
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
