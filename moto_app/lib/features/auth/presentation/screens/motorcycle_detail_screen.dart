import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moto_app/core/constants/app_constants.dart';
import 'package:moto_app/core/theme/app_colors.dart';
import 'package:moto_app/domain/models/motorcycle.dart';
import 'package:moto_app/domain/providers/motorcycle_provider.dart';

class MotorcycleDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final motorcycleProvider = context.watch<MotorcycleProvider>();
    final motorcycle = motorcycleProvider.motorcycles.firstWhere(
      (moto) => moto.id == motorcycleId,
      orElse: () => _placeholderMotorcycle(),
    );

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: Text('${motorcycle.make} ${motorcycle.model}'),
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.neutralText,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: screenHeight * 0.4,
              width: double.infinity,
              child: Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppConstants.borderRadius * 2),
                    bottomRight: Radius.circular(AppConstants.borderRadius * 2),
                  ),
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _MotorcycleDetails(motorcycle: motorcycle),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Motorcycle _placeholderMotorcycle() {
    return Motorcycle(
      id: motorcycleId,
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
                    color: AppColors.mutedText,
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
                  color: AppColors.accentCoralLight,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius * 1.2,
                  ),
                ),
                child: Text(
                  entry.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.accentCoral,
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
        widgets.add(const Divider(height: 1, color: AppColors.surfaceAlt));
      }
    }
    return widgets;
  }
}

class _SpecEntry {
  const _SpecEntry({required this.label, required this.value});

  final String label;
  final String value;
}
