import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/firestore_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirestoreRemoteDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity?> getUserById(String id) => _dataSource.getUserById(id);

  @override
  Future<UserEntity?> getUserByEmail(String email) =>
      _dataSource.getUserByEmail(email);

  @override
  Future<void> saveUser(UserEntity user) =>
      _dataSource.saveUser(UserModel.fromEntity(user));

  @override
  Future<void> updateUser(UserEntity user) =>
      _dataSource.saveUser(UserModel.fromEntity(user));

  @override
  Stream<UserEntity?> userStream(String id) => _dataSource.userStream(id);

  @override
  Future<UserEntity> bootstrapOrCreateUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    bool isEmailVerified = false,
  }) {
    return _dataSource.bootstrapOrCreateUser(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isEmailVerified: isEmailVerified,
    );
  }

  @override
  Future<void> saveUserPartial(String userId, Map<String, dynamic> data) =>
      _dataSource.saveUserPartial(userId, data);

  @override
  Future<List<UserEntity>> searchUsersByName(String query, {String? excludeUserId}) =>
      _dataSource.searchUsersByName(query, excludeUserId: excludeUserId);

  @override
  Future<List<UserEntity>> getAllUsers() => _dataSource.getAllUsers();

  @override
  Future<void> linkSpouse({required String userId, required String spouseId}) =>
      _dataSource.linkSpouse(userId: userId, spouseId: spouseId);
}
