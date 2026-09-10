import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_roles.dart';
import '../../domain/entities/invite_entity.dart';

class InviteModel extends InviteEntity {
  const InviteModel({
    required super.id,
    required super.targetRole,
    super.tipoVida,
    super.localidade,
    super.targetEmail,
    required super.createdByUid,
    super.createdByName,
    required super.status,
    super.acceptedByUid,
    required super.createdAt,
    super.expiresAt,
  });

  factory InviteModel.fromEntity(InviteEntity entity) {
    return InviteModel(
      id: entity.id,
      targetRole: entity.targetRole,
      tipoVida: entity.tipoVida,
      localidade: entity.localidade,
      targetEmail: entity.targetEmail,
      createdByUid: entity.createdByUid,
      createdByName: entity.createdByName,
      status: entity.status,
      acceptedByUid: entity.acceptedByUid,
      createdAt: entity.createdAt,
      expiresAt: entity.expiresAt,
    );
  }

  factory InviteModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return InviteModel.fromMap(data, doc.id);
  }

  factory InviteModel.fromMap(Map<String, dynamic> data, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return InviteModel(
      id: id,
      targetRole: AppRole.fromKey(data['targetRole'] as String?),
      tipoVida: TipoVida.fromKey(data['tipoVida'] as String?),
      localidade: data['localidade'] as String?,
      targetEmail: data['targetEmail'] as String?,
      createdByUid: (data['createdByUid'] as String?) ?? '',
      createdByName: data['createdByName'] as String?,
      status: InviteStatus.fromKey(data['status'] as String?),
      acceptedByUid: data['acceptedByUid'] as String?,
      createdAt: parseDate(data['createdAt']),
      expiresAt: parseNullableDate(data['expiresAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetRole': targetRole.key,
      'tipoVida': tipoVida?.key,
      'localidade': localidade,
      'targetEmail': targetEmail,
      'createdByUid': createdByUid,
      'createdByName': createdByName,
      'status': status.key,
      'acceptedByUid': acceptedByUid,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }
}
