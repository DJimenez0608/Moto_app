import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:moto_app/core/constants/app_constants.dart';
import 'package:moto_app/core/theme/app_colors.dart';
import 'package:moto_app/domain/models/motorcycle.dart';
import 'package:moto_app/domain/providers/motorcycle_provider.dart';
import 'package:moto_app/features/auth/data/datasources/observation_http_service.dart';
import 'package:moto_app/features/auth/data/datasources/maintenance_http_service.dart';

class MotorcycleDetailScreen extends StatefulWidget {
  const MotorcycleDetailScreen({
    super.key,
    required this.motorcycleId,
    required this.imagePath,
    required this.heroTag,
  });

  final int motorcycleId;
  final String imagePath;
  final String heroTag;

  @override
  State<MotorcycleDetailScreen> createState() => _MotorcycleDetailScreenState();
}

class _MotorcycleDetailScreenState extends State<MotorcycleDetailScreen> {
  Future<void> _showOptionsDialog(
    BuildContext context,
    Motorcycle motorcycle,
  ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showDialog(
      context: context,
      barrierDismissible: true, // Permite cerrar haciendo clic fuera
      builder:
          (dialogContext) => AlertDialog(
            title: Align(
              alignment: Alignment.center,
              child: Text('${motorcycle.make} ${motorcycle.model}'),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _showAddObservationDialog(context, motorcycle);
                  },
                  icon: const Icon(Icons.note_add),
                  label: const Text('Observaciones'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _showAddMaintenanceDialog(context, motorcycle);
                  },
                  icon: const Icon(Icons.build),
                  label: const Text('Mantenimiento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _showAddMaintenanceDialog(
    BuildContext context,
    Motorcycle motorcycle,
  ) async {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController costController = TextEditingController();
    DateTime? selectedDate;
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) {
              final theme = Theme.of(context);

              return AlertDialog(
                title: Align(
                  alignment: Alignment.center,
                  child: Text('${motorcycle.make} ${motorcycle.model}'),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Campo de descripción
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            hintText:
                                'Haga la descripción de lo que se le hizo a su motocicleta',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                            ),
                          ),
                          maxLines: 5,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16),
                        // Campo de costo
                        TextField(
                          controller: costController,
                          decoration: InputDecoration(
                            labelText: 'Costo del mantenimiento',
                            hintText: 'COP',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16),
                        // Campo de fecha
                        Text(
                          'Fecha del mantenimiento:',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _DateSelectionRow(
                          displayText: _formatDate(selectedDate),
                          onPressed:
                              isLoading
                                  ? null
                                  : () => _selectDate(
                                    context: context,
                                    currentValue: selectedDate,
                                    onDateSelected: (value) {
                                      setDialogState(() {
                                        selectedDate = value;
                                      });
                                    },
                                  ),
                        ),
                        if (isLoading) ...[
                          const SizedBox(height: 16),
                          const CircularProgressIndicator(),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed:
                        isLoading
                            ? null
                            : () {
                              Navigator.pop(context);
                            },
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              final descriptionText =
                                  descriptionController.text.trim();
                              final costText = costController.text.trim();

                              // Validaciones
                              if (descriptionText.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Por favor ingrese una descripción',
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (costText.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Por favor ingrese el costo'),
                                  ),
                                );
                                return;
                              }

                              if (selectedDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Por favor seleccione una fecha',
                                    ),
                                  ),
                                );
                                return;
                              }

                              double costValue;
                              try {
                                costValue = double.parse(costText);
                                if (costValue < 0) {
                                  throw FormatException('Costo negativo');
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Por favor ingrese un costo válido',
                                    ),
                                  ),
                                );
                                return;
                              }

                              setDialogState(() {
                                isLoading = true;
                              });

                              try {
                                await MaintenanceHttpService().addMaintenance(
                                  motorcycle.id,
                                  selectedDate!,
                                  descriptionText,
                                  costValue,
                                );

                                if (!context.mounted) {
                                  setDialogState(() {
                                    isLoading = false;
                                  });
                                  return;
                                }

                                setDialogState(() {
                                  isLoading = false;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Mantenimiento agregado exitosamente',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                Navigator.pop(context);
                              } catch (e) {
                                if (!context.mounted) return;

                                setDialogState(() {
                                  isLoading = false;
                                });

                                final errorMessage = e.toString().replaceAll(
                                  'Exception: ',
                                  '',
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              } finally {
                                // Asegurar que isLoading siempre se establezca en false
                                if (mounted) {
                                  setDialogState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                    child: const Text('Crear'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Future<void> _selectDate({
    required BuildContext context,
    required DateTime? currentValue,
    required void Function(DateTime date) onDateSelected,
  }) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 2, now.month, now.day);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentValue ?? now,
      firstDate: firstDate,
      lastDate: now,
    );

    if (selectedDate != null) {
      onDateSelected(selectedDate);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Elegir una fecha';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _showAddObservationDialog(
    BuildContext context,
    Motorcycle motorcycle,
  ) async {
    final TextEditingController observationController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Align(
                  alignment: Alignment.center,
                  child: Text('${motorcycle.make} ${motorcycle.model}'),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: observationController,
                        decoration: InputDecoration(
                          hintText:
                              'Escriba su observación aca para luego indicarle a su mecánico',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                        ),
                        maxLines: 5,
                        enabled: !isLoading,
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
                    onPressed:
                        isLoading
                            ? null
                            : () {
                              Navigator.pop(context);
                            },
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              final observationText =
                                  observationController.text.trim();

                              if (observationText.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Por favor ingrese una observación',
                                    ),
                                  ),
                                );
                                return;
                              }

                              setDialogState(() {
                                isLoading = true;
                              });

                              try {
                                await ObservationHttpService().addObservation(
                                  motorcycle.id,
                                  observationText,
                                );

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Observación agregada exitosamente',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                Navigator.pop(context);
                              } catch (e) {
                                if (!context.mounted) return;

                                setDialogState(() {
                                  isLoading = false;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                    child: const Text('Crear'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Motorcycle _placeholderMotorcycle() {
    return Motorcycle(
      id: widget.motorcycleId,
      make: 'Motocicleta',
      model: 'No encontrada',
      year: 0,
      power: 0,
      torque: 0,
      type: 'N/A',
      displacement: 0,
      fuelCapacity: 'N/A',
      weight: 0,
      userId: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final motorcycleProvider = context.watch<MotorcycleProvider>();
    final motorcycle = motorcycleProvider.motorcycles.firstWhere(
      (moto) => moto.id == widget.motorcycleId,
      orElse: () => _placeholderMotorcycle(),
    );

    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${motorcycle.make} ${motorcycle.model}'),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: screenHeight * 0.4,
                  width: double.infinity,
                  child: Hero(
                    tag: widget.heroTag,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(
                          AppConstants.borderRadius * 2,
                        ),
                        bottomRight: Radius.circular(
                          AppConstants.borderRadius * 2,
                        ),
                      ),
                      child: Image.asset(widget.imagePath, fit: BoxFit.contain),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _MotorcycleDetails(motorcycle: motorcycle),
                const SizedBox(height: 100), // Espacio para el FAB
              ],
            ),
          ),
          // FAB simple que abre diálogo de opciones
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: FloatingActionButton(
                onPressed: () {
                  final motorcycleProvider = Provider.of<MotorcycleProvider>(
                    context,
                    listen: false,
                  );
                  final motorcycle = motorcycleProvider.motorcycles.firstWhere(
                    (moto) => moto.id == widget.motorcycleId,
                    orElse: () => _placeholderMotorcycle(),
                  );
                  _showOptionsDialog(context, motorcycle);
                },
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MotorcycleDetails extends StatelessWidget {
  const _MotorcycleDetails({required this.motorcycle});

  final Motorcycle motorcycle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = <_SpecEntry>[
      _SpecEntry(label: 'Marca', value: motorcycle.make),
      _SpecEntry(label: 'Modelo', value: motorcycle.model),
      _SpecEntry(label: 'Año', value: motorcycle.year.toString()),
      _SpecEntry(label: 'Tipo', value: motorcycle.type),
      _SpecEntry(
        label: 'Cilindrada',
        value:
            motorcycle.displacement != null && motorcycle.displacement! > 0
                ? '${motorcycle.displacement} cc'
                : 'N/A',
      ),
      _SpecEntry(label: 'Potencia', value: '${motorcycle.power} hp'),
      _SpecEntry(label: 'Torque', value: '${motorcycle.torque} Nm'),
      _SpecEntry(
        label: 'Capacidad de combustible',
        value: motorcycle.fuelCapacity,
      ),
      _SpecEntry(label: 'Peso', value: '${motorcycle.weight} kg'),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius * 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Especificaciones', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ..._buildSpecRows(entries, theme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSpecRows(List<_SpecEntry> entries, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final widgets = <Widget>[];
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entry.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      theme.brightness == Brightness.dark
                          ? colorScheme.primary.withOpacity(0.2)
                          : AppColors.accentCoralLight,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius * 1.2,
                  ),
                ),
                child: Text(
                  entry.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      );
      if (i < entries.length - 1) {
        widgets.add(
          Divider(
            height: 1,
            color: colorScheme.surfaceVariant.withOpacity(0.5),
          ),
        );
      }
    }
    return widgets;
  }
}

class _DateSelectionRow extends StatelessWidget {
  const _DateSelectionRow({required this.displayText, required this.onPressed});

  final String displayText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            side: BorderSide(color: accentColor.withOpacity(0.4)),
            padding: const EdgeInsets.all(12),
          ),
          child: Icon(Icons.calendar_today_outlined, color: accentColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: colorScheme.surfaceVariant.withOpacity(0.8),
              ),
              color: colorScheme.surface,
            ),
            child: Text(
              displayText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    displayText == 'Elegir una fecha'
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpecEntry {
  const _SpecEntry({required this.label, required this.value});

  final String label;
  final String value;
}
