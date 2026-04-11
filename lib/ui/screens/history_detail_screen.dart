import 'package:flutter/material.dart';

import 'package:bmi_calculator/core/utils/unit_converter.dart';
import 'package:bmi_calculator/models/bmi_entry.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({
    super.key,
    required this.entry,
  });

  final BmiEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = _categoryColor(entry, colorScheme);
    final measurements = _formatMeasurements(entry);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Result'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      entry.category.name.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry.bmiValue.toStringAsFixed(1),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: categoryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'BMI',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved on',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDateTime(context, entry.createdAt),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Measurement Snapshot',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Height: ${measurements.heightValue} ${measurements.heightUnit}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Weight: ${measurements.weightValue} ${measurements.weightUnit}',
                    ),
                    const SizedBox(height: 8),
                    Text('Unit used: ${entry.unitUsed.label}'),
                  ],
                ),
              ),
            ),
            if (entry.goalSnapshot != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Snapshot',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Target BMI: ${entry.goalSnapshot!.value.toStringAsFixed(1)}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MeasurementSnapshot {
  const _MeasurementSnapshot({
    required this.heightValue,
    required this.heightUnit,
    required this.weightValue,
    required this.weightUnit,
  });

  final String heightValue;
  final String heightUnit;
  final String weightValue;
  final String weightUnit;
}

_MeasurementSnapshot _formatMeasurements(BmiEntry entry) {
  final isMetric = entry.unitUsed == MeasurementUnit.metric;
  final height = isMetric ? entry.heightCm : UnitConverter.cmToIn(entry.heightCm);
  final weight = isMetric ? entry.weightKg : UnitConverter.kgToLb(entry.weightKg);
  return _MeasurementSnapshot(
    heightValue: height.toStringAsFixed(1),
    heightUnit: isMetric ? 'cm' : 'in',
    weightValue: weight.toStringAsFixed(1),
    weightUnit: isMetric ? 'kg' : 'lb',
  );
}

String _formatDateTime(BuildContext context, DateTime value) {
  final localizations = MaterialLocalizations.of(context);
  final date = localizations.formatFullDate(value);
  final time = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(value),
    alwaysUse24HourFormat: true,
  );
  return '$date at $time';
}

Color _categoryColor(BmiEntry entry, ColorScheme scheme) {
  final isDark = scheme.brightness == Brightness.dark;
  switch (entry.category.name) {
    case 'underweight':
      return isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7);
    case 'normal':
      return isDark ? const Color(0xFF86EFAC) : const Color(0xFF16A34A);
    case 'overweight':
      return isDark ? const Color(0xFFFCD34D) : const Color(0xFFD97706);
    case 'obese':
      return isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
    default:
      return scheme.primary;
  }
}
