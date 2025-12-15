import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageCompressionService {
  static Future<File> compressImage(File imageFile, {int quality = 70}) async {
    try {
      final filePath = imageFile.absolute.path;
      final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = '${splitted}_out${filePath.substring(lastIndex)}';
      
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: quality,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );

      if (compressedFile != null) {
        if (kDebugMode) {
          final originalSize = await imageFile.length();
          final compressedSize = await compressedFile.length();
          debugPrint('Imagen comprimida: ${(originalSize / 1024).toStringAsFixed(2)} KB → ${(compressedSize / 1024).toStringAsFixed(2)} KB');
        }
        return File(compressedFile.path);
      } else {
        if (kDebugMode) {
          debugPrint('La compresión retornó null, usando imagen original');
        }
        return imageFile;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al comprimir imagen: $e. Usando imagen original.');
      }
      // Si falla la compresión, retornar imagen original
      return imageFile;
    }
  }

  static Future<File> compressAndSaveToTemp(File imageFile, {int quality = 70}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basename(imageFile.path);
      final targetPath = path.join(tempDir.path, 'compressed_$fileName');
      
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );

      if (compressedFile != null) {
        if (kDebugMode) {
          final originalSize = await imageFile.length();
          final compressedSize = await compressedFile.length();
          debugPrint('Imagen comprimida: ${(originalSize / 1024).toStringAsFixed(2)} KB → ${(compressedSize / 1024).toStringAsFixed(2)} KB');
        }
        return File(compressedFile.path);
      } else {
        if (kDebugMode) {
          debugPrint('La compresión retornó null, usando imagen original');
        }
        return imageFile;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al comprimir imagen: $e. Usando imagen original.');
      }
      return imageFile;
    }
  }
}

