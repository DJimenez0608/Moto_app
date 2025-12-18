import 'package:flutter/foundation.dart';
import 'package:moto_app/features/auth/data/datasources/gasto_http_service.dart';

class GastosProvider extends ChangeNotifier {
  Map<String, dynamic> _gastosData = {};
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get gastosData => _gastosData;

  Future<void> loadGastos(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _gastosData = await GastoHttpService().getGastosTotales(userId);
      if (kDebugMode) {
        debugPrint('Gastos cargados: $_gastosData');
      }
    } catch (e) {
      _gastosData = {};
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('Error al cargar gastos: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener todos los años disponibles en los gastos
  List<int> getAvailableYears() {
    final Set<int> years = {};
    
    _gastosData.forEach((motoId, gastosPorMoto) {
      final gastos = gastosPorMoto as Map<String, dynamic>;
      
      // SOAT
      final soatList = gastos['soat'] as List<dynamic>? ?? [];
      for (var item in soatList) {
        final fecha = item['fecha'] as String?;
        if (fecha != null) {
          final year = DateTime.parse(fecha).year;
          years.add(year);
        }
      }
      
      // Técnicomecánica
      final tecnicomecanicaList = gastos['tecnicomecanica'] as List<dynamic>? ?? [];
      for (var item in tecnicomecanicaList) {
        final fecha = item['fecha'] as String?;
        if (fecha != null) {
          final year = DateTime.parse(fecha).year;
          years.add(year);
        }
      }
      
      // Mantenimientos
      final maintenanceList = gastos['maintenance'] as List<dynamic>? ?? [];
      for (var item in maintenanceList) {
        final fecha = item['fecha'] as String?;
        if (fecha != null) {
          final year = DateTime.parse(fecha).year;
          years.add(year);
        }
      }
    });
    
    return years.toList()..sort((a, b) => b.compareTo(a));
  }

  // Obtener total de gastos para un año específico
  double getTotalByYear(int year) {
    double total = 0.0;
    
    _gastosData.forEach((motoId, gastosPorMoto) {
      final gastos = gastosPorMoto as Map<String, dynamic>;
      
      // SOAT
      final soatList = gastos['soat'] as List<dynamic>? ?? [];
      for (var item in soatList) {
        final fecha = item['fecha'] as String?;
        if (fecha != null && DateTime.parse(fecha).year == year) {
          total += (item['costo'] as num?)?.toDouble() ?? 0.0;
        }
      }
      
      // Técnicomecánica
      final tecnicomecanicaList = gastos['tecnicomecanica'] as List<dynamic>? ?? [];
      for (var item in tecnicomecanicaList) {
        final fecha = item['fecha'] as String?;
        if (fecha != null && DateTime.parse(fecha).year == year) {
          total += (item['costo'] as num?)?.toDouble() ?? 0.0;
        }
      }
      
      // Mantenimientos
      final maintenanceList = gastos['maintenance'] as List<dynamic>? ?? [];
      for (var item in maintenanceList) {
        final fecha = item['fecha'] as String?;
        if (fecha != null && DateTime.parse(fecha).year == year) {
          total += (item['costo'] as num?)?.toDouble() ?? 0.0;
        }
      }
    });
    
    return total;
  }

  // Obtener total de SOAT para un año específico
  double getSoatTotalByYear(int year) {
    double total = 0.0;
    
    _gastosData.forEach((motoId, gastosPorMoto) {
      final gastos = gastosPorMoto as Map<String, dynamic>;
      final soatList = gastos['soat'] as List<dynamic>? ?? [];
      
      for (var item in soatList) {
        final fecha = item['fecha'] as String?;
        if (fecha != null && DateTime.parse(fecha).year == year) {
          total += (item['costo'] as num?)?.toDouble() ?? 0.0;
        }
      }
    });
    
    return total;
  }

  // Obtener total de técnicomecánica para un año específico
  double getTecnicomecanicaTotalByYear(int year) {
    double total = 0.0;
    
    _gastosData.forEach((motoId, gastosPorMoto) {
      final gastos = gastosPorMoto as Map<String, dynamic>;
      final tecnicomecanicaList = gastos['tecnicomecanica'] as List<dynamic>? ?? [];
      
      for (var item in tecnicomecanicaList) {
        final fecha = item['fecha'] as String?;
        if (fecha != null && DateTime.parse(fecha).year == year) {
          total += (item['costo'] as num?)?.toDouble() ?? 0.0;
        }
      }
    });
    
    return total;
  }

  // Obtener total de mantenimientos para un año específico
  double getMaintenanceTotalByYear(int year) {
    double total = 0.0;
    
    _gastosData.forEach((motoId, gastosPorMoto) {
      final gastos = gastosPorMoto as Map<String, dynamic>;
      final maintenanceList = gastos['maintenance'] as List<dynamic>? ?? [];
      
      for (var item in maintenanceList) {
        final fecha = item['fecha'] as String?;
        if (fecha != null && DateTime.parse(fecha).year == year) {
          total += (item['costo'] as num?)?.toDouble() ?? 0.0;
        }
      }
    });
    
    return total;
  }

  // Obtener porcentajes por categoría para un año específico
  Map<String, double> getPercentagesByYear(int year) {
    final totalYear = getTotalByYear(year);
    
    if (totalYear == 0.0) {
      return {
        'soat': 0.0,
        'tecnicomecanica': 0.0,
        'maintenance': 0.0,
      };
    }
    
    final soatTotal = getSoatTotalByYear(year);
    final tecnicomecanicaTotal = getTecnicomecanicaTotalByYear(year);
    final maintenanceTotal = getMaintenanceTotalByYear(year);
    
    return {
      'soat': (soatTotal / totalYear) * 100,
      'tecnicomecanica': (tecnicomecanicaTotal / totalYear) * 100,
      'maintenance': (maintenanceTotal / totalYear) * 100,
    };
  }

  // Obtener información de motos con SOAT vencido
  // Retorna lista de mapas con: {motorcycleId: int, lastEndDate: DateTime}
  List<Map<String, dynamic>> getExpiredSoatMotorcycles() {
    final List<Map<String, dynamic>> expiredSoats = [];
    final now = DateTime.now();
    
    _gastosData.forEach((motoIdStr, gastosPorMoto) {
      final gastos = gastosPorMoto as Map<String, dynamic>;
      final soatList = gastos['soat'] as List<dynamic>? ?? [];
      
      if (soatList.isEmpty) {
        // Si no hay SOAT registrado, considerar vencido
        expiredSoats.add({
          'motorcycleId': int.parse(motoIdStr),
          'lastEndDate': null,
        });
        return;
      }
      
      // Encontrar el SOAT con el end_date más reciente
      DateTime? lastEndDate;
      for (var item in soatList) {
        final endDateStr = item['end_date'] as String?;
        if (endDateStr != null) {
          try {
            final endDate = DateTime.parse(endDateStr);
            if (lastEndDate == null || endDate.isAfter(lastEndDate)) {
              lastEndDate = endDate;
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Error al parsear fecha end_date: $endDateStr');
            }
          }
        }
      }
      
      // Si no hay end_date válido, usar start_date como referencia
      if (lastEndDate == null) {
        DateTime? lastStartDate;
        for (var item in soatList) {
          final fechaStr = item['fecha'] as String?;
          if (fechaStr != null) {
            try {
              final startDate = DateTime.parse(fechaStr);
              if (lastStartDate == null || startDate.isAfter(lastStartDate)) {
                lastStartDate = startDate;
              }
            } catch (e) {
              if (kDebugMode) {
                debugPrint('Error al parsear fecha: $fechaStr');
              }
            }
          }
        }
        
        // Si encontramos un start_date, asumir que el SOAT dura 1 año
        if (lastStartDate != null) {
          lastEndDate = DateTime(lastStartDate.year + 1, lastStartDate.month, lastStartDate.day);
        }
      }
      
      // Verificar si ha pasado más de un año desde el último end_date
      if (lastEndDate != null) {
        final oneYearAfterEndDate = DateTime(
          lastEndDate.year + 1,
          lastEndDate.month,
          lastEndDate.day,
        );
        
        if (now.isAfter(oneYearAfterEndDate) || now.isAtSameMomentAs(oneYearAfterEndDate)) {
          expiredSoats.add({
            'motorcycleId': int.parse(motoIdStr),
            'lastEndDate': lastEndDate,
          });
        }
      } else {
        // Si no pudimos determinar el end_date, considerar vencido
        expiredSoats.add({
          'motorcycleId': int.parse(motoIdStr),
          'lastEndDate': null,
        });
      }
    });
    
    return expiredSoats;
  }

  // Verificar si hay algún SOAT vencido
  bool hasExpiredSoat() {
    return getExpiredSoatMotorcycles().isNotEmpty;
  }

  // Verificar si el presupuesto fue excedido para un año específico
  // Este método recibe el presupuesto como parámetro (se obtiene del BudgetService)
  bool isBudgetExceeded(int year, double? budget) {
    if (budget == null) {
      return false; // Si no hay presupuesto establecido, no está excedido
    }
    
    final total = getTotalByYear(year);
    return total > budget;
  }

  void clearGastos() {
    _gastosData = {};
    _errorMessage = null;
    notifyListeners();
  }
}

