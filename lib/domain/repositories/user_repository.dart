import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getUserById(String id);
  Future<UserEntity?> getUserByEmail(String email);
  Future<void> saveUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
  Stream<UserEntity?> userStream(String id);
  Future<UserEntity> bootstrapOrCreateUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  });
  Future<void> saveUserPartial(String userId, Map<String, dynamic> data);
  Future<List<UserEntity>> searchUsersByName(String query, {String? excludeUserId});
  Future<List<UserEntity>> getAllUsers();
  Future<void> linkSpouse({required String userId, required String spouseId});
}
