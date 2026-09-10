import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageCompressor {
  static const int maxFileSizeBytes = 100 * 1024; // 100 KB máximo estrito para perfil

  /// Comprime e redimensiona a imagem para avatar de alta performance.
  /// Dimensões padrão 256x256 e qualidade otimizada resultam em ~15KB - 30KB.
  static Future<Uint8List> compressImage(
    Uint8List inputBytes, {
    int maxWidth = 256,
    int maxHeight = 256,
    int targetQuality = 75,
  }) async {
    final originalImage = img.decodeImage(inputBytes);
    if (originalImage == null) {
      throw Exception('Não foi possível processar a imagem selecionada.');
    }

    // Redimensionar proporcionalmente para caber em 256x256
    img.Image resized = originalImage;
    if (originalImage.width > maxWidth || originalImage.height > maxHeight) {
      resized = img.copyResize(
        originalImage,
        width: originalImage.width > originalImage.height ? maxWidth : null,
        height: originalImage.height >= originalImage.width ? maxHeight : null,
        interpolation: img.Interpolation.linear,
      );
    }

    int quality = targetQuality;
    Uint8List compressed = Uint8List.fromList(img.encodeJpg(resized, quality: quality));

    while (compressed.lengthInBytes > maxFileSizeBytes && quality > 20) {
      quality -= 15;
      compressed = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    }

    return compressed;
  }

  /// Converte bytes da imagem comprimida em uma Data URI Base64 pronta para salvar no Firestore
  /// Ex: data:image/jpeg;base64,...
  static String toBase64DataUri(Uint8List compressedBytes) {
    final base64String = base64Encode(compressedBytes);
    return 'data:image/jpeg;base64,$base64String';
  }
}
