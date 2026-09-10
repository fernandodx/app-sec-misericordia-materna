import 'dart:typed_data';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/storage_remote_datasource.dart';

class StorageRepositoryImpl implements StorageRepository {
  final StorageRemoteDataSource _dataSource;

  StorageRepositoryImpl(this._dataSource);

  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List imageBytes,
  }) {
    return _dataSource.uploadAvatar(
      userId: userId,
      imageBytes: imageBytes,
    );
  }
}
