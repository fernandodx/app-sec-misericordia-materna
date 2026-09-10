import '../../domain/entities/invite_entity.dart';
import '../../domain/repositories/invite_repository.dart';
import '../datasources/firestore_remote_datasource.dart';
import '../models/invite_model.dart';

class InviteRepositoryImpl implements InviteRepository {
  final FirestoreRemoteDataSource _dataSource;

  InviteRepositoryImpl(this._dataSource);

  @override
  Future<void> createInvite(InviteEntity invite) {
    return _dataSource.createInvite(InviteModel.fromEntity(invite));
  }

  @override
  Future<InviteEntity?> getInviteByCode(String code) {
    return _dataSource.getInviteByCode(code);
  }

  @override
  Future<void> acceptInvite(String code, String userId) {
    return _dataSource.acceptInvite(code, userId);
  }

  @override
  Future<void> revokeInvite(String code) {
    return _dataSource.revokeInvite(code);
  }

  @override
  Future<List<InviteEntity>> listInvites() {
    return _dataSource.listInvites();
  }

  @override
  Future<InviteEntity?> findPendingInviteForEmail(String email) {
    return _dataSource.findPendingInviteForEmail(email);
  }
}
