import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> authStateChanges();
  UserEntity? getCurrentUser();
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> registerWithEmail(String email, String password, {String? nome});
  Future<UserEntity> signInWithGoogle();
  Future<void> sendEmailVerification();
  Future<bool> reloadAndCheckEmailVerified();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
}
