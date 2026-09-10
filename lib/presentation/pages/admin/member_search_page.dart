import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/constants/localidades.dart';
import '../../../domain/entities/user_entity.dart';
import '../../signals/auth_signal.dart';
import '../../signals/member_search_signal.dart';
import '../../widgets/member_detail_dialog.dart';

class MemberSearchPage extends StatefulWidget {
  const MemberSearchPage({super.key});

  @override
  State<MemberSearchPage> createState() => _MemberSearchPageState();
}

class _MemberSearchPageState extends State<MemberSearchPage> {
  final _searchController = TextEditingController();

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
    _searchController.text = memberSearchSignal.searchQuery.value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      memberSearchSignal.loadMembers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final currentUser = authSignal.currentUser.value;

        if (currentUser == null || !currentUser.role.canSearchMembers) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pesquisa de Membros')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    const Text(
                      'Acesso Restrito',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Seu perfil atual não possui permissão para pesquisar membros.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final isLoading = memberSearchSignal.isLoading.value;
        final errorMessage = memberSearchSignal.errorMessage.value;
        final paginatedList = memberSearchSignal.paginatedMembers;
        final totalCount = memberSearchSignal.totalCount;
        final totalPages = memberSearchSignal.totalPages;
        final currentPage = memberSearchSignal.currentPage.value;
        final itemsPerPage = memberSearchSignal.itemsPerPage.value;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text('Pesquisa e Gestão de Membros'),
            backgroundColor: AppColors.surface,
            elevation: 1,
            actions: [
              IconButton(
                tooltip: 'Recarregar membros',
                icon: const Icon(Icons.refresh),
                onPressed: isLoading ? null : () => memberSearchSignal.loadMembers(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header & Security Scoping Notice
                    _buildRoleScopeBanner(currentUser),
                    const SizedBox(height: 20),

                    // Filters & Search Card
                    _buildFiltersCard(currentUser),
                    const SizedBox(height: 24),

                    // Error Banner
                    if (errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ),
                            TextButton(
                              onPressed: () => memberSearchSignal.loadMembers(),
                              child: const Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Pagination Summary Bar
                    _buildSummaryBar(totalCount, itemsPerPage),
                    const SizedBox(height: 16),

                    // List / Cards
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (totalCount == 0)
                      _buildEmptyState()
                    else ...[
                      _buildMembersGrid(paginatedList),
                      const SizedBox(height: 24),
                      _buildPaginationControls(currentPage, totalPages),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleScopeBanner(UserEntity currentUser) {
    String scopeTitle;
    String scopeDesc;
    IconData icon;

    switch (currentUser.role) {
      case AppRole.fundador:
        scopeTitle = 'Visão Global (Fundador)';
        scopeDesc = 'Você possui acesso total para visualizar e filtrar todos os membros em todas as fraternidades.';
        icon = Icons.admin_panel_settings;
        break;
      case AppRole.secretariaGeralExterna:
        scopeTitle = 'Secretaria Geral — Vida Externa';
        scopeDesc = 'Sua visão está restrita a todos os membros pertencentes à Vida Externa.';
        icon = Icons.wb_sunny_outlined;
        break;
      case AppRole.secretariaGeralInterna:
        scopeTitle = 'Secretaria Geral — Vida Interna';
        scopeDesc = 'Sua visão está restrita a todos os membros pertencentes à Vida Interna.';
        icon = Icons.nightlight_round_outlined;
        break;
      case AppRole.formador:
        scopeTitle = 'Formador Vocacional — Vida Interna';
        scopeDesc = 'Sua visão está restrita a todos os membros e vocacionados da Vida Interna.';
        icon = Icons.school_outlined;
        break;
      case AppRole.secretariaLocal:
        final loc = Localidades.porSigla(currentUser.localidade);
        scopeTitle = 'Secretaria Local — ${loc?.nome ?? currentUser.localidade ?? "Local"}';
        scopeDesc = 'Sua visão está restrita exclusivamente aos membros cadastrados na sua fraternidade.';
        icon = Icons.location_city;
        break;
      default:
        scopeTitle = currentUser.role.displayName;
        scopeDesc = 'Consulta de membros autorizada.';
        icon = Icons.security;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 20,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scopeTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scopeDesc,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard(UserEntity currentUser) {
    final filterTipoVida = memberSearchSignal.filterTipoVida.value;
    final filterLocalidade = memberSearchSignal.filterLocalidade.value;
    final filterEtapa = memberSearchSignal.filterEtapa.value;
    final filterCasado = memberSearchSignal.filterCasado.value;

    final isTipoVidaLocked = currentUser.role == AppRole.secretariaGeralExterna ||
        currentUser.role == AppRole.secretariaGeralInterna ||
        currentUser.role == AppRole.formador;

    final isLocalidadeLocked = currentUser.role == AppRole.secretariaLocal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de busca em texto
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Pesquise por Nome, E-mail, CPF ou Telefone...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        memberSearchSignal.searchQuery.value = '';
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (val) {
              memberSearchSignal.searchQuery.value = val;
              setState(() {});
            },
          ),
          const SizedBox(height: 16),

          // Filtros Avançados
          Wrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // 1. Tipo de Vida
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<TipoVida?>(
                  initialValue: filterTipoVida,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Vida',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    enabled: !isTipoVidaLocked,
                  ),
                  items: [
                    if (!isTipoVidaLocked)
                      const DropdownMenuItem(value: null, child: Text('Todos os Tipos')),
                    const DropdownMenuItem(value: TipoVida.externa, child: Text('Vida Externa')),
                    const DropdownMenuItem(value: TipoVida.interna, child: Text('Vida Interna')),
                  ],
                  onChanged: isTipoVidaLocked
                      ? null
                      : (val) => memberSearchSignal.filterTipoVida.value = val,
                ),
              ),

              // 2. Localidade da Fraternidade
              SizedBox(
                width: 210,
                child: DropdownButtonFormField<String?>(
                  initialValue: filterLocalidade,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: 'Fraternidade',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    enabled: !isLocalidadeLocked,
                  ),
                  items: [
                    if (!isLocalidadeLocked)
                      const DropdownMenuItem(value: null, child: Text('Todas as Fraternidades')),
                    ...Localidades.todas.map((loc) => DropdownMenuItem(
                          value: loc.sigla,
                          child: Text('${loc.nome} (${loc.sigla})'),
                        )),
                  ],
                  onChanged: isLocalidadeLocked
                      ? null
                      : (val) => memberSearchSignal.filterLocalidade.value = val,
                ),
              ),

              // 3. Etapa do Caminho
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<String?>(
                  initialValue: filterEtapa,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: 'Etapa do Caminho',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas as Etapas')),
                    ..._etapasPossiveis.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                  ],
                  onChanged: (val) => memberSearchSignal.filterEtapa.value = val,
                ),
              ),

              // 4. Estado Civil (Casado vs Solteiro)
              SizedBox(
                width: 170,
                child: DropdownButtonFormField<bool?>(
                  initialValue: filterCasado,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: 'Estado Civil',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    DropdownMenuItem(value: false, child: Text('Solteiro(a)')),
                    DropdownMenuItem(value: true, child: Text('Casado(a)')),
                  ],
                  onChanged: (val) => memberSearchSignal.filterCasado.value = val,
                ),
              ),

              // Botão Limpar Filtros
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  memberSearchSignal.clearFilters();
                  setState(() {});
                },
                icon: const Icon(Icons.filter_alt_off, size: 18),
                label: const Text('Limpar Filtros'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(int totalCount, int itemsPerPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$totalCount ${totalCount == 1 ? "membro encontrado" : "membros encontrados"}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Row(
          children: [
            const Text(
              'Itens por página: ',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: itemsPerPage,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 10, child: Text('10')),
                DropdownMenuItem(value: 25, child: Text('25')),
                DropdownMenuItem(value: 50, child: Text('50')),
              ],
              onChanged: (val) {
                if (val != null) {
                  memberSearchSignal.itemsPerPage.value = val;
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMembersGrid(List<UserEntity> members) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Grid responsive calculation
        final width = constraints.maxWidth;
        int crossAxisCount = 1;
        if (width >= 1000) {
          crossAxisCount = 3;
        } else if (width >= 650) {
          crossAxisCount = 2;
        }

        if (crossAxisCount == 1) {
          return Column(
            children: members.map((m) => _buildMemberCard(m)).toList(),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 260,
          ),
          itemCount: members.length,
          itemBuilder: (context, index) => _buildMemberCard(members[index]),
        );
      },
    );
  }

  Widget _buildMemberCard(UserEntity member) {
    final localidadeObj = Localidades.porSigla(member.localidade);
    final localidadeNome = localidadeObj?.nome ?? member.localidade ?? 'Não definida';
    final tipoVidaNome = member.tipoVida?.displayName ?? 'Não definido';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Email, Role
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(member),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.nome.isNotEmpty ? member.nome : 'Sem nome cadastrado',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.email,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (member.cidade != null && member.cidade!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${member.cidade}/${member.uf ?? ""}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Badges: Role, Vida, Fraternidade
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildBadgeChip(member.role.displayName, AppColors.primarySoft, AppColors.primaryDark),
              _buildBadgeChip(tipoVidaNome, Colors.amber.shade50, Colors.amber.shade900),
              _buildBadgeChip(localidadeNome, Colors.blue.shade50, Colors.blue.shade800),
              if (member.etapaFraternidade != null && member.etapaFraternidade!.isNotEmpty)
                _buildBadgeChip(member.etapaFraternidade!, Colors.grey.shade100, Colors.grey.shade800),
              _buildBadgeChip(
                member.isCasado ? 'Casado(a)' : 'Solteiro(a)',
                Colors.purple.shade50,
                Colors.purple.shade800,
              ),
            ],
          ),

          const Spacer(),
          const Divider(height: 16, color: AppColors.borderLight),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (member.telefone.isNotEmpty || member.celular != null)
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366), size: 20),
                      tooltip: 'Conversar no WhatsApp',
                      onPressed: () => _abrirWhatsApp(member.telefone.isNotEmpty ? member.telefone : member.celular),
                    ),
                  IconButton(
                    icon: const Icon(Icons.mail_outline, color: AppColors.primary, size: 20),
                    tooltip: 'Enviar E-mail',
                    onPressed: () => _abrirEmail(member.email),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => MemberDetailDialog.show(context, member),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('Detalhes'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(UserEntity member) {
    final foto = member.fotoUrl;
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
          radius: 24,
          backgroundImage: imgProvider,
          backgroundColor: AppColors.primarySoft,
        );
      }
    }

    final initials = member.nome.isNotEmpty
        ? member.nome.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'M';

    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primarySoft,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildBadgeChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: text),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'Nenhum membro encontrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tente ajustar seus termos de pesquisa ou remover os filtros aplicados.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                memberSearchSignal.clearFilters();
                setState(() {});
              },
              child: const Text('Limpar Filtros'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls(int currentPage, int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () => memberSearchSignal.goToPage(currentPage - 1)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            'Página $currentPage de $totalPages',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () => memberSearchSignal.goToPage(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
