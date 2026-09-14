import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/user_repository.dart';

class LinkSpouseUseCase {
  final UserRepository _userRepository;

  LinkSpouseUseCase(this._userRepository);

  Future<Either<Failure, Unit>> call({required String userId, required String spouseId}) {
    return TaskEither<Failure, Unit>.tryCatch(
      () async {
        await _userRepository.linkSpouse(userId: userId, spouseId: spouseId);
        return unit;
      },
      (error, _) => Failure.fromException(error),
    ).run();
  }
}
