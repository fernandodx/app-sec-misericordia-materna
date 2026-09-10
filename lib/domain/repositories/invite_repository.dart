import '../entities/invite_entity.dart';

abstract class InviteRepository {
  Future<void> createInvite(InviteEntity invite);
  Future<InviteEntity?> getInviteByCode(String code);
  Future<void> acceptInvite(String code, String userId);
  Future<void> revokeInvite(String code);
  Future<List<InviteEntity>> listInvites();
  Future<InviteEntity?> findPendingInviteForEmail(String email);
}
