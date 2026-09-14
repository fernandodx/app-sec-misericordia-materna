import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class RegisterEmailUseCase {
  final AuthRepository _repository;
  RegisterEmailUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(String email, String password, {String? nome}) {
    return TaskEither<Failure, UserEntity>.tryCatch(
      () => _repository.registerWithEmail(email, password, nome: nome),
      (error, _) => Failure.fromException(error),
    ).run();
  }
}
