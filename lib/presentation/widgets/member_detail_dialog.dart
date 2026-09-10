import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_roles.dart';
import '../../core/constants/localidades.dart';
import '../../domain/entities/user_entity.dart';
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

  final List<String> _etapasPossiveis = const [
    'Aspirantado',
    'Postulantado I',
    'Postulantado II',
    'Noviciado I',
    'Noviciado II',
    'Consagrado',
    'Formador',
  ];

  @override
  void initState() {
    super.initState();
    _member = widget.member;
    _tipoVida = _member.tipoVida;
    _localidade = _member.localidade;
    _etapaFraternidade = _member.etapaFraternidade;
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

  @override
  Widget build(BuildContext context) {
    final currentUser = authSignal.currentUser.value;
    final canEdit = currentUser?.role.canEditMemberInstitutional ?? false;
    final isFundador = currentUser?.role == AppRole.fundador;
    final idade = _calcularIdade(_member.dataNascimento);

    return Dialog(
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
            _buildHeader(),
            const Divider(height: 1, color: AppColors.borderLight),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumo Institucional e Badges
                    _buildInstitutionalBanner(),
                    const SizedBox(height: 24),

                    // 1. Dados Pessoais & Contato
                    _buildSectionTitle(Icons.person_outline, 'Dados Pessoais & Contato'),
                    const SizedBox(height: 12),
                    _buildCardGrid([
                      _buildInfoItem('Nome Completo', _member.nome),
                      _buildInfoItem('E-mail', _member.email),
                      _buildInfoItem('Telefone / WhatsApp', _member.telefone.isNotEmpty ? _member.telefone : (_member.celular ?? 'Não informado')),
                      _buildInfoItem('Data de Nascimento', _member.dataNascimento != null ? '${_member.dataNascimento} (${idade != null ? "$idade anos" : ""})' : 'Não informada'),
                      _buildInfoItem('CPF', _member.cpf ?? 'Não informado'),
                      _buildInfoItem('RG / Órgão', _member.rg ?? 'Não informado'),
                      _buildInfoItem('Profissão', _member.profissao ?? 'Não informada'),
                      _buildInfoItem('Escolaridade', _member.escolaridade ?? 'Não informada'),
                    ]),
                    const SizedBox(height: 16),

                    // Endereço Residencial
                    _buildSubCard(
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
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Família & Vínculos
                    _buildSectionTitle(Icons.family_restroom, 'Família & Vínculos'),
                    const SizedBox(height: 12),
                    _buildFamiliaSection(),
                    const SizedBox(height: 24),

                    // 3. Vivência Paroquial & Caminho
                    _buildSectionTitle(Icons.church_outlined, 'Vivência Religiosa & Paroquial'),
                    const SizedBox(height: 12),
                    _buildCardGrid([
                      _buildInfoItem('Paróquia que frequenta', _member.paroquia ?? 'Não informada'),
                      _buildInfoItem('Pároco', _member.paroco ?? 'Não informado'),
                      _buildInfoItem('Cidade/UF da Paróquia', _member.paroquiaCidadeUf ?? 'Não informada'),
                      _buildInfoItem(
                        'Participa de Pastoral / Movimento',
                        _member.participaPastoral
                            ? (_member.qualPastoral ?? 'Sim')
                            : 'Não participa',
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // 4. Vocacional
                    _buildSectionTitle(Icons.volunteer_activism_outlined, 'Dados Vocacionais'),
                    const SizedBox(height: 12),
                    _buildVocacionalSection(),
                    const SizedBox(height: 24),

                    // 5. Autobiografia (se solteiro ou presente)
                    if (!_member.isCasado || _member.autobiografiaPdfBase64 != null || (_member.autobiografiaHistoriaPessoal != null && _member.autobiografiaHistoriaPessoal!.isNotEmpty)) ...[
                      _buildSectionTitle(Icons.history_edu_outlined, 'Autobiografia Vocacional'),
                      const SizedBox(height: 12),
                      _buildAutobiografiaSection(),
                      const SizedBox(height: 24),
                    ],

                    // 6. Painel de Gestão Institucional
                    if (canEdit) ...[
                      _buildSectionTitle(Icons.admin_panel_settings_outlined, 'Gestão Institucional'),
                      const SizedBox(height: 12),
                      _buildGestaoInstitucionalSection(isFundador: isFundador),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            const Divider(height: 1, color: AppColors.borderLight),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Foto ou Iniciais
          _buildAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _member.nome.isNotEmpty ? _member.nome : 'Sem nome',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _member.email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Ações rápidas (WhatsApp e Email)
          if (_member.telefone.isNotEmpty || _member.celular != null)
            IconButton(
              tooltip: 'Conversar no WhatsApp',
              icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366)),
              onPressed: () => _abrirWhatsApp(_member.telefone.isNotEmpty ? _member.telefone : _member.celular),
            ),
          IconButton(
            tooltip: 'Enviar E-mail',
            icon: const Icon(Icons.mail_outline, color: AppColors.primary),
            onPressed: () => _abrirEmail(_member.email),
          ),
          IconButton(
            tooltip: 'Fechar',
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
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
          backgroundColor: AppColors.primarySoft,
        );
      }
    }

    // Initials fallback
    final initials = _member.nome.isNotEmpty
        ? _member.nome.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'M';

    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.primarySoft,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildInstitutionalBanner() {
    final localidadeObj = Localidades.fromSigla(_member.localidade);
    final localidadeNome = localidadeObj?.nome ?? _member.localidade ?? 'Não definida';
    final tipoVidaNome = _member.tipoVida?.displayName ?? 'Não definido';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildBadge(
            icon: Icons.shield_outlined,
            label: _member.role.displayName,
            bgColor: AppColors.primary,
            textColor: Colors.white,
          ),
          _buildBadge(
            icon: Icons.favorite_outline,
            label: 'Vida: $tipoVidaNome',
            bgColor: AppColors.surface,
            textColor: AppColors.primaryDark,
            borderColor: AppColors.primary,
          ),
          _buildBadge(
            icon: Icons.location_on_outlined,
            label: 'Fraternidade: $localidadeNome',
            bgColor: AppColors.surface,
            textColor: AppColors.secondary,
            borderColor: AppColors.secondary,
          ),
          if (_member.etapaFraternidade != null && _member.etapaFraternidade!.isNotEmpty)
            _buildBadge(
              icon: Icons.timeline,
              label: 'Etapa: ${_member.etapaFraternidade}',
              bgColor: AppColors.surface,
              textColor: AppColors.textPrimary,
              borderColor: AppColors.borderLight,
            ),
          _buildBadge(
            icon: _member.isCasado ? Icons.favorite : Icons.person,
            label: _member.isCasado ? 'Casado(a)' : 'Solteiro(a)',
            bgColor: AppColors.surface,
            textColor: AppColors.textSecondary,
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

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCardGrid(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
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

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value.isNotEmpty ? value : '—',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSubCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
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

  Widget _buildFamiliaSection() {
    if (_member.isCasado) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem('Cônjuge', _member.nomeConjuge ?? 'Não informado'),
            if (_member.spouseId != null && _member.spouseId!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Perfil vinculado (ID: ${_member.spouseId})',
                style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold),
              ),
            ],
            const Divider(height: 24, color: AppColors.borderLight),
            Text(
              'Filhos (${_member.filhos.isNotEmpty ? _member.filhos.length : _member.quantidadeFilhos})',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            if (_member.filhos.isEmpty && _member.nomesFilhos.isEmpty)
              const Text('Nenhum filho cadastrado.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
            else if (_member.filhos.isNotEmpty)
              ..._member.filhos.map((f) {
                final idadeFilho = _calcularIdade(f.dataNascimento);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.child_care, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${f.nome} — Nasc: ${f.dataNascimento}${idadeFilho != null ? " ($idadeFilho anos)" : ""}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                );
              })
            else
              ..._member.nomesFilhos.map((nome) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $nome', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                  )),
          ],
        ),
      );
    } else {
      // Solteiro
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildInfoItem('Nome do Pai', _member.nomePai ?? 'Não informado')),
                Expanded(child: _buildInfoItem('Nome da Mãe', _member.nomeMae ?? 'Não informado')),
              ],
            ),
            const Divider(height: 24, color: AppColors.borderLight),
            Text(
              'Irmãos (${_member.irmaos.length})',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            if (_member.irmaos.isEmpty)
              const Text('Nenhum irmão cadastrado (filho único).', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))
            else
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _member.irmaos.map((nome) {
                  return Chip(
                    backgroundColor: AppColors.primarySoft.withValues(alpha: 0.5),
                    label: Text(nome, style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
          ],
        ),
      );
    }
  }

  Widget _buildVocacionalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_member.isCasado) ...[
            _buildVocacionalItem('Testemunho Vocacional Matrimonial', _member.testemunhoVocacionalMatrimonial),
            const SizedBox(height: 12),
            _buildVocacionalItem('Disponibilidade do Casal', _member.disponibilidadeCasal),
            const SizedBox(height: 12),
          ],
          _buildVocacionalItem('Experiência de Serviço na Igreja', _member.experienciaServicoIgreja),
          const SizedBox(height: 12),
          _buildVocacionalItem('Como conheceu a Fraternidade', _member.conhecimentoFraternidade),
          const SizedBox(height: 12),
          _buildVocacionalItem('Pensamento sobre o Carisma', _member.pensamentoCarisma),
          const SizedBox(height: 12),
          _buildVocacionalItem('Chamado à Comunidade de Aliança', _member.chamadoComunidadeAlianca),
          const SizedBox(height: 12),
          _buildVocacionalItem('Onde mais gosta de trabalhar na Fraternidade', _member.ondeMaisGostaTrabalhar),
        ],
      ),
    );
  }

  Widget _buildVocacionalItem(String title, String? content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          content != null && content.isNotEmpty ? content : 'Não informado',
          style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary, height: 1.3),
        ),
      ],
    );
  }

  Widget _buildAutobiografiaSection() {
    final temPdf = _member.autobiografiaPdfBase64 != null && _member.autobiografiaPdfBase64!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (temPdf) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF86EFAC)),
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Documento PDF anexado pelo membro',
                          style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
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
            _buildVocacionalItem('1. História Pessoal', _member.autobiografiaHistoriaPessoal),
            const SizedBox(height: 12),
          ],
          if (_member.autobiografiaFamilia != null && _member.autobiografiaFamilia!.isNotEmpty) ...[
            _buildVocacionalItem('2. Família e Relacionamentos', _member.autobiografiaFamilia),
            const SizedBox(height: 12),
          ],
          if (_member.autobiografiaIgreja != null && _member.autobiografiaIgreja!.isNotEmpty) ...[
            _buildVocacionalItem('3. Experiência de Fé e Igreja', _member.autobiografiaIgreja),
          ],
        ],
      ),
    );
  }

  Widget _buildGestaoInstitucionalSection({required bool isFundador}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Alterar Atribuições do Membro',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Tipo de Vida
          const Text('Tipo de Vida', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
            onSelectionChanged: (set) => setState(() => _tipoVida = set.first),
          ),
          const SizedBox(height: 16),

          // 2. Localidade da Fraternidade
          const Text('Localidade da Fraternidade', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: Localidades.todas.any((l) => l.sigla == _localidade)
                ? _localidade
                : Localidades.brasilia.sigla,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              filled: true,
              fillColor: AppColors.surface,
            ),
            items: Localidades.todas
                .map((loc) => DropdownMenuItem(
                      value: loc.sigla,
                      child: Text('${loc.nome} (${loc.sigla})'),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _localidade = val),
          ),
          const SizedBox(height: 16),

          // 3. Etapa da Fraternidade
          const Text('Etapa do Caminho', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _etapasPossiveis.contains(_etapaFraternidade)
                ? _etapaFraternidade
                : _etapasPossiveis.first,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              filled: true,
              fillColor: AppColors.surface,
            ),
            items: _etapasPossiveis
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => setState(() => _etapaFraternidade = val),
          ),
          const SizedBox(height: 16),

          // 4. Perfil / Role (Apenas Fundador)
          if (isFundador) ...[
            const Text('Papel / Acesso no Sistema (Exclusivo Fundador)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<AppRole>(
              initialValue: _role,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: AppRole.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.displayName)))
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(_isSaving ? 'Salvando...' : 'Salvar Alterações'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Criado em: ${_formatarData(_member.createdAt)}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
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
