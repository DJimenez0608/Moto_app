import 'package:shared_preferences/shared_preferences.dart';

class BudgetService {
  static String _getBudgetKey(int year) => 'budget_$year';
  static String _getBudgetWarningReadKey(int year) => 'budget_warning_read_$year';

  /// Guarda el presupuesto para un año específico
  static Future<void> saveBudget(int year, double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_getBudgetKey(year), budget);
    await prefs.reload();
  }

  /// Obtiene el presupuesto para un año específico
  /// Retorna null si no existe
  static Future<double?> getBudget(int year) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getDouble(_getBudgetKey(year));
  }

  /// Marca la advertencia de presupuesto como leída para un año específico
  /// Esto solo afecta la visibilidad en el home screen, no en la pantalla de gastos
  static Future<void> markBudgetWarningAsRead(int year) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getBudgetWarningReadKey(year), true);
    await prefs.reload();
  }

  /// Verifica si la advertencia de presupuesto fue marcada como leída para un año específico
  static Future<bool> isBudgetWarningRead(int year) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getBool(_getBudgetWarningReadKey(year)) ?? false;
  }

  /// Limpia el estado de "leído" para un año específico (útil para resetear)
  static Future<void> clearBudgetWarningRead(int year) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getBudgetWarningReadKey(year));
    await prefs.reload();
  }

  /// Elimina el presupuesto de un año específico
  static Future<void> deleteBudget(int year) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getBudgetKey(year));
    await prefs.reload();
  }
}

