enum AppRole {
  fundador(
    'fundador',
    'Fundador (Poder Total)',
    'Acesso total e irrestrito a todas as funcionalidades do sistema. Pode gerenciar todos os perfis (incluindo atribuir o papel de Fundador), desativar ou excluir membros definitivamente, gerenciar convites, consultar relatórios e administrar configurações globais da instituição.',
  ),
  formador(
    'formador',
    'Formador (Vida Interna)',
    'Acompanhamento e discernimento vocacional dos membros de Vida Interna. Acesso à consulta dos membros de Vida Interna, relatórios formativos e acompanhamento de etapas da instituição.',
  ),
  acompanhador(
    'acompanhador',
    'Acompanhador (Vida Externa)',
    'Acompanhamento formativo e pastoral dos membros de Vida Externa. Auxilia no discernimento vocacional e acompanhamento das etapas do caminho.',
  ),
  secretariaGeral(
    'secretaria_geral',
    'Secretaria Geral',
    'Gestão ampla e unificada de membros e convites para todas as localidades e tipos de vida. Pode atribuir perfis a qualquer usuário (exceto Fundador), desativar e excluir membros, consultar fichas completas e gerenciar etapas.',
  ),
  secretariaLocal(
    'secretaria_local',
    'Secretaria Local',
    'Gestão restrita de membros e convites da sua respectiva localidade/cidade. Pode cadastrar novos membros locais, consultar cadastros e atribuir perfis operacionais locais.',
  ),
  membro(
    'membro',
    'Membro',
    'Membro ativo da Fraternidade. Acesso à própria ficha cadastral, informações institucionais, avisos, eventos e vida da instituição.',
  ),
  visitante(
    'visitante',
    'Visitante (Sem Convite)',
    'Perfil inicial de acesso público. Visualiza apenas as informações institucionais públicas da Fraternidade enquanto aguarda aprovação de convite ou vínculo cadastral.',
  );

  final String key;
  final String label;
  final String description;

  const AppRole(this.key, this.label, this.description);

  static AppRole fromKey(String? key) {
    if (key == null) return AppRole.visitante;
    final clean = key.trim().toLowerCase();
    // Mapeamento retrocompatível para Secretaria Geral
    if (clean == 'secretaria_geral' ||
        clean == 'secretaria_geral_ext' ||
        clean == 'secretaria_geral_int') {
      return AppRole.secretariaGeral;
    }
    return AppRole.values.firstWhere(
      (role) => role.key == clean,
      orElse: () => AppRole.visitante,
    );
  }

  String get displayName => label;

  bool get isFundador => this == AppRole.fundador;
  bool get isFormador => this == AppRole.formador;
  bool get isAcompanhador => this == AppRole.acompanhador;
  bool get isSecretariaGeral => this == AppRole.secretariaGeral;
  // Aliases de retrocompatibilidade
  bool get isSecretariaGeralExterna => isSecretariaGeral;
  bool get isSecretariaGeralInterna => isSecretariaGeral;
  bool get isSecretariaLocal => this == AppRole.secretariaLocal;
  bool get isMembro => this == AppRole.membro;
  bool get isVisitante => this == AppRole.visitante;

  bool get canManageInvites =>
      isFundador ||
      isSecretariaGeral ||
      isSecretariaLocal;

  bool get canSearchMembers =>
      isFundador ||
      isSecretariaGeral ||
      isSecretariaLocal ||
      isFormador;

  /// Perfis que podem criar novos usuários/membros diretamente (sem convite)
  bool get canCreateDirectMember =>
      isFundador ||
      isSecretariaGeral ||
      isSecretariaLocal;

  /// Os mesmos perfis que podem consultar membros também podem alterar dados institucionais
  bool get canEditMemberInstitutional => canSearchMembers;

  /// Perfis que podem desativar ou excluir membros definitivamente (Fundador e Secretaria Geral)
  bool get canDeactivateOrDeleteMember =>
      isFundador ||
      isSecretariaGeral;

  /// Perfis que podem gerenciar/atribuir múltiplos perfis aos membros
  bool get canManageProfiles =>
      isFundador ||
      isSecretariaGeral;

  bool get canAccessDashboard => !isVisitante;

  /// Lista de papéis que o perfil atual tem permissão de atribuir a outro usuário
  List<AppRole> get rolesPermitidasParaAtribuir {
    switch (this) {
      case AppRole.fundador:
        // Somente o Fundador pode nomear outro Fundador (e qualquer outro perfil)
        return AppRole.values.toList();

      case AppRole.secretariaGeral:
      case AppRole.formador:
        // Secretaria Geral e Formador podem alterar para qualquer um, menos Fundador
        return AppRole.values.where((r) => r != AppRole.fundador).toList();

      case AppRole.secretariaLocal:
        // Secretaria Local pode mudar para todos os perfis abaixo de Secretaria Geral
        return AppRole.values
            .where((r) =>
                r != AppRole.fundador &&
                r != AppRole.secretariaGeral)
            .toList();

      default:
        return [];
    }
  }

  /// Valida se o perfil atual pode atribuir um papel específico
  bool podeAtribuirRole(AppRole roleAlvo) {
    return rolesPermitidasParaAtribuir.contains(roleAlvo);
  }
}

enum TipoVida {
  interna('interna', 'Vida Interna'),
  externa('externa', 'Vida Externa');

  final String key;
  final String label;

  const TipoVida(this.key, this.label);

  static TipoVida? fromKey(String? key) {
    if (key == null) return null;
    final clean = key.trim().toLowerCase();
    if (clean.isEmpty) return null;
    if (clean.contains('interna')) return TipoVida.interna;
    if (clean.contains('externa')) return TipoVida.externa;
    return null;
  }

  String get displayName => label;
}
