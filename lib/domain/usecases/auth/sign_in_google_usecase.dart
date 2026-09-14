import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class SignInGoogleUseCase {
  final AuthRepository _repository;
  SignInGoogleUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() {
    return TaskEither<Failure, UserEntity>.tryCatch(
      () => _repository.signInWithGoogle(),
      (error, _) => Failure.fromException(error),
    ).run();
  }
}
