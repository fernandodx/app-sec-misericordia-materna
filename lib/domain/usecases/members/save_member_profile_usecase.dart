import '../../entities/user_entity.dart';
import '../../repositories/invite_repository.dart';
import '../../repositories/user_repository.dart';

class SaveMemberProfileUseCase {
  final UserRepository _userRepository;
  final InviteRepository _inviteRepository;

  SaveMemberProfileUseCase(this._userRepository, this._inviteRepository);

  Future<void> call({
    required UserEntity user,
    String? inviteCode,
  }) async {
    // Salva o perfil do membro
    await _userRepository.saveUser(user);

    // Se houve código de convite utilizado, marca o convite como aceito
    if (inviteCode != null && inviteCode.trim().isNotEmpty) {
      await _inviteRepository.acceptInvite(inviteCode.trim(), user.id);
    }
  }
}
