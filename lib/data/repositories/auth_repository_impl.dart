import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/firestore_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final FirestoreRemoteDataSource firestoreRemoteDataSource;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.firestoreRemoteDataSource,
  });

  @override
  Stream<UserEntity?> authStateChanges() {
    return authRemoteDataSource.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return firestoreRemoteDataSource.bootstrapOrCreateUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        isEmailVerified: firebaseUser.emailVerified,
      );
    });
  }

  @override
  UserEntity? getCurrentUser() {
    final fbUser = authRemoteDataSource.currentUser;
    if (fbUser == null) return null;
    return null;
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    final fbUser = await authRemoteDataSource.signInWithEmail(email, password);
    return firestoreRemoteDataSource.bootstrapOrCreateUser(
      uid: fbUser.uid,
      email: fbUser.email ?? email,
      displayName: fbUser.displayName,
      photoUrl: fbUser.photoURL,
      isEmailVerified: fbUser.emailVerified,
    );
  }

  @override
  Future<UserEntity> registerWithEmail(String email, String password, {String? nome}) async {
    final fbUser = await authRemoteDataSource.registerWithEmail(email, password, nome: nome);
    return firestoreRemoteDataSource.bootstrapOrCreateUser(
      uid: fbUser.uid,
      email: fbUser.email ?? email,
      displayName: (nome != null && nome.trim().isNotEmpty) ? nome.trim() : fbUser.displayName,
      photoUrl: fbUser.photoURL,
      isEmailVerified: fbUser.emailVerified,
    );
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final fbUser = await authRemoteDataSource.signInWithGoogle();
    return firestoreRemoteDataSource.bootstrapOrCreateUser(
      uid: fbUser.uid,
      email: fbUser.email ?? '',
      displayName: fbUser.displayName,
      photoUrl: fbUser.photoURL,
      isEmailVerified: fbUser.emailVerified,
    );
  }

  @override
  Future<void> sendEmailVerification() =>
      authRemoteDataSource.sendEmailVerification();

  @override
  Future<bool> reloadAndCheckEmailVerified() =>
      authRemoteDataSource.reloadAndCheckEmailVerified();

  @override
  Future<void> sendPasswordReset(String email) =>
      authRemoteDataSource.sendPasswordReset(email);

  @override
  Future<void> signOut() => authRemoteDataSource.signOut();
}
