enum AppRole {
  fundador('fundador', 'Fundador (Poder Total)'),
  formador('formador', 'Formador (Vida Interna)'),
  acompanhador('acompanhador', 'Acompanhador (Vida Externa)'),
  secretariaGeralExterna('secretaria_geral_ext', 'Secretaria Geral (Vida Externa)'),
  secretariaGeralInterna('secretaria_geral_int', 'Secretaria Geral (Vida Interna)'),
  secretariaLocal('secretaria_local', 'Secretaria Local'),
  membro('membro', 'Membro'),
  visitante('visitante', 'Visitante (Sem Convite)');

  final String key;
  final String label;

  const AppRole(this.key, this.label);

  static AppRole fromKey(String? key) {
    if (key == null) return AppRole.visitante;
    return AppRole.values.firstWhere(
      (role) => role.key == key,
      orElse: () => AppRole.visitante,
    );
  }

  String get displayName => label;

  bool get isFundador => this == AppRole.fundador;
  bool get isFormador => this == AppRole.formador;
  bool get isAcompanhador => this == AppRole.acompanhador;
  bool get isSecretariaGeralExterna => this == AppRole.secretariaGeralExterna;
  bool get isSecretariaGeralInterna => this == AppRole.secretariaGeralInterna;
  bool get isSecretariaLocal => this == AppRole.secretariaLocal;
  bool get isMembro => this == AppRole.membro;
  bool get isVisitante => this == AppRole.visitante;

  bool get canManageInvites =>
      isFundador ||
      isSecretariaGeralExterna ||
      isSecretariaGeralInterna ||
      isSecretariaLocal;

  bool get canSearchMembers =>
      isFundador ||
      isSecretariaGeralExterna ||
      isSecretariaGeralInterna ||
      isSecretariaLocal ||
      isFormador;

  /// Os mesmos perfis que podem consultar membros também podem alterar dados institucionais
  bool get canEditMemberInstitutional => canSearchMembers;

  bool get canAccessDashboard => !isVisitante;

  /// Lista de papéis que o perfil atual tem permissão de atribuir a outro usuário
  List<AppRole> get rolesPermitidasParaAtribuir {
    switch (this) {
      case AppRole.fundador:
        // Somente o Fundador pode nomear outro Fundador (e qualquer outro perfil)
        return AppRole.values.toList();

      case AppRole.secretariaGeralExterna:
      case AppRole.secretariaGeralInterna:
      case AppRole.formador:
        // Secretaria Geral e Formador podem alterar para qualquer um, menos Fundador
        return AppRole.values.where((r) => r != AppRole.fundador).toList();

      case AppRole.secretariaLocal:
        // Secretaria Local pode mudar para todos os perfis abaixo de Secretaria Geral
        return AppRole.values
            .where((r) =>
                r != AppRole.fundador &&
                r != AppRole.secretariaGeralExterna &&
                r != AppRole.secretariaGeralInterna)
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
