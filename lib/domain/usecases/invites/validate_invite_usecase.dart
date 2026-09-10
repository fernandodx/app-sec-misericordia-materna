import '../../entities/invite_entity.dart';
import '../../repositories/invite_repository.dart';

class ValidateInviteUseCase {
  final InviteRepository _repository;
  ValidateInviteUseCase(this._repository);

  Future<InviteEntity?> call(String code) async {
    final invite = await _repository.getInviteByCode(code);
    if (invite == null || !invite.isValid) {
      return null;
    }
    return invite;
  }
}
