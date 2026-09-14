import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class SignInEmailUseCase {
  final AuthRepository _repository;
  SignInEmailUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(String email, String password) {
    return TaskEither<Failure, UserEntity>.tryCatch(
      () => _repository.signInWithEmail(email, password),
      (error, _) => Failure.fromException(error),
    ).run();
  }
}
