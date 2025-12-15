import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:moto_app/core/constants/app_constants.dart';
import 'package:moto_app/core/theme/app_colors.dart';
import 'package:moto_app/domain/models/motorcycle.dart';
import 'package:moto_app/domain/models/maintenance.dart';
import 'package:moto_app/domain/models/observation.dart';
import 'package:moto_app/domain/providers/motorcycle_provider.dart';
import 'package:moto_app/domain/providers/maintenance_provider.dart';
import 'package:moto_app/domain/providers/observation_provider.dart';
import 'package:moto_app/features/auth/data/datasources/observation_http_service.dart';
import 'package:moto_app/features/auth/data/datasources/maintenance_http_service.dart';

class MotorcycleDetailScreen extends StatefulWidget {
  const MotorcycleDetailScreen({
    super.key,
    required this.motorcycleId,
    this.motorcyclePhotoUrl,
    required this.heroTag,
  });

  final int motorcycleId;
  final String? motorcyclePhotoUrl;
  final String heroTag;

  @override
  State<MotorcycleDetailScreen> createState() => _MotorcycleDetailScreenState();
}

class _MotorcycleDetailScreenState extends State<MotorcycleDetailScreen> {
  int _selectedTab = 0; // 0=Detalle, 1=Mantenimientos, 2=Observaciones

  void _onTabSelected(int index) {
    setState(() {
      _selectedTab = index;
    });

    // Carga lazy de datos
    if (index == 1) {
      // Mantenimientos
      Provider.of<MaintenanceProvider>(
        context,
        listen: false,
      ).getMaintenance(widget.motorcycleId);
    } else if (index == 2) {
      // Observaciones
      Provider.of<ObservationProvider>(
        context,
        listen: false,
      ).getObservations(widget.motorcycleId);
    }
  }

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

  Widget _buildTabsRow(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildTab(
            context: context,
            colorScheme: colorScheme,
            text: 'Detalle',
            index: 0,
          ),
        ),
        Expanded(
          child: _buildTab(
            context: context,
            colorScheme: colorScheme,
            text: 'Mantenimientos',
            index: 1,
          ),
        ),
        Expanded(
          child: _buildTab(
            context: context,
            colorScheme: colorScheme,
            text: 'Observaciones',
            index: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required ColorScheme colorScheme,
    required String text,
    required int index,
  }) {
    final isSelected = _selectedTab == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (theme.brightness == Brightness.dark
                      ? colorScheme.primary.withOpacity(0.2)
                      : AppColors.accentCoralLight)
                  : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
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
                  child: SingleChildScrollView(
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

                                // Refrescar observaciones
                                final observationProvider =
                                    Provider.of<ObservationProvider>(
                                      context,
                                      listen: false,
                                    );
                                observationProvider.getObservations(
                                  motorcycle.id,
                                );

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
          Column(
            children: [
              // Menú de tabs fijo en la parte superior
              Container(
                color: theme.scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: _buildTabsRow(context, colorScheme),
              ),
              // Contenido scrolleable
              Expanded(
                child: SingleChildScrollView(
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
                            child:
                                widget.motorcyclePhotoUrl != null
                                    ? Image.network(
                                      widget.motorcyclePhotoUrl!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        final colorScheme =
                                            Theme.of(context).colorScheme;
                                        return Container(
                                          color: colorScheme.surfaceVariant,
                                          child: Icon(
                                            Icons.motorcycle,
                                            size: 100,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        );
                                      },
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                          ),
                                        );
                                      },
                                    )
                                    : Builder(
                                      builder: (context) {
                                        final colorScheme =
                                            Theme.of(context).colorScheme;
                                        return Container(
                                          color: colorScheme.surfaceVariant,
                                          child: Icon(
                                            Icons.motorcycle,
                                            size: 100,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        );
                                      },
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Contenido según tab seleccionado
                      if (_selectedTab == 0)
                        _MotorcycleDetails(motorcycle: motorcycle)
                      else if (_selectedTab == 1)
                        _MaintenanceList(motorcycleId: widget.motorcycleId)
                      else if (_selectedTab == 2)
                        _ObservationsList(motorcycleId: widget.motorcycleId),
                      const SizedBox(height: 100), // Espacio para el FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
          // FAB fijo en la parte inferior
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

class _MaintenanceList extends StatelessWidget {
  const _MaintenanceList({required this.motorcycleId});

  final int motorcycleId;

  @override
  Widget build(BuildContext context) {
    final maintenanceProvider = context.watch<MaintenanceProvider>();
    final maintenanceList = maintenanceProvider.maintenanceForMotorcycle(
      motorcycleId,
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (maintenanceProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (maintenanceProvider.errorMessage != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error: ${maintenanceProvider.errorMessage}',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      );
    }

    if (maintenanceList.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No hay mantenimientos registrados',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text('Mantenimientos', style: theme.textTheme.titleLarge),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: maintenanceList.length,
          itemBuilder: (context, index) {
            final maintenance = maintenanceList[index];
            return _MaintenanceCard(maintenance: maintenance);
          },
        ),
      ],
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  const _MaintenanceCard({required this.maintenance});

  final Maintenance maintenance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final numberFormat = NumberFormat('#,###');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(maintenance.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    maintenance.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'COP ${numberFormat.format(maintenance.cost)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: colorScheme.primary),
              onPressed: () {
                // Por ahora no hace nada
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ObservationsList extends StatelessWidget {
  const _ObservationsList({required this.motorcycleId});

  final int motorcycleId;

  @override
  Widget build(BuildContext context) {
    final observationProvider = context.watch<ObservationProvider>();
    final observationsList = observationProvider.observationsForMotorcycle(
      motorcycleId,
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (observationProvider.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Cargando observaciones...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (observationProvider.errorMessage != null) {
      return Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: colorScheme.error, size: 48),
              const SizedBox(height: 8),
              Text(
                'Error al cargar observaciones',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                observationProvider.errorMessage ?? 'Error desconocido',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (observationsList.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No hay observaciones registradas',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text('Observaciones', style: theme.textTheme.titleLarge),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: observationsList.length,
          itemBuilder: (context, index) {
            final observation = observationsList[index];
            return _ObservationCard(observation: observation);
          },
        ),
      ],
    );
  }
}

class _ObservationCard extends StatelessWidget {
  const _ObservationCard({required this.observation});

  final Observation observation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy');

    Widget cardContent = Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono de observación
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.note_alt_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Contenido de la observación
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(observation.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    observation.observation,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            // Icono de editar
            IconButton(
              icon: Icon(Icons.edit, color: colorScheme.primary),
              onPressed: () {
                // Por ahora no hace nada
              },
            ),
          ],
        ),
      ),
    );

    return cardContent;
  }
}

class _SpecEntry {
  const _SpecEntry({required this.label, required this.value});

  final String label;
  final String value;
}
