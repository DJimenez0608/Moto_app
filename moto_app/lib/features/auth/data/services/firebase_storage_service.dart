import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static String _buildMotorcyclePhotoPath(
    String username,
    String make,
    String model,
    int year,
  ) {
    // Construir path: users/username/motos-registradas/marca-modelo-año/
    final folderName = '${make.toLowerCase()}-${model.toLowerCase()}-$year';
    return 'users/$username/motos-registradas/$folderName/foto.jpg';
  }

  Future<String> uploadMotorcyclePhoto({
    required String username,
    required String make,
    required String model,
    required int year,
    required File imageFile,
  }) async {
    try {
      final path = _buildMotorcyclePhotoPath(username, make, model, year);
      final ref = FirebaseStorage.instance.ref().child(path);
      
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      
      if (kDebugMode) {
        debugPrint('Foto subida exitosamente a: $path');
        debugPrint('URL de descarga: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error al subir foto a Firebase Storage: $e');
      }
      throw Exception('Error al subir la foto: $e');
    }
  }

  Future<String?> getMotorcyclePhotoUrl({
    required String username,
    required String make,
    required String model,
    required int year,
  }) async {
    try {
      final path = _buildMotorcyclePhotoPath(username, make, model, year);
      final ref = FirebaseStorage.instance.ref().child(path);
      
      final url = await ref.getDownloadURL();
      
      if (kDebugMode) {
        debugPrint('Foto encontrada en: $path');
      }
      
      return url;
    } catch (e) {
      // Si no existe la foto, retornar null (no es un error crítico)
      if (kDebugMode) {
        debugPrint('No se encontró foto en: users/$username/motos-registradas/${make.toLowerCase()}-${model.toLowerCase()}-$year/');
        debugPrint('Error: $e');
      }
      return null;
    }
  }

  Future<void> deleteMotorcyclePhotos({
    required String username,
    required String make,
    required String model,
    required int year,
  }) async {
    try {
      final folderName = '${make.toLowerCase()}-${model.toLowerCase()}-$year';
      final folderPath = 'users/$username/motos-registradas/$folderName';
      final folderRef = FirebaseStorage.instance.ref().child(folderPath);
      
      // Listar todos los archivos en la carpeta
      final listResult = await folderRef.listAll();
      
      // Eliminar cada archivo
      await Future.wait(
        listResult.items.map((item) => item.delete()),
      );
      
      if (kDebugMode) {
        debugPrint('Fotos de moto eliminadas de: $folderPath');
      }
    } catch (e) {
      // No lanzar error - la eliminación de la moto debe continuar
      if (kDebugMode) {
        debugPrint('Error al eliminar fotos de Firebase Storage: $e');
        debugPrint('Path intentado: users/$username/motos-registradas/${make.toLowerCase()}-${model.toLowerCase()}-$year/');
      }
    }
  }
}

