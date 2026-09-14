import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../entities/invite_entity.dart';
import '../../repositories/invite_repository.dart';

class ListInvitesUseCase {
  final InviteRepository _repository;
  ListInvitesUseCase(this._repository);

  Future<Either<Failure, List<InviteEntity>>> call() {
    return TaskEither<Failure, List<InviteEntity>>.tryCatch(
      () => _repository.listInvites(),
      (error, _) => Failure.fromException(error),
    ).run();
  }
}
