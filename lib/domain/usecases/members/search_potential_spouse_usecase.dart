import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

class SearchPotentialSpouseUseCase {
  final UserRepository _userRepository;

  SearchPotentialSpouseUseCase(this._userRepository);

  Future<Either<Failure, List<UserEntity>>> call(String query, {String? excludeUserId}) {
    return TaskEither<Failure, List<UserEntity>>.tryCatch(
      () => _userRepository.searchUsersByName(query, excludeUserId: excludeUserId),
      (error, _) => Failure.fromException(error),
    ).run();
  }
}
