import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/image_compressor.dart';

class UploadMemberPhotoUseCase {
  UploadMemberPhotoUseCase();

  Future<Either<Failure, String>> call({
    required String userId,
    required Uint8List rawImageBytes,
  }) {
    return TaskEither<Failure, String>.tryCatch(
      () async {
        // Redimensiona para 256x256 e comprime (ficando tipicamente entre 15KB e 30KB)
        final compressedBytes = await ImageCompressor.compressImage(
          rawImageBytes,
          maxWidth: 256,
          maxHeight: 256,
          targetQuality: 75,
        );
        // Retorna como Data URI base64 seguro para armazenar diretamente no Firestore
        return ImageCompressor.toBase64DataUri(compressedBytes);
      },
      (error, _) => Failure.fromException(error),
    ).run();
  }
}
