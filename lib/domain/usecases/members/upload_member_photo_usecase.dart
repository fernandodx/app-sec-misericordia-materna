import 'dart:typed_data';
import '../../../core/utils/image_compressor.dart';

class UploadMemberPhotoUseCase {
  UploadMemberPhotoUseCase();

  Future<String> call({
    required String userId,
    required Uint8List rawImageBytes,
  }) async {
    // Redimensiona para 256x256 e comprime (ficando tipicamente entre 15KB e 30KB)
    final compressedBytes = await ImageCompressor.compressImage(
      rawImageBytes,
      maxWidth: 256,
      maxHeight: 256,
      targetQuality: 75,
    );
    // Retorna como Data URI base64 seguro para armazenar diretamente no Firestore
    return ImageCompressor.toBase64DataUri(compressedBytes);
  }
}
