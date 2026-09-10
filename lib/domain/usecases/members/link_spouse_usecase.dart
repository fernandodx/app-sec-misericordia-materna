import '../../repositories/user_repository.dart';

class LinkSpouseUseCase {
  final UserRepository _userRepository;

  LinkSpouseUseCase(this._userRepository);

  Future<void> call({required String userId, required String spouseId}) {
    return _userRepository.linkSpouse(userId: userId, spouseId: spouseId);
  }
}
