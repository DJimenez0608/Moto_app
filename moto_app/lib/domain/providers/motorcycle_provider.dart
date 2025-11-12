import 'package:flutter/material.dart';
import 'package:moto_app/domain/models/motorcycle.dart';
import 'package:moto_app/features/auth/data/datasources/motorcycle_http_service.dart';

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
}
