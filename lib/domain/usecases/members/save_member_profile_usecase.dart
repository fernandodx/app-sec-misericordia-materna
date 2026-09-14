import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/invite_repository.dart';
import '../../repositories/user_repository.dart';

class SaveMemberProfileUseCase {
  final UserRepository _userRepository;
  final InviteRepository _inviteRepository;

  SaveMemberProfileUseCase(this._userRepository, this._inviteRepository);

  Future<Either<Failure, Unit>> call({
    required UserEntity user,
    String? inviteCode,
  }) {
    return TaskEither<Failure, Unit>.tryCatch(
      () async {
        await _userRepository.saveUser(user);
        if (inviteCode != null && inviteCode.trim().isNotEmpty) {
          await _inviteRepository.acceptInvite(inviteCode.trim(), user.id);
        }
        return unit;
      },
      (error, _) => Failure.fromException(error),
    ).run();
  }
}
