import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moto_app/domain/models/motorcycle.dart';
import 'package:moto_app/features/auth/data/datasources/motorcycle_http_service.dart';
import 'package:moto_app/domain/providers/user_provider.dart';
import 'package:moto_app/features/auth/data/services/firebase_storage_service.dart';

class MotorcycleProvider extends ChangeNotifier {
  List<Motorcycle> _motorcycles = [];
  List<Motorcycle> get motorcycles => _motorcycles;

  void setMotorcycles(List<Motorcycle> motorcycles) {
    _motorcycles = motorcycles;
    notifyListeners();
  }

  List<Motorcycle> searchMotorcyclesByMake(String query) {
    if (query.trim().isEmpty) {
      return List.unmodifiable(_motorcycles);
    }

    final normalizedQuery = query.trim().toLowerCase();
    return _motorcycles
        .where(
          (motorcycle) =>
              motorcycle.make.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);
  }

  void clearMotorcycles() {
    _motorcycles = [];
    notifyListeners();
  }

  Future<void> getMotorcycles(int id, String username) async {
    final motorcyclesData = await MotorcycleHttpService().getMotorcycles(id);
    if (motorcyclesData != null) {
      final motorcycles =
          motorcyclesData.map((e) => Motorcycle.fromJson(e)).toList();

      // Cargar fotos desde Firebase Storage para cada moto
      final storageService = FirebaseStorageService();
      final motorcyclesWithPhotos = await Future.wait(
        motorcycles.map((motorcycle) async {
          try {
            final photoUrl = await storageService.getMotorcyclePhotoUrl(
              username: username,
              make: motorcycle.make,
              model: motorcycle.model,
              year: motorcycle.year,
            );

            // Crear nueva instancia de Motorcycle con la foto
            return Motorcycle(
              id: motorcycle.id,
              make: motorcycle.make,
              model: motorcycle.model,
              year: motorcycle.year,
              power: motorcycle.power,
              torque: motorcycle.torque,
              type: motorcycle.type,
              displacement: motorcycle.displacement,
              fuelCapacity: motorcycle.fuelCapacity,
              weight: motorcycle.weight,
              userId: motorcycle.userId,
              photo: photoUrl,
            );
          } catch (e) {
            // Si hay error al obtener foto, mantener la moto sin foto
            return motorcycle;
          }
        }),
      );

      setMotorcycles(motorcyclesWithPhotos);
    } else {
      throw Exception('Error al obtener las motos');
    }
  }

  Future<String> deleteMotorcycle({
    required int motorcycleId,
    required UserProvider userProvider,
  }) async {
    final index = _motorcycles.indexWhere(
      (motorcycle) => motorcycle.id == motorcycleId,
    );

    if (index == -1) {
      throw Exception('Motocicleta no encontrada');
    }

    final removedMotorcycle = _motorcycles.removeAt(index);
    notifyListeners();

    try {
      // Eliminar fotos de Firebase Storage antes de eliminar la moto del backend
      final username = userProvider.user?.username;
      if (username != null) {
        try {
          await FirebaseStorageService().deleteMotorcyclePhotos(
            username: username,
            make: removedMotorcycle.make,
            model: removedMotorcycle.model,
            year: removedMotorcycle.year,
          );
        } catch (e) {
          // No lanzar error - continuar con la eliminación de la moto
          if (kDebugMode) {
            debugPrint('Error al eliminar fotos de Firebase Storage: $e');
          }
        }
      }

      final message = await MotorcycleHttpService().deleteMotorcycle(
        motorcycleId,
      );

      final currentUser = userProvider.user;
      if (currentUser != null) {
        await getMotorcycles(currentUser.id, currentUser.username);
      }

      return message;
    } catch (error) {
      _motorcycles.insert(index, removedMotorcycle);
      notifyListeners();
      rethrow;
    }
  }
}
