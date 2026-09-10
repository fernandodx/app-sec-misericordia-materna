import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

class SearchPotentialSpouseUseCase {
  final UserRepository _userRepository;

  SearchPotentialSpouseUseCase(this._userRepository);

  Future<List<UserEntity>> call(String query, {String? excludeUserId}) {
    return _userRepository.searchUsersByName(query, excludeUserId: excludeUserId);
  }
}
