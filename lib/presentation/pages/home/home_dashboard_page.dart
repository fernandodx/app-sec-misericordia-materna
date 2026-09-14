import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/localidades.dart';
import '../../signals/auth_signal.dart';

import '../../widgets/theme_selector_widget.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SignalBuilder(
      builder: (context) {
        final user = authSignal.currentUser.value;
        final isLoading = authSignal.isLoading.value;

        if (user == null) {
          if (isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: _buildAppBarTitle(colorScheme),
              actions: [
                const ThemeSelectorButton(),
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Sair',
                  onPressed: () => authSignal.signOut(),
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_circle_outlined, size: 64, color: colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'Sessão não identificada',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Não foi possível carregar os dados do seu usuário.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () => authSignal.signOut(),
                      icon: const Icon(Icons.logout),
                      label: const Text('Sair para o Login'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final role = user.role;

        return Scaffold(
          appBar: AppBar(
            title: _buildAppBarTitle(colorScheme),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card de Identidade da Fraternidade
                      Card(
                        elevation: 0,
                        color: colorScheme.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/img/logo_fraternidade.png',
                                height: 50,
                                fit: BoxFit.contain,
                                errorBuilder: (_, error, stackTrace) => Icon(
                                  Icons.church_rounded,
                                  size: 40,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fraternidade Misericórdia Materna',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Secretaria Geral & Acompanhamento de Membros',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.photo_library_outlined),
                                tooltip: 'Visualizar Banner da Fraternidade',
                                onPressed: () => _showBannerDialog(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Banner de Alerta Não Bloqueante: Cadastro Incompleto
                      if (!user.isProfileComplete) ...[
                        Card(
                          elevation: 0,
                          color: colorScheme.errorContainer.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colorScheme.error.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    color: colorScheme.error,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cadastro Incompleto (Etapa ${user.cadastroEtapa} de 6)',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onErrorContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Finalize o preenchimento da sua ficha de membro para manter seus dados cadastrais atualizados.',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                FilledButton.tonal(
                                  onPressed: () => context.go(AppRoutes.memberForm),
                                  child: const Text('Concluir'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Banner de Aviso: E-mail não verificado
                      if (!user.isEmailVerified) ...[
                        Card(
                          elevation: 0,
                          color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.4)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.mail_outline_rounded, color: colorScheme.secondary),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'E-mail não confirmado',
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Confirme seu endereço de e-mail (${user.email}) para validação de segurança.',
                                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () => context.push(AppRoutes.verifyEmail),
                                  child: const Text('Verificar'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Card de Perfil do Usuário Logado
                      Card(
                        elevation: 0,
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              ClipOval(
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: (user.fotoUrl != null && user.fotoUrl!.isNotEmpty)
                                      ? Image.network(
                                          user.fotoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: colorScheme.primary,
                                            alignment: Alignment.center,
                                            child: Text(
                                              user.nome.isNotEmpty ? user.nome[0].toUpperCase() : 'M',
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onPrimary,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: colorScheme.primary,
                                          alignment: Alignment.center,
                                          child: Text(
                                            user.nome.isNotEmpty ? user.nome[0].toUpperCase() : 'M',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.nome.isNotEmpty ? user.nome : 'Membro',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user.email,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            role.label,
                                            style: TextStyle(
                                              color: colorScheme.onPrimary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (user.localidade != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: colorScheme.secondaryContainer,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              Localidades.nomePorSigla(user.localidade),
                                              style: TextStyle(
                                                color: colorScheme.onSecondaryContainer,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_note_rounded, size: 28),
                                tooltip: 'Minha Ficha Cadastral',
                                onPressed: () => context.go(AppRoutes.memberForm),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),


                      // Ações Rápidas Administrativas
                      if (role.canManageInvites || role.canSearchMembers) ...[
                        Text(
                          'Gestão e Secretaria',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (role.canSearchMembers) ...[
                          Card(
                            elevation: 0,
                            color: colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: colorScheme.outlineVariant),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.secondary,
                                child: Icon(Icons.people_alt_outlined, color: colorScheme.onSecondary, size: 20),
                              ),
                              title: const Text(
                                'Pesquisa e Gestão de Membros',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                'Consulte fichas cadastrais, contatos, etapas do caminho e vida comunitária',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push(AppRoutes.memberSearch),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (role.canManageInvites) ...[
                          Card(
                            elevation: 0,
                            color: colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: colorScheme.outlineVariant),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.primary,
                                child: Icon(Icons.send_rounded, color: colorScheme.onPrimary, size: 20),
                              ),
                              title: const Text(
                                'Gerenciar Links de Convite',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                'Gere links oficiais com perfis pré-definidos (Membro, Formador, etc.)',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push(AppRoutes.adminInvites),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 12),
                      ],

                      // Informações do Perfil de Acesso
                      Text(
                        'Seu Acesso na Fraternidade',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildRoleCard(context, role),
                      const SizedBox(height: 24),

                      // Ações do Membro
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.badge_outlined),
                              title: const Text('Editar Ficha Cadastral'),
                              subtitle: const Text('Atualize seu telefone e foto de perfil'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.go(AppRoutes.memberForm),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.info_outline),
                              title: const Text('Portal Institucional'),
                              subtitle: const Text('Conheça mais sobre a Fraternidade Misericórdia Materna'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push(AppRoutes.institucional),
                            ),
                          ],
                        ),
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

  Widget _buildRoleCard(BuildContext context, dynamic role) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String description;
    IconData icon;

    switch (role.key) {
      case 'fundador':
        description = 'Poder total sobre o sistema, aprovação de etapas, relatórios globais de Vida Interna e Externa.';
        icon = Icons.star_rounded;
        break;
      case 'formador':
        description = 'Acompanhamento e formação direta de membros em Vida Interna.';
        icon = Icons.school_rounded;
        break;
      case 'acompanhador':
        description = 'Acompanhamento e formação pastoral exclusiva dos membros atribuídos a você em Vida Externa.';
        icon = Icons.handshake_rounded;
        break;
      case 'secretaria_geral_ext':
        description = 'Acesso cadastral geral aos membros de Vida Externa e atribuição de acompanhadores.';
        icon = Icons.assignment_ind_rounded;
        break;
      case 'secretaria_geral_int':
        description = 'Acesso cadastral aos membros de Vida Interna e atribuição de formadores.';
        icon = Icons.assignment_ind_outlined;
        break;
      case 'secretaria_local':
        description = 'Gestão de membros e acompanhadores da sua Fraternidade Local.';
        icon = Icons.location_city_rounded;
        break;
      default:
        description = 'Acesso aos seus dados pessoais e ficha de acompanhamento.';
        icon = Icons.person_outline_rounded;
    }

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/img/logo_fraternidade.png',
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (_, error, stackTrace) => const Icon(Icons.church_rounded, size: 24),
        ),
        const SizedBox(width: 10),
        const Flexible(
          child: Text(
            'Misericórdia Materna',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showBannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 750),
                  child: Image.asset(
                    'assets/img/banner_vertical.jpg',
                    fit: BoxFit.contain,
                    errorBuilder: (_, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(32),
                      color: Colors.black87,
                      child: const Text(
                        'Banner da Fraternidade Misericórdia Materna',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.65),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
