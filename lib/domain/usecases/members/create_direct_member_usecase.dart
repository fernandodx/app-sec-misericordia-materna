import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

class CreateDirectMemberUseCase {
  final UserRepository _repository;

  CreateDirectMemberUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(UserEntity member) {
    return TaskEither<Failure, UserEntity>.tryCatch(
      () async {
        if (member.nome.trim().isEmpty) {
          throw const ValidationFailure('O nome do membro é obrigatório.');
        }
        if (member.email.trim().isEmpty || !member.email.contains('@')) {
          throw const ValidationFailure('Informe um endereço de e-mail válido.');
        }
        return await _repository.createDirectMember(member);
      },
      (error, _) => Failure.fromException(error),
    ).run();
  }
}
