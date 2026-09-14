import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../entities/invite_entity.dart';
import '../../repositories/invite_repository.dart';

class CreateInviteUseCase {
  final InviteRepository _repository;
  CreateInviteUseCase(this._repository);

  Future<Either<Failure, InviteEntity>> call(InviteEntity invite) {
    return TaskEither<Failure, InviteEntity>.tryCatch(
      () async {
        await _repository.createInvite(invite);
        return invite;
      },
      (error, _) => Failure.fromException(error),
    ).run();
  }
}
