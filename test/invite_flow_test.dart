import 'package:flutter_test/flutter_test.dart';
import 'package:app_secretaria/core/constants/app_roles.dart';
import 'package:app_secretaria/domain/entities/invite_entity.dart';

void main() {
  group('InviteEntity Tests', () {
    test('formata corretamente link oficial do convite com código', () {
      final invite = InviteEntity(
        id: 'E5C637D6',
        targetRole: AppRole.membro,
        createdByUid: 'admin-123',
        status: InviteStatus.pending,
        createdAt: DateTime.now(),
      );

      expect(invite.linkOficial, contains('/convite?codigo=E5C637D6'));
      expect(invite.isValid, isTrue);
      expect(invite.isExpired, isFalse);
    });

    test('valida status de expiração de convite', () {
      final expiredInvite = InviteEntity(
        id: 'EXPIRED123',
        targetRole: AppRole.formador,
        createdByUid: 'admin-123',
        status: InviteStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(expiredInvite.isExpired, isTrue);
      expect(expiredInvite.isValid, isFalse);
    });
  });
}
