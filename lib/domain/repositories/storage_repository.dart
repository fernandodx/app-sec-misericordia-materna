import 'dart:typed_data';

abstract class StorageRepository {
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List imageBytes,
  });
}
