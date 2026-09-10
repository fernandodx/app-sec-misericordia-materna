import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class CheckAuthStateUseCase {
  final AuthRepository _repository;
  CheckAuthStateUseCase(this._repository);

  Stream<UserEntity?> call() {
    return _repository.authStateChanges();
  }

  UserEntity? getCurrentUser() {
    return _repository.getCurrentUser();
  }
}
