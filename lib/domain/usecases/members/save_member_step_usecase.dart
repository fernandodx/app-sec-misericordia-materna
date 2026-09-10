import '../../repositories/user_repository.dart';

class SaveMemberStepUseCase {
  final UserRepository _userRepository;

  SaveMemberStepUseCase(this._userRepository);

  Future<void> call({
    required String userId,
    required Map<String, dynamic> stepData,
  }) {
    return _userRepository.saveUserPartial(userId, stepData);
  }
}
