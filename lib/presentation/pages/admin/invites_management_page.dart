import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/constants/localidades.dart';
import '../../../domain/entities/invite_entity.dart';
import '../../signals/auth_signal.dart';
import '../../signals/invite_signal.dart';
import '../../widgets/theme_selector_widget.dart';

class InvitesManagementPage extends StatefulWidget {
  const InvitesManagementPage({super.key});

  @override
  State<InvitesManagementPage> createState() => _InvitesManagementPageState();
}

class _InvitesManagementPageState extends State<InvitesManagementPage> {
  @override
  void initState() {
    super.initState();
    inviteSignal.loadInvites();
  }

  void _showCreateInviteDialog() {
    AppRole selectedRole = AppRole.membro;
    TipoVida selectedTipoVida = TipoVida.externa;
    String? selectedLocalidade = 'BSB';
    final emailController = TextEditingController();
    int validadeDias = 15;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isVidaExterna = selectedTipoVida == TipoVida.externa;

          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.mail_lock_outlined),
                SizedBox(width: 8),
                Text('Gerar Novo Convite'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Configure os parâmetros do convite. O usuário assumirá este perfil automaticamente ao aceitar.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Perfil
                  DropdownButtonFormField<AppRole>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Perfil Atribuído *',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      AppRole.membro,
                      AppRole.acompanhador,
                      AppRole.formador,
                      AppRole.secretariaLocal,
                      AppRole.secretariaGeralExterna,
                      AppRole.secretariaGeralInterna,
                      AppRole.fundador,
                    ].map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedRole = val;
                          if (val == AppRole.formador || val == AppRole.secretariaGeralInterna) {
                            selectedTipoVida = TipoVida.interna;
                            selectedLocalidade = null;
                          } else if (val == AppRole.acompanhador || val == AppRole.secretariaLocal || val == AppRole.secretariaGeralExterna) {
                            selectedTipoVida = TipoVida.externa;
                            selectedLocalidade ??= 'BSB';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tipo de Vida
                  DropdownButtonFormField<TipoVida>(
                    initialValue: selectedTipoVida,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Vida *',
                      border: OutlineInputBorder(),
                    ),
                    items: TipoVida.values.map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedTipoVida = val;
                          if (val == TipoVida.interna) {
                            selectedLocalidade = null;
                          } else {
                            selectedLocalidade ??= 'BSB';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Localidade (Apenas se Vida Externa)
                  if (isVidaExterna) ...[
                    DropdownButtonFormField<String>(
                      initialValue: selectedLocalidade,
                      decoration: const InputDecoration(
                        labelText: 'Localidade (Fraternidade Local) *',
                        border: OutlineInputBorder(),
                      ),
                      items: Localidades.todas.map((loc) {
                        return DropdownMenuItem(
                          value: loc.sigla,
                          child: Text(loc.rotuloCompleto),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() => selectedLocalidade = val);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // E-mail Opcional
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail do Convidado (Opcional)',
                      hintText: 'Deixe vazio para qualquer e-mail',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Validade
                  DropdownButtonFormField<int>(
                    initialValue: validadeDias,
                    decoration: const InputDecoration(
                      labelText: 'Validade do Link',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 7, child: Text('7 dias')),
                      DropdownMenuItem(value: 15, child: Text('15 dias')),
                      DropdownMenuItem(value: 30, child: Text('30 dias')),
                      DropdownMenuItem(value: 90, child: Text('90 dias')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => validadeDias = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final invite = await inviteSignal.createInvite(
                    targetRole: selectedRole,
                    tipoVida: selectedTipoVida,
                    localidade: selectedLocalidade,
                    targetEmail: emailController.text.isNotEmpty ? emailController.text : null,
                    validadeDias: validadeDias,
                  );

                  if (invite != null && mounted) {
                    _showInviteResultDialog(invite);
                  }
                },
                child: const Text('Gerar Link'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showInviteResultDialog(InviteEntity invite) {
    final link = invite.linkOficial;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('Convite Gerado com Sucesso!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Código: ${invite.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Perfil: ${invite.targetRole.label}'),
            if (invite.targetEmail != null && invite.targetEmail!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'E-mail Convidado: ${invite.targetEmail}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            if (invite.tipoVida != null) ...[
              const SizedBox(height: 4),
              Text('Tipo de Vida: ${invite.tipoVida!.label}'),
            ],
            if (invite.localidade != null) ...[
              const SizedBox(height: 4),
              Text('Localidade: ${Localidades.nomePorSigla(invite.localidade)}'),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: SelectableText(
                link,
                style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copiar Link'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copiado para a área de transferência!')),
              );
            },
          ),
          FilledButton.icon(
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Compartilhar'),
            onPressed: () async {
              final text = 'Olá! Você foi convidado para fazer parte da Fraternidade Misericórdia Materna como ${invite.targetRole.label}.\n\nAcesse o link abaixo para concluir seu cadastro:\n$link';
              final whatsappUrl = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
              try {
                await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
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
        final invites = inviteSignal.invites.value;
        final isLoading = inviteSignal.isLoading.value;
        final user = authSignal.currentUser.value;

        return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Convites'),
        actions: const [
          ThemeSelectorButton(),
          SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateInviteDialog,
        icon: const Icon(Icons.add_link),
        label: const Text('Criar Convite'),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => inviteSignal.loadInvites(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header de Resumo
                    Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: colorScheme.outlineVariant),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Image.asset(
                                'assets/img/logo_fraternidade.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.shield_outlined,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Painel de Convites',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Logado como: ${user?.role.label ?? ""} (${user?.email ?? ""})',
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
                    const SizedBox(height: 16),

                    Text(
                      'Histórico de Convites Emitidos (${invites.length})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (invites.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text('Nenhum convite emitido até o momento.'),
                        ),
                      )
                    else
                      ...invites.map((invite) {
                        final isPending = invite.status == InviteStatus.pending && !invite.isExpired;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isPending
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest,
                              foregroundColor: isPending
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                              child: Icon(
                                isPending ? Icons.mark_email_unread_outlined : Icons.check,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  invite.targetRole.label,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (invite.tipoVida != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: invite.tipoVida == TipoVida.interna
                                          ? colorScheme.tertiaryContainer
                                          : colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      invite.tipoVida!.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: invite.tipoVida == TipoVida.interna
                                            ? colorScheme.onTertiaryContainer
                                            : colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      (invite.targetEmail != null && invite.targetEmail!.trim().isNotEmpty)
                                          ? Icons.email_outlined
                                          : Icons.public,
                                      size: 15,
                                      color: (invite.targetEmail != null && invite.targetEmail!.trim().isNotEmpty)
                                          ? colorScheme.primary
                                          : colorScheme.outline,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        (invite.targetEmail != null && invite.targetEmail!.trim().isNotEmpty)
                                            ? 'E-mail Convidado: ${invite.targetEmail}'
                                            : 'E-mail Convidado: Aberto a qualquer e-mail',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: (invite.targetEmail != null && invite.targetEmail!.trim().isNotEmpty)
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: (invite.targetEmail != null && invite.targetEmail!.trim().isNotEmpty)
                                              ? colorScheme.onSurface
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                SelectableText(
                                  invite.linkOficial,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Status: ${invite.status.label}${invite.isExpired ? " (Expirado)" : ""}'
                                  '${invite.localidade != null ? " • Local: ${Localidades.nomePorSigla(invite.localidade)}" : ""}',
                                  style: TextStyle(fontSize: 12, color: colorScheme.outline),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (action) {
                                if (action == 'copy') {
                                  Clipboard.setData(ClipboardData(text: invite.linkOficial));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Link copiado!')),
                                  );
                                } else if (action == 'revoke') {
                                  inviteSignal.revokeInvite(invite.id);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'copy',
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy, size: 18),
                                      SizedBox(width: 8),
                                      Text('Copiar Link'),
                                    ],
                                  ),
                                ),
                                if (isPending)
                                  const PopupMenuItem(
                                    value: 'revoke',
                                    child: Row(
                                      children: [
                                        Icon(Icons.cancel_outlined, size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Revogar Convite', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
      ),
    );
  },
);
}
}
