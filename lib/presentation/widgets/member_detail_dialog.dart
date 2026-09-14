import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_roles.dart';
import '../../core/constants/cadastro_constants.dart';
import '../../core/constants/localidades.dart';
import '../../domain/entities/user_entity.dart';
import '../pages/admin/member_edit_page.dart';
import '../signals/auth_signal.dart';
import '../signals/member_search_signal.dart';

class MemberDetailDialog extends StatefulWidget {
  final UserEntity member;

  const MemberDetailDialog({
    super.key,
    required this.member,
  });

  static Future<void> show(BuildContext context, UserEntity member) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => MemberDetailDialog(member: member),
    );
  }

  @override
  State<MemberDetailDialog> createState() => _MemberDetailDialogState();
}

class _MemberDetailDialogState extends State<MemberDetailDialog> {
  late UserEntity _member;

  // Institutional edit fields
  late TipoVida? _tipoVida;
  late String? _localidade;
  late String? _etapaFraternidade;
  late AppRole _role;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _member = widget.member;
    _tipoVida = _member.tipoVida ?? TipoVida.externa;
    _localidade = Localidades.resolver(_member.localidade)?.sigla ?? Localidades.brasilia.sigla;

    final etapasValidas = CadastroConstants.etapasPorTipoVida(_tipoVida);
    if (_member.etapaFraternidade != null && etapasValidas.contains(_member.etapaFraternidade)) {
      _etapaFraternidade = _member.etapaFraternidade;
    } else {
      _etapaFraternidade = etapasValidas.first;
    }

    _role = _member.role;
  }

  int? _calcularIdade(String? dataNasc) {
    if (dataNasc == null || dataNasc.isEmpty) return null;
    final parts = dataNasc.split('/');
    if (parts.length != 3) return null;
    final dia = int.tryParse(parts[0]);
    final mes = int.tryParse(parts[1]);
    final ano = int.tryParse(parts[2]);
    if (dia == null || mes == null || ano == null) return null;

    final hoje = DateTime.now();
    int idade = hoje.year - ano;
    if (hoje.month < mes || (hoje.month == mes && hoje.day < dia)) {
      idade--;
    }
    return idade >= 0 ? idade : null;
  }

  Future<void> _abrirWhatsApp(String? telefone) async {
    if (telefone == null || telefone.isEmpty) return;
    final digits = telefone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    final url = Uri.parse('https://wa.me/55$digits');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _abrirEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _abrirPdfAutobiografia() async {
    final base64Data = _member.autobiografiaPdfBase64;
    if (base64Data == null || base64Data.isEmpty) return;

    try {
      final uri = Uri.parse('data:application/pdf;base64,$base64Data');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o PDF diretamente no navegador.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir PDF: $e')),
        );
      }
    }
  }

  Future<void> _salvarAlteracoesInstitucionais() async {
    setState(() => _isSaving = true);
    final success = await memberSearchSignal.updateMemberInstitutional(
      userId: _member.id,
      tipoVida: _tipoVida,
      localidade: _localidade,
      etapaFraternidade: _etapaFraternidade,
      role: _role,
    );

    if (mounted) {
      setState(() {
        _isSaving = false;
        if (success) {
          _member = _member.copyWith(
            tipoVida: _tipoVida,
            localidade: _localidade,
            etapaFraternidade: _etapaFraternidade,
            role: _role,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Dados institucionais atualizados com sucesso!'
                : (memberSearchSignal.errorMessage.value ?? 'Erro ao salvar alterações.'),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _abrirEdicaoCompleta() async {
    final updated = await MemberEditPage.navigate(context, _member);
    if (updated != null && mounted) {
      setState(() {
        _member = updated;
        _tipoVida = updated.tipoVida ?? TipoVida.externa;
        _localidade = Localidades.resolver(updated.localidade)?.sigla ?? Localidades.brasilia.sigla;
        final etapasValidas = CadastroConstants.etapasPorTipoVida(_tipoVida);
        if (updated.etapaFraternidade != null && etapasValidas.contains(updated.etapaFraternidade)) {
          _etapaFraternidade = updated.etapaFraternidade;
        } else {
          _etapaFraternidade = etapasValidas.first;
        }
        _role = updated.role;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = authSignal.currentUser.value;
    final canEdit = currentUser?.role.canEditMemberInstitutional ?? false;
    final idade = _calcularIdade(_member.dataNascimento);

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 780,
          maxHeight: 850,
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(colorScheme, canEdit),
            Divider(height: 1, color: colorScheme.outlineVariant),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumo Institucional e Badges
                    _buildInstitutionalBanner(colorScheme),
                    const SizedBox(height: 24),

                    // 1. Dados Pessoais & Contato
                    _buildSectionTitle(colorScheme, Icons.person_outline, 'Dados Pessoais & Contato'),
                    const SizedBox(height: 12),
                    _buildCardGrid(colorScheme, [
                      _buildInfoItem(colorScheme, 'Nome Completo', _member.nome),
                      _buildInfoItem(colorScheme, 'E-mail', _member.email),
                      _buildInfoItem(colorScheme, 'Telefone / WhatsApp', _member.telefone.isNotEmpty ? _member.telefone : (_member.celular ?? 'Não informado')),
                      _buildInfoItem(colorScheme, 'Data de Nascimento', _member.dataNascimento != null ? '${_member.dataNascimento} (${idade != null ? "$idade anos" : ""})' : 'Não informada'),
                      _buildInfoItem(colorScheme, 'CPF', _member.cpf ?? 'Não informado'),
                      _buildInfoItem(colorScheme, 'RG / Órgão', _member.rg ?? 'Não informado'),
                      _buildInfoItem(colorScheme, 'Profissão', _member.profissao ?? 'Não informada'),
                      _buildInfoItem(colorScheme, 'Escolaridade', _member.escolaridade ?? 'Não informada'),
                    ]),
                    const SizedBox(height: 16),

                    // Endereço Residencial
                    _buildSubCard(
                      colorScheme,
                      title: 'Endereço Residencial',
                      icon: Icons.home_outlined,
                      child: Text(
                        [
                          if (_member.logradouro != null && _member.logradouro!.isNotEmpty)
                            '${_member.logradouro}${_member.numero != null ? ", ${_member.numero}" : ""}',
                          if (_member.complemento != null && _member.complemento!.isNotEmpty)
                            _member.complemento,
                          if (_member.bairro != null && _member.bairro!.isNotEmpty)
                            'Bairro: ${_member.bairro}',
                          if (_member.cidade != null && _member.cidade!.isNotEmpty)
                            '${_member.cidade}/${_member.uf ?? ""}',
                          if (_member.cep != null && _member.cep!.isNotEmpty)
                            'CEP: ${_member.cep}',
                        ].where((s) => s != null && s.isNotEmpty).join(' • ').ifEmpty('Endereço não informado.'),
                        style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Família & Vínculos
                    _buildSectionTitle(colorScheme, Icons.family_restroom, 'Família & Vínculos'),
                    const SizedBox(height: 12),
                    _buildFamiliaSection(colorScheme),
                    const SizedBox(height: 24),

                    // 3. Vivência Paroquial & Caminho
                    _buildSectionTitle(colorScheme, Icons.church_outlined, 'Vivência Religiosa & Paroquial'),
                    const SizedBox(height: 12),
                    _buildCardGrid(colorScheme, [
                      _buildInfoItem(colorScheme, 'Paróquia que frequenta', _member.paroquia ?? 'Não informada'),
                      _buildInfoItem(colorScheme, 'Pároco', _member.paroco ?? 'Não informado'),
                      _buildInfoItem(colorScheme, 'Cidade/UF da Paróquia', _member.paroquiaCidadeUf ?? 'Não informada'),
                      _buildInfoItem(
                        colorScheme,
                        'Participa de Pastoral / Movimento',
                        _member.participaPastoral
                            ? (_member.qualPastoral ?? 'Sim')
                            : 'Não participa',
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // 4. Vocacional
                    _buildSectionTitle(colorScheme, Icons.volunteer_activism_outlined, 'Dados Vocacionais'),
                    const SizedBox(height: 12),
                    _buildVocacionalSection(colorScheme),
                    const SizedBox(height: 24),

                    // 5. Autobiografia (se solteiro ou presente)
                    if (!_member.isCasado || _member.autobiografiaPdfBase64 != null || (_member.autobiografiaHistoriaPessoal != null && _member.autobiografiaHistoriaPessoal!.isNotEmpty)) ...[
                      _buildSectionTitle(colorScheme, Icons.history_edu_outlined, 'Autobiografia Vocacional'),
                      const SizedBox(height: 12),
                      _buildAutobiografiaSection(colorScheme),
                      const SizedBox(height: 24),
                    ],

                    // 6. Painel de Gestão Institucional
                    if (canEdit) ...[
                      _buildSectionTitle(colorScheme, Icons.admin_panel_settings_outlined, 'Gestão Institucional'),
                      const SizedBox(height: 12),
                      _buildGestaoInstitucionalSection(colorScheme, currentUser: currentUser),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            Divider(height: 1, color: colorScheme.outlineVariant),
            _buildFooter(colorScheme, canEdit),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, bool canEdit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Foto ou Iniciais
          _buildAvatar(colorScheme),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _member.nome.isNotEmpty ? _member.nome : 'Sem nome',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _member.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (canEdit) ...[
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Editar'),
              onPressed: _abrirEdicaoCompleta,
            ),
            const SizedBox(width: 6),
          ],
          // Ações rápidas (WhatsApp e Email)
          if (_member.telefone.isNotEmpty || _member.celular != null)
            IconButton(
              tooltip: 'Conversar no WhatsApp',
              icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366)),
              onPressed: () => _abrirWhatsApp(_member.telefone.isNotEmpty ? _member.telefone : _member.celular),
            ),
          IconButton(
            tooltip: 'Enviar E-mail',
            icon: Icon(Icons.mail_outline, color: colorScheme.primary),
            onPressed: () => _abrirEmail(_member.email),
          ),
          IconButton(
            tooltip: 'Fechar',
            icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme) {
    final foto = _member.fotoUrl;
    if (foto != null && foto.isNotEmpty) {
      ImageProvider? imgProvider;
      if (foto.startsWith('data:image')) {
        try {
          final base64Str = foto.split(',').last;
          imgProvider = MemoryImage(base64Decode(base64Str));
        } catch (_) {}
      } else if (foto.startsWith('http')) {
        imgProvider = NetworkImage(foto);
      }
      if (imgProvider != null) {
        return CircleAvatar(
          radius: 28,
          backgroundImage: imgProvider,
          backgroundColor: colorScheme.surfaceContainerHighest,
        );
      }
    }

    // Initials fallback
    final initials = _member.nome.isNotEmpty
        ? _member.nome.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'M';

    return CircleAvatar(
      radius: 28,
      backgroundColor: colorScheme.primary,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildInstitutionalBanner(ColorScheme colorScheme) {
    final localidadeObj = Localidades.resolver(_member.localidade);
    final localidadeNome = localidadeObj?.rotuloCompleto ??
        ((_member.localidade != null && _member.localidade!.trim().isNotEmpty)
            ? _member.localidade!
            : 'Não definida');
    final tipoVidaNome = _member.tipoVida?.displayName ?? 'Não definido';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildBadge(
            icon: Icons.shield_outlined,
            label: _member.role.displayName,
            bgColor: colorScheme.primary,
            textColor: colorScheme.onPrimary,
          ),
          _buildBadge(
            icon: Icons.favorite_outline,
            label: 'Vida: $tipoVidaNome',
            bgColor: colorScheme.surfaceContainerHigh,
            textColor: colorScheme.primary,
            borderColor: colorScheme.primary.withValues(alpha: 0.5),
          ),
          _buildBadge(
            icon: Icons.location_on_outlined,
            label: 'Fraternidade: $localidadeNome',
            bgColor: colorScheme.surfaceContainerHigh,
            textColor: colorScheme.secondary,
            borderColor: colorScheme.secondary.withValues(alpha: 0.5),
          ),
          if (_member.etapaFraternidade != null && _member.etapaFraternidade!.isNotEmpty)
            _buildBadge(
              icon: Icons.timeline,
              label: 'Etapa: ${_member.etapaFraternidade}',
              bgColor: colorScheme.surfaceContainerHigh,
              textColor: colorScheme.onSurface,
              borderColor: colorScheme.outlineVariant,
            ),
          _buildBadge(
            icon: _member.isCasado ? Icons.favorite : Icons.person,
            label: _member.isCasado ? 'Casado(a)' : 'Solteiro(a)',
            bgColor: colorScheme.surfaceContainerHigh,
            textColor: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != null ? Border.all(color: borderColor, width: 1.2) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ColorScheme colorScheme, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCardGrid(ColorScheme colorScheme, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;
          return Wrap(
            spacing: 24,
            runSpacing: 16,
            children: children.map((item) {
              return SizedBox(
                width: isWide ? (constraints.maxWidth - 24) / 2 - 1 : constraints.maxWidth,
                child: item,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(ColorScheme colorScheme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value.isNotEmpty ? value : '—',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSubCard(ColorScheme colorScheme, {required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildFamiliaSection(ColorScheme colorScheme) {
    if (_member.isCasado) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(colorScheme, 'Cônjuge', _member.nomeConjuge ?? 'Não informado'),
            if (_member.spouseId != null && _member.spouseId!.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Text(
                'Perfil vinculado',
                style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold),
              ),
            ],
            Divider(height: 24, color: colorScheme.outlineVariant),
            Text(
              'Filhos (${_member.filhos.isNotEmpty ? _member.filhos.length : _member.quantidadeFilhos})',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            if (_member.filhos.isEmpty && _member.nomesFilhos.isEmpty)
              Text('Nenhum filho cadastrado.', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant))
            else if (_member.filhos.isNotEmpty)
              ..._member.filhos.map((f) {
                final idadeFilho = _calcularIdade(f.dataNascimento);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.child_care, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${f.nome} — Nasc: ${f.dataNascimento}${idadeFilho != null ? " ($idadeFilho anos)" : ""}',
                          style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                );
              })
            else
              ..._member.nomesFilhos.map((nome) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $nome', style: TextStyle(fontSize: 13, color: colorScheme.onSurface)),
                  )),
          ],
        ),
      );
    } else {
      // Solteiro
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildInfoItem(colorScheme, 'Nome do Pai', _member.nomePai ?? 'Não informado')),
                Expanded(child: _buildInfoItem(colorScheme, 'Nome da Mãe', _member.nomeMae ?? 'Não informado')),
              ],
            ),
            Divider(height: 24, color: colorScheme.outlineVariant),
            Text(
              'Irmãos (${_member.irmaos.length})',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            if (_member.irmaos.isEmpty)
              Text('Nenhum irmão cadastrado (filho único).', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant))
            else
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _member.irmaos.map((nome) {
                  return Chip(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    label: Text(nome, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
          ],
        ),
      );
    }
  }

  Widget _buildVocacionalSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_member.isCasado) ...[
            _buildVocacionalItem(colorScheme, 'Testemunho Vocacional Matrimonial', _member.testemunhoVocacionalMatrimonial),
            const SizedBox(height: 12),
            _buildVocacionalItem(colorScheme, 'Disponibilidade do Casal', _member.disponibilidadeCasal),
            const SizedBox(height: 12),
          ],
          _buildVocacionalItem(colorScheme, 'Experiência de Serviço na Igreja', _member.experienciaServicoIgreja),
          const SizedBox(height: 12),
          _buildVocacionalItem(colorScheme, 'Como conheceu a Fraternidade', _member.conhecimentoFraternidade),
          const SizedBox(height: 12),
          _buildVocacionalItem(colorScheme, 'Pensamento sobre o Carisma', _member.pensamentoCarisma),
          const SizedBox(height: 12),
          _buildVocacionalItem(colorScheme, 'Chamado à Comunidade de Aliança', _member.chamadoComunidadeAlianca),
          const SizedBox(height: 12),
          _buildVocacionalItem(colorScheme, 'Onde mais gosta de trabalhar na Fraternidade', _member.ondeMaisGostaTrabalhar),
        ],
      ),
    );
  }

  Widget _buildVocacionalItem(ColorScheme colorScheme, String title, String? content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          content != null && content.isNotEmpty ? content : 'Não informado',
          style: TextStyle(fontSize: 13.5, color: colorScheme.onSurface, height: 1.3),
        ),
      ],
    );
  }

  Widget _buildAutobiografiaSection(ColorScheme colorScheme) {
    final temPdf = _member.autobiografiaPdfBase64 != null && _member.autobiografiaPdfBase64!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (temPdf) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Color(0xFF16A34A), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _member.autobiografiaPdfNome ?? 'autobiografia.pdf',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Documento PDF anexado pelo membro',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _abrirPdfAutobiografia,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Visualizar PDF'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_member.autobiografiaHistoriaPessoal != null && _member.autobiografiaHistoriaPessoal!.isNotEmpty) ...[
            _buildVocacionalItem(colorScheme, '1. História Pessoal', _member.autobiografiaHistoriaPessoal),
            const SizedBox(height: 12),
          ],
          if (_member.autobiografiaFamilia != null && _member.autobiografiaFamilia!.isNotEmpty) ...[
            _buildVocacionalItem(colorScheme, '2. Família e Relacionamentos', _member.autobiografiaFamilia),
            const SizedBox(height: 12),
          ],
          if (_member.autobiografiaIgreja != null && _member.autobiografiaIgreja!.isNotEmpty) ...[
            _buildVocacionalItem(colorScheme, '3. Experiência de Fé e Igreja', _member.autobiografiaIgreja),
          ],
        ],
      ),
    );
  }

  Widget _buildGestaoInstitucionalSection(ColorScheme colorScheme, {required UserEntity? currentUser}) {
    final etapas = CadastroConstants.etapasPorTipoVida(_tipoVida);
    final allowedRoles = currentUser?.role.rolesPermitidasParaAtribuir ?? [];
    final targetIsFundador = _member.role == AppRole.fundador;
    final currentUserIsFundador = currentUser?.role == AppRole.fundador;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Alterar Atribuições do Membro',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _abrirEdicaoCompleta,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Edição Completa'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Tipo de Vida
          Text('Tipo de Vida', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 6),
          SegmentedButton<TipoVida>(
            segments: const [
              ButtonSegment<TipoVida>(
                value: TipoVida.externa,
                label: Text('Vida Externa'),
                icon: Icon(Icons.wb_sunny_outlined, size: 16),
              ),
              ButtonSegment<TipoVida>(
                value: TipoVida.interna,
                label: Text('Vida Interna'),
                icon: Icon(Icons.nightlight_round_outlined, size: 16),
              ),
            ],
            selected: {_tipoVida ?? TipoVida.externa},
            onSelectionChanged: (set) {
              final newTipo = set.first;
              setState(() {
                _tipoVida = newTipo;
                final novasEtapas = CadastroConstants.etapasPorTipoVida(newTipo);
                if (!novasEtapas.contains(_etapaFraternidade)) {
                  _etapaFraternidade = novasEtapas.first;
                }
              });
            },
          ),
          const SizedBox(height: 16),

          // 2. Localidade da Fraternidade
          Text('Localidade da Fraternidade', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            key: ValueKey('localidade_combo_$_localidade'),
            initialValue: Localidades.todas.any((l) => l.sigla == _localidade)
                ? _localidade
                : Localidades.brasilia.sigla,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
            ),
            items: Localidades.todas
                .map((loc) => DropdownMenuItem(
                      value: loc.sigla,
                      child: Text('${loc.nome} (${loc.sigla})', overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _localidade = val),
          ),
          const SizedBox(height: 16),

          // 3. Etapa da Fraternidade (Dinâmica de acordo com o Tipo de Vida)
          Text('Etapa do Caminho (${_tipoVida?.displayName ?? "Vida Externa"})',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            key: ValueKey('etapa_combo_${_tipoVida?.key}_$_etapaFraternidade'),
            initialValue: etapas.contains(_etapaFraternidade)
                ? _etapaFraternidade
                : etapas.first,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
            ),
            items: etapas
                .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (val) => setState(() => _etapaFraternidade = val),
          ),
          const SizedBox(height: 16),

          // 4. Perfil / Role (Regras de alteração de papel por permissão)
          if (targetIsFundador && !currentUserIsFundador) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Perfil atual: Fundador (somente outro Fundador pode alterar este papel).',
                      style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else if (allowedRoles.isNotEmpty) ...[
            Text('Papel / Acesso no Sistema',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            const SizedBox(height: 6),
            DropdownButtonFormField<AppRole>(
              key: ValueKey('role_combo_$_role'),
              initialValue: allowedRoles.contains(_role) ? _role : allowedRoles.first,
              isExpanded: true,
              decoration: InputDecoration(
                isDense: true,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceContainerLow,
              ),
              items: allowedRoles
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.displayName, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (val) => setState(() => _role = val ?? _role),
            ),
            const SizedBox(height: 16),
          ],

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _salvarAlteracoesInstitucionais,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: _isSaving
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(_isSaving ? 'Salvando...' : 'Salvar Alterações'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ColorScheme colorScheme, bool canEdit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Criado em: ${_formatarData(_member.createdAt)}',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canEdit) ...[
                FilledButton.icon(
                  onPressed: _abrirEdicaoCompleta,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  icon: const Icon(Icons.edit_note_outlined, size: 18),
                  label: const Text('Editar Cadastro Completo'),
                ),
                const SizedBox(width: 12),
              ],
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
