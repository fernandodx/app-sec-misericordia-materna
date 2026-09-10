import '../../core/config/env_config.dart';
import '../../core/constants/app_roles.dart';

enum InviteStatus {
  pending('pending', 'Pendente'),
  accepted('accepted', 'Utilizado'),
  revoked('revoked', 'Revogado');

  final String key;
  final String label;
  const InviteStatus(this.key, this.label);

  static InviteStatus fromKey(String? key) {
    if (key == null) return InviteStatus.pending;
    return InviteStatus.values.firstWhere(
      (s) => s.key == key,
      orElse: () => InviteStatus.pending,
    );
  }
}

class InviteEntity {
  final String id; // Token do convite
  final AppRole targetRole;
  final TipoVida? tipoVida;
  final String? localidade; // BSB, AAX, UDI
  final String? targetEmail; // Opcional (restrito a um e-mail se preenchido)
  final String createdByUid;
  final String? createdByName;
  final InviteStatus status;
  final String? acceptedByUid;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const InviteEntity({
    required this.id,
    required this.targetRole,
    this.tipoVida,
    this.localidade,
    this.targetEmail,
    required this.createdByUid,
    this.createdByName,
    required this.status,
    this.acceptedByUid,
    required this.createdAt,
    this.expiresAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isValid => status == InviteStatus.pending && !isExpired;

  /// Retorna o link oficial no formato exigido: https://app.misericordiamaterna.org/convite?codigo=TOKEN_XYZ
  String get linkOficial => '${EnvConfig.inviteBaseUrl}?codigo=$id';
}
