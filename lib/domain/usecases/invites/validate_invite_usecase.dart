import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../entities/invite_entity.dart';
import '../../repositories/invite_repository.dart';

class ValidateInviteUseCase {
  final InviteRepository _repository;
  ValidateInviteUseCase(this._repository);

  Future<Either<Failure, InviteEntity>> call(String code) {
    return TaskEither<Failure, InviteEntity>.tryCatch(
      () async {
        final cleanCode = code.trim().toUpperCase();
        if (cleanCode.isEmpty) {
          throw const ValidationFailure('Código de convite não informado.');
        }

        final invite = await _repository.getInviteByCode(cleanCode);
        if (invite == null || !invite.isValid) {
          throw const NotFoundFailure(
            'Convite não encontrado, já utilizado ou expirado. Verifique o link ou contate a secretaria.',
          );
        }
        return invite;
      },
      (error, _) => Failure.fromException(error),
    ).run();
  }
}
