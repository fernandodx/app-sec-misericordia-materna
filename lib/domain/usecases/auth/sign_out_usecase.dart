import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository _repository;
  SignOutUseCase(this._repository);

  Future<Either<Failure, Unit>> call() {
    return TaskEither<Failure, Unit>.tryCatch(
      () async {
        await _repository.signOut();
        return unit;
      },
      (error, _) => Failure.fromException(error),
    ).run();
  }
}
