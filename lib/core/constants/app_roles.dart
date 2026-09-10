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

  bool get canEditMemberInstitutional =>
      isFundador ||
      isSecretariaGeralExterna ||
      isSecretariaGeralInterna ||
      isSecretariaLocal;

  bool get canAccessDashboard => !isVisitante;
}

enum TipoVida {
  interna('interna', 'Vida Interna'),
  externa('externa', 'Vida Externa');

  final String key;
  final String label;

  const TipoVida(this.key, this.label);

  static TipoVida? fromKey(String? key) {
    if (key == null) return null;
    return TipoVida.values.firstWhere(
      (t) => t.key == key,
      orElse: () => TipoVida.externa,
    );
  }

  String get displayName => label;
}
