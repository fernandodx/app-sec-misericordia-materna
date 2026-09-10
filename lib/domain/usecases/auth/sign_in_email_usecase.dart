import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class SignInEmailUseCase {
  final AuthRepository _repository;
  SignInEmailUseCase(this._repository);

  Future<UserEntity> call(String email, String password) {
    return _repository.signInWithEmail(email, password);
  }
}
