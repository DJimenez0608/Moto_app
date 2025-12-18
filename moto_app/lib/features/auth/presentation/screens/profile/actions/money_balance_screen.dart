import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moto_app/core/constants/app_constants.dart';
import 'package:moto_app/domain/providers/gastos_provider.dart';
import 'package:moto_app/domain/providers/user_provider.dart';
import 'package:moto_app/domain/providers/motorcycle_provider.dart';
import 'package:moto_app/features/auth/data/services/budget_service.dart';
import 'package:moto_app/features/auth/data/datasources/soat_http_service.dart';
import 'package:moto_app/domain/models/motorcycle.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MoneyBalanceScreen extends StatefulWidget {
  const MoneyBalanceScreen({super.key});

  @override
  State<MoneyBalanceScreen> createState() => _MoneyBalanceScreenState();
}

class _MoneyBalanceScreenState extends State<MoneyBalanceScreen> 
    with WidgetsBindingObserver {
  int _selectedYear = DateTime.now().year;
  int _touchedIndex = -1;

  // Colores para cada categoría
  static const Color _soatColor = Color(0xFFE57373);
  static const Color _tecnicomecanicaColor = Color(0xFFF59E0B);
  static const Color _maintenanceColor = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGastos();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recargar gastos cuando la app vuelve al foreground
      _loadGastos();
    }
  }

  Future<void> _loadGastos() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
    
    final user = userProvider.user;
    if (user != null) {
      await gastosProvider.loadGastos(user.id);
      
      if (mounted) {
        final availableYears = gastosProvider.getAvailableYears();
        if (availableYears.isNotEmpty && !availableYears.contains(_selectedYear)) {
          setState(() {
            _selectedYear = availableYears.first;
          });
        }
      }
    }
  }

  List<_ExpenseSlice> _getSlices(GastosProvider gastosProvider) {
    final percentages = gastosProvider.getPercentagesByYear(_selectedYear);
    
    return [
      _ExpenseSlice(
        label: 'SOAT',
        value: percentages['soat'] ?? 0.0,
        color: _soatColor,
      ),
      _ExpenseSlice(
        label: 'Tecnicomecánica',
        value: percentages['tecnicomecanica'] ?? 0.0,
        color: _tecnicomecanicaColor,
      ),
      _ExpenseSlice(
        label: 'Mantenimientos',
        value: percentages['maintenance'] ?? 0.0,
        color: _maintenanceColor,
      ),
    ];
  }

  String _getFormattedTotal(double total) {
    final rounded = total.toStringAsFixed(0);
    final buffer = StringBuffer();
    final chars = rounded.split('').reversed.toList();
    for (int i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write(',');
      buffer.write(chars[i]);
    }
    final formatted = buffer.toString().split('').reversed.join();
    return '\$ $formatted';
  }

  Widget _buildSoatWarningCard(BuildContext context, GastosProvider gastosProvider) {
    final expiredSoats = gastosProvider.getExpiredSoatMotorcycles();
    if (expiredSoats.isEmpty) {
      return const SizedBox.shrink();
    }

    final motorcycleProvider = Provider.of<MotorcycleProvider>(context, listen: false);
    final motorcycles = motorcycleProvider.motorcycles;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
        border: Border.all(
          color: Colors.orange.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'SOAT vencido',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...expiredSoats.map((expiredSoat) {
            final motorcycleId = expiredSoat['motorcycleId'] as int;
            final lastEndDate = expiredSoat['lastEndDate'] as DateTime?;
            final motorcycle = motorcycles.firstWhere(
              (m) => m.id == motorcycleId,
              orElse: () => Motorcycle(
                id: motorcycleId,
                make: 'Desconocida',
                model: '',
                year: 0,
                power: 0,
                torque: 0,
                type: '',
                fuelCapacity: '',
                weight: 0,
                userId: 0,
              ),
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${motorcycle.make} ${motorcycle.model} ${motorcycle.year}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (lastEndDate != null)
                          Text(
                            'Último SOAT vencido: ${DateFormat('dd/MM/yyyy').format(lastEndDate)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          )
                        else
                          Text(
                            'No tiene SOAT registrado',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddSoatDialog(context, motorcycle),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Lo pagué'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _showAddSoatDialog(BuildContext context, Motorcycle motorcycle) async {
    final costController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    bool isLoading = false;

    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Registrar nuevo SOAT'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Moto: ${motorcycle.make} ${motorcycle.model} ${motorcycle.year}'),
                const SizedBox(height: 16),
                TextField(
                  controller: costController,
                  decoration: const InputDecoration(
                    labelText: 'Costo',
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    startDate == null
                        ? 'Seleccionar fecha de inicio'
                        : 'Inicio: ${DateFormat('dd/MM/yyyy').format(startDate!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() => startDate = picked);
                    }
                  },
                ),
                ListTile(
                  title: Text(
                    endDate == null
                        ? 'Seleccionar fecha de fin'
                        : 'Fin: ${DateFormat('dd/MM/yyyy').format(endDate!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate?.add(const Duration(days: 365)) ?? DateTime.now(),
                      firstDate: startDate ?? DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() => endDate = picked);
                    }
                  },
                ),
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (costController.text.isEmpty ||
                          startDate == null ||
                          endDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor complete todos los campos'),
                          ),
                        );
                        return;
                      }

                      final cost = double.tryParse(costController.text);
                      if (cost == null || cost <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('El costo debe ser un número válido mayor a 0'),
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      try {
                        await SoatHttpService().addSoat(
                          motorcycle.id,
                          startDate!,
                          endDate!,
                          cost,
                        );

                        if (!context.mounted) return;

                        // Recargar gastos
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        final gastosProvider = Provider.of<GastosProvider>(context, listen: false);
                        final user = userProvider.user;
                        if (user != null) {
                          await gastosProvider.loadGastos(user.id);
                        }

                        Navigator.pop(context, true);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('SOAT registrado exitosamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetWarningCard(BuildContext context, GastosProvider gastosProvider, double? budget) {
    if (budget == null) {
      return const SizedBox.shrink();
    }

    final total = gastosProvider.getTotalByYear(_selectedYear);
    final isExceeded = total > budget;

    if (!isExceeded) {
      return const SizedBox.shrink();
    }

    final difference = total - budget;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
        border: Border.all(
          color: Colors.red.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Presupuesto excedido',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Has superado tu presupuesto de ${_getFormattedTotal(budget)} por ${_getFormattedTotal(difference)}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Future<void> _showBudgetDialog(BuildContext context) async {
    final currentYear = DateTime.now().year;
    final currentBudget = await BudgetService.getBudget(currentYear);
    final budgetController = TextEditingController(
      text: currentBudget?.toStringAsFixed(0) ?? '',
    );
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Presupuesto ${currentYear}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (currentBudget != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Presupuesto actual: ${_getFormattedTotal(currentBudget)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                TextField(
                  controller: budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Presupuesto anual',
                    prefixText: '\$ ',
                    helperText: 'Ingrese el presupuesto para este año',
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (budgetController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor ingrese un presupuesto'),
                          ),
                        );
                        return;
                      }

                      final budget = double.tryParse(budgetController.text);
                      if (budget == null || budget <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('El presupuesto debe ser un número válido mayor a 0'),
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      try {
                        await BudgetService.saveBudget(currentYear, budget);

                        if (!context.mounted) return;

                        Navigator.pop(context);
                        setState(() {}); // Actualizar UI

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Presupuesto guardado exitosamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnualSummaryCard(BuildContext context, GastosProvider gastosProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = colorScheme.primary;
    final years = gastosProvider.getAvailableYears();
    final availableYears = years.isEmpty ? [DateTime.now().year] : years;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
        border: Border.all(
          color: accentColor.withOpacity(0.35),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 18,
            spreadRadius: 2.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Gastos anuales totales',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              DropdownButton<int>(
                value: availableYears.contains(_selectedYear) 
                    ? _selectedYear 
                    : (availableYears.isNotEmpty ? availableYears.first : DateTime.now().year),
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadius * 1.5,
                ),
                underline: const SizedBox.shrink(),
                items: availableYears
                    .map(
                      (year) => DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedYear = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_getFormattedTotal(gastosProvider.getTotalByYear(_selectedYear))} COP ',
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(BuildContext context, GastosProvider gastosProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final slices = _getSlices(gastosProvider);
    final total = gastosProvider.getTotalByYear(_selectedYear);
    
    // Si no hay gastos, mostrar mensaje
    if (total == 0.0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              offset: const Offset(0, 12),
              blurRadius: 32,
              spreadRadius: -8,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No hay gastos registrados para el año $_selectedYear',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            offset: const Offset(0, 12),
            blurRadius: 32,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.28,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 48,
                  pieTouchData: PieTouchData(
                    touchCallback: (
                      FlTouchEvent event,
                      PieTouchResponse? response,
                    ) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sections: List.generate(slices.length, (index) {
                    final slice = slices[index];
                    final isTouched = index == _touchedIndex;
                    final double radius = isTouched ? 86 : 72;
                    final double fontSize = isTouched ? 18 : 14;

                    return PieChartSectionData(
                      color: slice.color,
                      value: slice.value,
                      title: '${slice.value.toInt()}%',
                      radius: radius,
                      titleStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: fontSize,
                      ),
                      badgeWidget:
                          isTouched
                              ? _PieBadge(
                                label: slice.label,
                                color: slice.color,
                              )
                              : null,
                      badgePositionPercentageOffset: 1.2,
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _PieLegend(
              slices: slices,
              touchedIndex: _touchedIndex,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos de la moto')),
      body: Consumer<GastosProvider>(
        builder: (context, gastosProvider, _) {
          if (gastosProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (gastosProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      gastosProvider.errorMessage!,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _loadGastos(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return FutureBuilder<double?>(
            future: BudgetService.getBudget(_selectedYear),
            builder: (context, budgetSnapshot) {
              final budget = budgetSnapshot.data;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSoatWarningCard(context, gastosProvider),
                      _buildBudgetWarningCard(context, gastosProvider, budget),
                      _buildAnnualSummaryCard(context, gastosProvider),
                      const SizedBox(height: 24),
                      _buildPieChartCard(context, gastosProvider),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showBudgetDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius * 1.2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: const Text(
                            'Establecer presupuesto',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ExpenseSlice {
  const _ExpenseSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _PieBadge extends StatelessWidget {
  const _PieBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PieLegend extends StatelessWidget {
  const _PieLegend({
    required this.slices,
    required this.touchedIndex,
  });

  final List<_ExpenseSlice> slices;
  final int touchedIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: slices.asMap().entries.map((entry) {
        final index = entry.key;
        final slice = entry.value;
        final bool isActive = index == touchedIndex;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color:
                    isActive
                        ? slice.color.withOpacity(0.1)
                        : colorScheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color:
                      isActive
                          ? slice.color
                          : colorScheme.surfaceVariant.withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: slice.color,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            slice.label,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${slice.value.toInt()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
