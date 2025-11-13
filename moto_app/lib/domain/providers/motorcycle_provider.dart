import 'package:flutter/material.dart';
import 'package:moto_app/domain/models/motorcycle.dart';
import 'package:moto_app/features/auth/data/datasources/motorcycle_http_service.dart';
import 'package:moto_app/domain/providers/user_provider.dart';

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

  Future<void> getMotorcycles(int id) async {
    final motorcycles = await MotorcycleHttpService().getMotorcycles(id);
    if (motorcycles != null) {
      setMotorcycles(motorcycles.map((e) => Motorcycle.fromJson(e)).toList());
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
      final message = await MotorcycleHttpService().deleteMotorcycle(
        motorcycleId,
      );

      final currentUser = userProvider.user;
      if (currentUser != null) {
        await getMotorcycles(currentUser.id);
      }

      return message;
    } catch (error) {
      _motorcycles.insert(index, removedMotorcycle);
      notifyListeners();
      rethrow;
    }
  }
}
