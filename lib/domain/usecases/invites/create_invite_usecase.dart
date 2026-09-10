import '../../entities/invite_entity.dart';
import '../../repositories/invite_repository.dart';

class CreateInviteUseCase {
  final InviteRepository _repository;
  CreateInviteUseCase(this._repository);

  Future<void> call(InviteEntity invite) {
    return _repository.createInvite(invite);
  }
}
