import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class RegisterEmailUseCase {
  final AuthRepository _repository;
  RegisterEmailUseCase(this._repository);

  Future<UserEntity> call(String email, String password, {String? nome}) {
    return _repository.registerWithEmail(email, password, nome: nome);
  }
}
