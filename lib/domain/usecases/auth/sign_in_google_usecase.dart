import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class SignInGoogleUseCase {
  final AuthRepository _repository;
  SignInGoogleUseCase(this._repository);

  Future<UserEntity> call() {
    return _repository.signInWithGoogle();
  }
}
