import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moto_app/domain/models/observation.dart';
import 'package:moto_app/features/auth/data/datasources/observation_http_service.dart';

class ObservationProvider extends ChangeNotifier {
  final Map<int, List<Observation>> _observationsByMotorcycle = {};
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Observation> observationsForMotorcycle(int motorcycleId) =>
      _observationsByMotorcycle[motorcycleId] ?? [];

  List<Observation> get allObservations =>
      _observationsByMotorcycle.values.expand((list) => list).toList();

  Future<void> getObservations(int motorcycleId) async {
    if (kDebugMode) {
      debugPrint('=== ObservationProvider.getObservations ===');
      debugPrint('Motorcycle ID: $motorcycleId');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        debugPrint('Calling ObservationHttpService.getObservations...');
      }

      final observationsMaps = await ObservationHttpService().getObservations(
        motorcycleId,
      );

      if (kDebugMode) {
        debugPrint('Observations received: ${observationsMaps.length}');
        if (observationsMaps.isNotEmpty) {
          debugPrint('First observation keys: ${observationsMaps.first.keys}');
          debugPrint('First observation: ${observationsMaps.first}');
        }
      }

      if (observationsMaps.isEmpty) {
        if (kDebugMode) {
          debugPrint('No observations found, setting empty list');
        }
        _observationsByMotorcycle[motorcycleId] = [];
      } else {
        _observationsByMotorcycle[motorcycleId] =
            observationsMaps.map((observation) {
              try {
                if (kDebugMode) {
                  debugPrint('Parsing observation: $observation');
                }
                final parsed = Observation.fromJson(observation);
                if (kDebugMode) {
                  debugPrint(
                    'Successfully parsed observation ID: ${parsed.id}',
                  );
                }
                return parsed;
              } catch (e, stackTrace) {
                if (kDebugMode) {
                  debugPrint('Error parsing observation: $e');
                  debugPrint('Stack trace: $stackTrace');
                  debugPrint('Observation data: $observation');
                }
                throw Exception(
                  'Error al parsear observación: $e. Datos: $observation',
                );
              }
            }).toList();

        if (kDebugMode) {
          debugPrint(
            'Total observations parsed: ${_observationsByMotorcycle[motorcycleId]?.length}',
          );
        }
      }
    } catch (e, stackTrace) {
      _observationsByMotorcycle.remove(motorcycleId);
      _errorMessage = e.toString();

      if (kDebugMode) {
        debugPrint('=== ERROR getting observations ===');
        debugPrint('Error: $e');
        debugPrint('Error type: ${e.runtimeType}');
        debugPrint('Stack trace: $stackTrace');
      }
    } finally {
      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('=== ObservationProvider.getObservations FINISHED ===');
        debugPrint('isLoading: $_isLoading');
        debugPrint('errorMessage: $_errorMessage');
        debugPrint(
          'observations count: ${_observationsByMotorcycle[motorcycleId]?.length ?? 0}',
        );
      }
    }
  }

  void clearObservations() {
    _observationsByMotorcycle.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
