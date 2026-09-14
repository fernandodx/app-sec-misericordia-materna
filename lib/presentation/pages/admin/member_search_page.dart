import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_roles.dart';
import '../../../core/constants/cadastro_constants.dart';
import '../../../core/constants/localidades.dart';
import '../../../domain/entities/user_entity.dart';
import '../../signals/auth_signal.dart';
import '../../signals/member_search_signal.dart';
import '../../widgets/member_detail_dialog.dart';
import '../../widgets/theme_selector_widget.dart';
import 'member_edit_page.dart';

class MemberSearchPage extends StatefulWidget {
  const MemberSearchPage({super.key});

  @override
  State<MemberSearchPage> createState() => _MemberSearchPageState();
}

class _MemberSearchPageState extends State<MemberSearchPage> {
  final _searchController = TextEditingController();

  List<String> get _etapasDisponiveis {
    final tipoVida = memberSearchSignal.filterTipoVida.value;
    if (tipoVida == TipoVida.interna) {
      return CadastroConstants.etapasVidaInterna;
    } else if (tipoVida == TipoVida.externa) {
      return CadastroConstants.etapasVidaExterna;
    } else {
      return [
        ...CadastroConstants.etapasVidaExterna,
        ...CadastroConstants.etapasVidaInterna,
      ];
    }
  }

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
    final cleanDigits = telefone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/55$cleanDigits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _abrirEmail(String email) async {
    if (email.isEmpty) return;
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SignalBuilder(
      builder: (context) {
        final currentUser = authSignal.currentUser.value;

        if (currentUser == null || !currentUser.role.canSearchMembers) {
          return Scaffold(
            appBar: AppBar(title: const Text('Acesso Restrito')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 64, color: colorScheme.error),
                    const SizedBox(height: 16),
                    const Text(
                      'Acesso Negado',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Seu perfil atual (${currentUser?.role.displayName ?? "Desconhecido"}) não possui permissão para consultar os membros.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Voltar'),
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
          appBar: AppBar(
            title: const Text('Pesquisa e Gestão de Membros'),
            elevation: 1,
            actions: [
              const ThemeSelectorButton(),
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
                    _buildRoleScopeBanner(colorScheme, currentUser),
                    const SizedBox(height: 20),

                    // Filters & Search Card
                    _buildFiltersCard(colorScheme, currentUser),
                    const SizedBox(height: 24),

                    // Error Banner
                    if (errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colorScheme.error.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: colorScheme.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: TextStyle(color: colorScheme.onErrorContainer),
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
                    _buildSummaryBar(colorScheme, totalCount, itemsPerPage),
                    const SizedBox(height: 16),

                    // List / Cards
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (totalCount == 0)
                      _buildEmptyState(colorScheme)
                    else ...[
                      _buildMembersGrid(colorScheme, paginatedList),
                      const SizedBox(height: 24),
                      _buildPaginationControls(colorScheme, currentPage, totalPages),
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

  Widget _buildRoleScopeBanner(ColorScheme colorScheme, UserEntity currentUser) {
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
        scopeTitle = 'Escopo Secretaria Geral (Vida Externa)';
        scopeDesc = 'Acesso restrito exclusivamente aos membros que pertencem ao Tipo de Vida Externa.';
        icon = Icons.wb_sunny_outlined;
        break;
      case AppRole.secretariaGeralInterna:
        scopeTitle = 'Escopo Secretaria Geral (Vida Interna)';
        scopeDesc = 'Acesso restrito exclusivamente aos membros que pertencem ao Tipo de Vida Interna.';
        icon = Icons.nightlight_round_outlined;
        break;
      case AppRole.secretariaLocal:
        final loc = Localidades.porSigla(currentUser.localidade);
        scopeTitle = 'Escopo Secretaria Local (${loc?.nome ?? currentUser.localidade ?? "Fraternidade Local"})';
        scopeDesc = 'Acesso restrito exclusivamente aos membros cadastrados na sua fraternidade local.';
        icon = Icons.location_city;
        break;
      case AppRole.formador:
        scopeTitle = 'Escopo Formador (Vida Interna)';
        scopeDesc = 'Acesso restrito para acompanhamento de formandos da Vida Interna.';
        icon = Icons.school_outlined;
        break;
      default:
        scopeTitle = currentUser.role.displayName;
        scopeDesc = 'Consulta de membros autorizada.';
        icon = Icons.security;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary,
            radius: 20,
            child: Icon(icon, color: colorScheme.onPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scopeTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scopeDesc,
                  style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard(ColorScheme colorScheme, UserEntity currentUser) {
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
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de busca em texto
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Pesquise por Nome, E-mail, CPF ou Telefone...',
              prefixIcon: Icon(Icons.search, color: colorScheme.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        memberSearchSignal.searchQuery.value = '';
                      },
                    )
                  : null,
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (val) {
              memberSearchSignal.searchQuery.value = val;
              setState(() {});
            },
          ),
          const SizedBox(height: 18),

          // Filtros Avançados
          LayoutBuilder(
            builder: (context, constraints) {
              final double itemWidth;
              if (constraints.maxWidth >= 960) {
                itemWidth = (constraints.maxWidth - 48) / 4;
              } else if (constraints.maxWidth >= 540) {
                itemWidth = (constraints.maxWidth - 16) / 2;
              } else {
                itemWidth = constraints.maxWidth;
              }

              return Wrap(
                spacing: 16,
                runSpacing: 14,
                children: [
                  // 1. Tipo de Vida
                  SizedBox(
                    width: itemWidth,
                    child: DropdownButtonFormField<TipoVida?>(
                      initialValue: filterTipoVida,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Vida',
                        isDense: true,
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLow,
                        border: const OutlineInputBorder(),
                        enabled: !isTipoVidaLocked,
                      ),
                      items: [
                        const DropdownMenuItem<TipoVida?>(
                          value: null,
                          child: Text('Todos os Tipos', overflow: TextOverflow.ellipsis),
                        ),
                        ...TipoVida.values.map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.displayName, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                      onChanged: isTipoVidaLocked
                          ? null
                          : (val) => memberSearchSignal.filterTipoVida.value = val,
                    ),
                  ),

                  // 2. Fraternidade Localidade
                  SizedBox(
                    width: itemWidth,
                    child: DropdownButtonFormField<String?>(
                      initialValue: filterLocalidade,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Fraternidade',
                        isDense: true,
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLow,
                        border: const OutlineInputBorder(),
                        enabled: !isLocalidadeLocked,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todas as Fraternidades', overflow: TextOverflow.ellipsis),
                        ),
                        ...Localidades.todas.map(
                          (l) => DropdownMenuItem(
                            value: l.sigla,
                            child: Text('${l.nome} (${l.sigla})', overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                      onChanged: isLocalidadeLocked
                          ? null
                          : (val) => memberSearchSignal.filterLocalidade.value = val,
                    ),
                  ),

                  // 3. Etapa do Caminho
                  SizedBox(
                    width: itemWidth,
                    child: DropdownButtonFormField<String?>(
                      key: ValueKey('filter_etapa_${filterTipoVida?.key}'),
                      initialValue: _etapasDisponiveis.contains(filterEtapa) ? filterEtapa : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Etapa do Caminho',
                        isDense: true,
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLow,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todas as Etapas', overflow: TextOverflow.ellipsis),
                        ),
                        ..._etapasDisponiveis.map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                      onChanged: (val) => memberSearchSignal.filterEtapa.value = val,
                    ),
                  ),

                  // 4. Estado Civil (Casado / Solteiro)
                  SizedBox(
                    width: itemWidth,
                    child: DropdownButtonFormField<bool?>(
                      initialValue: filterCasado,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Estado Civil',
                        isDense: true,
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLow,
                        border: const OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem<bool?>(
                          value: null,
                          child: Text('Todos', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem<bool?>(
                          value: true,
                          child: Text('Casados', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem<bool?>(
                          value: false,
                          child: Text('Solteiros', overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      onChanged: (val) => memberSearchSignal.filterCasado.value = val,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Botão Limpar Filtros
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                _searchController.clear();
                memberSearchSignal.clearFilters();
                setState(() {});
              },
              icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
              label: const Text('Limpar Filtros'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(ColorScheme colorScheme, int totalCount, int itemsPerPage) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        Text(
          'Total de membros encontrados: $totalCount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Exibir: ', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
            DropdownButton<int>(
              value: itemsPerPage,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 10, child: Text('10 por página')),
                DropdownMenuItem(value: 25, child: Text('25 por página')),
                DropdownMenuItem(value: 50, child: Text('50 por página')),
              ],
              onChanged: (val) {
                if (val != null) memberSearchSignal.itemsPerPage.value = val;
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMembersGrid(ColorScheme colorScheme, List<UserEntity> members) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoCol = constraints.maxWidth > 750;
        if (isTwoCol) {
          final rowCount = (members.length / 2).ceil();
          return Column(
            children: List.generate(rowCount, (rowIndex) {
              final firstIndex = rowIndex * 2;
              final secondIndex = firstIndex + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildMemberCard(colorScheme, members[firstIndex], fillRemaining: true),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: secondIndex < members.length
                            ? _buildMemberCard(colorScheme, members[secondIndex], fillRemaining: true)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        }

        return Column(
          children: members
              .map((member) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMemberCard(colorScheme, member, fillRemaining: false),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildMemberCard(ColorScheme colorScheme, UserEntity member, {bool fillRemaining = false}) {
    final localidadeObj = Localidades.resolver(member.localidade);
    final localidadeNome = localidadeObj?.rotuloCompleto ??
        ((member.localidade != null && member.localidade!.trim().isNotEmpty)
            ? member.localidade!
            : 'Não definida');
    final tipoVidaNome = member.tipoVida?.displayName ?? 'Não definido';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Email, Role
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(colorScheme, member),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.nome.isNotEmpty ? member.nome : 'Sem nome cadastrado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.email,
                      style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (member.cidade != null && member.cidade!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 13, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${member.cidade}/${member.uf ?? ""}',
                              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
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
              _buildBadgeChip(member.role.displayName, colorScheme.primary, colorScheme.onPrimary),
              _buildBadgeChip(tipoVidaNome, colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
              _buildBadgeChip(localidadeNome, colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
              if (member.etapaFraternidade != null && member.etapaFraternidade!.isNotEmpty)
                _buildBadgeChip(member.etapaFraternidade!, colorScheme.surfaceContainerHigh, colorScheme.onSurface),
              _buildBadgeChip(
                member.isCasado ? 'Casado(a)' : 'Solteiro(a)',
                colorScheme.surfaceContainerHigh,
                colorScheme.onSurfaceVariant,
              ),
            ],
          ),

          if (fillRemaining) const Spacer() else const SizedBox(height: 14),
          Divider(height: 16, color: colorScheme.outlineVariant),

          // Actions
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (member.telefone.isNotEmpty || member.celular != null)
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366), size: 20),
                      tooltip: 'Conversar no WhatsApp',
                      onPressed: () => _abrirWhatsApp(member.telefone.isNotEmpty ? member.telefone : member.celular),
                    ),
                  IconButton(
                    icon: Icon(Icons.mail_outline, color: colorScheme.primary, size: 20),
                    tooltip: 'Enviar E-mail',
                    onPressed: () => _abrirEmail(member.email),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => MemberDetailDialog.show(context, member),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Detalhes'),
                  ),
                  if (authSignal.currentUser.value?.role.canEditMemberInstitutional ?? false)
                    ElevatedButton.icon(
                      onPressed: () => MemberEditPage.navigate(context, member),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Editar'),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme, UserEntity member) {
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
          backgroundColor: colorScheme.surfaceContainerHighest,
        );
      }
    }

    final initials = member.nome.isNotEmpty
        ? member.nome.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'M';

    return CircleAvatar(
      radius: 24,
      backgroundColor: colorScheme.primary,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: colorScheme.outline),
            const SizedBox(height: 16),
            const Text(
              'Nenhum membro encontrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar seus termos de pesquisa ou remover os filtros aplicados.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
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

  Widget _buildPaginationControls(ColorScheme colorScheme, int currentPage, int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 1
                ? () => memberSearchSignal.goToPage(currentPage - 1)
                : null,
          ),
          Text(
            'Página $currentPage de $totalPages',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
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
