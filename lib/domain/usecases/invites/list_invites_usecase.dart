import '../../entities/invite_entity.dart';
import '../../repositories/invite_repository.dart';

class ListInvitesUseCase {
  final InviteRepository _repository;
  ListInvitesUseCase(this._repository);

  Future<List<InviteEntity>> call() {
    return _repository.listInvites();
  }
}
