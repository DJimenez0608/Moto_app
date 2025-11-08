import 'package:flutter/material.dart';
import 'package:moto_app/domain/models/maintenance.dart';
import 'package:moto_app/features/auth/data/datasources/maintenance_http_service.dart';

class MaintenanceProvider extends ChangeNotifier {
  final Map<int, List<Maintenance>> _maintenanceByMotorcycle = {};
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Maintenance> maintenanceForMotorcycle(int motorcycleId) =>
      _maintenanceByMotorcycle[motorcycleId] ?? [];

  List<Maintenance> get allMaintenance =>
      _maintenanceByMotorcycle.values.expand((list) => list).toList();

  Future<void> getMaintenance(int motorcycleId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final maintenanceMaps =
          await MaintenanceHttpService().getMaintenance(motorcycleId);
      _maintenanceByMotorcycle[motorcycleId] = maintenanceMaps
          .map((maintenance) => Maintenance.fromJson(maintenance))
          .toList();
    } catch (e) {
      _maintenanceByMotorcycle.remove(motorcycleId);
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMaintenance() {
    _maintenanceByMotorcycle.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
