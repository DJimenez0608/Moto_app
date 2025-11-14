import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moto_app/core/constants/app_constants.dart';

class MoneyBalanceScreen extends StatefulWidget {
  const MoneyBalanceScreen({super.key});

  @override
  State<MoneyBalanceScreen> createState() => _MoneyBalanceScreenState();
}

class _MoneyBalanceScreenState extends State<MoneyBalanceScreen> {
  final List<int> _availableYears = List<int>.generate(
    2024 - 2017 + 1,
    (index) => 2024 - index,
  );

  final Map<int, double> _annualTotals = {
    2024: 4820,
    2023: 4560,
    2022: 4380,
    2021: 4290,
    2020: 3825,
    2019: 3610,
    2018: 3425,
    2017: 2980,
  };

  late int _selectedYear;
  int _touchedIndex = -1;

  final List<_ExpenseSlice> _slices = const [
    _ExpenseSlice(label: 'SOAT', value: 15, color: Color(0xFFE57373)),
    _ExpenseSlice(
      label: 'Tecnicomecánica',
      value: 15,
      color: Color(0xFFF59E0B),
    ),
    _ExpenseSlice(label: 'Mantenimientos', value: 50, color: Color(0xFF2563EB)),
    _ExpenseSlice(
      label: 'Gastos inesperados',
      value: 30,
      color: Color(0xFF9333EA),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = _availableYears.first;
  }

  String get _formattedTotal {
    final total = _annualTotals[_selectedYear] ?? 0;
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

  Widget _buildAnnualSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = colorScheme.primary;

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
                value: _selectedYear,
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadius * 1.5,
                ),
                underline: const SizedBox.shrink(),
                items:
                    _availableYears
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
              '$_formattedTotal COP ',
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

  Widget _buildPieChartCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
                  sections: List.generate(_slices.length, (index) {
                    final slice = _slices[index];
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
              slices: _slices,
              touchedIndex: _touchedIndex,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnnualSummaryCard(context),
              const SizedBox(height: 24),
              _buildPieChartCard(context),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
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
    this.shrinkWrap = false,
    this.physics = const BouncingScrollPhysics(),
  });

  final List<_ExpenseSlice> slices;
  final int touchedIndex;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GridView.builder(
      itemCount: slices.length,
      padding: EdgeInsets.zero,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.2,
      ),
      itemBuilder: (context, index) {
        final slice = slices[index];
        final bool isActive = index == touchedIndex;

        return DecoratedBox(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: slice.color,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    slice.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${slice.value.toInt()}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
