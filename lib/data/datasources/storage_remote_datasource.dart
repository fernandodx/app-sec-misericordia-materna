import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/errors/failures.dart';

class StorageRemoteDataSource {
  final FirebaseStorage _storage;

  StorageRemoteDataSource({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadAvatar({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    try {
      final ref = _storage.ref().child('avatars').child('$userId.jpg');
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
      );

      final uploadTask = await ref.putData(imageBytes, metadata).timeout(const Duration(seconds: 8));
      final downloadUrl = await uploadTask.ref.getDownloadURL().timeout(const Duration(seconds: 5));
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageFailure('Erro ao enviar imagem ao Firebase Storage: ${e.message}');
    } catch (e) {
      throw StorageFailure('Erro inesperado no upload: $e');
    }
  }
}
