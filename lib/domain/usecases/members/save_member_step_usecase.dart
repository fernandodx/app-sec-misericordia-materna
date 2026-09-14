import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/user_repository.dart';

class SaveMemberStepUseCase {
  final UserRepository _userRepository;

  SaveMemberStepUseCase(this._userRepository);

  Future<Either<Failure, Unit>> call({
    required String userId,
    required Map<String, dynamic> stepData,
  }) {
    return TaskEither<Failure, Unit>.tryCatch(
      () async {
        await _userRepository.saveUserPartial(userId, stepData);
        return unit;
      },
      (error, _) => Failure.fromException(error),
    ).run();
  }
}
