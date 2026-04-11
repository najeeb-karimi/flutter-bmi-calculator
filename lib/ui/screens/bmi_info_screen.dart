import 'package:flutter/material.dart';

import 'package:bmi_calculator/models/bmi_result.dart';

/// Educational screen explaining BMI with category intervals.
class BmiInfoScreen extends StatelessWidget {
  const BmiInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Info'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'What is BMI?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Body Mass Index (BMI) is a simple number based on your height and weight. '
              'It helps estimate if your weight falls into a common health category.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'BMI categories',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _LegendRow(
              color: _categoryColor(BmiCategory.underweight, colorScheme),
              label: 'Underweight',
              range: '< 18.5',
            ),
            _LegendRow(
              color: _categoryColor(BmiCategory.normal, colorScheme),
              label: 'Normal',
              range: '18.5 - 24.9',
            ),
            _LegendRow(
              color: _categoryColor(BmiCategory.overweight, colorScheme),
              label: 'Overweight',
              range: '25.0 - 29.9',
            ),
            _LegendRow(
              color: _categoryColor(BmiCategory.obese, colorScheme),
              label: 'Obese',
              range: '>= 30.0',
            ),
            const SizedBox(height: 24),
            Text(
              'Important',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'BMI is a helpful screening tool, not a diagnosis. Age, body composition, '
              'and medical history matter too. For medical advice, consult a healthcare professional.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _categoryColor(BmiCategory category, ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    switch (category) {
      case BmiCategory.underweight:
        return isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0284C7);
      case BmiCategory.normal:
        return isDark ? const Color(0xFF86EFAC) : const Color(0xFF16A34A);
      case BmiCategory.overweight:
        return isDark ? const Color(0xFFFCD34D) : const Color(0xFFD97706);
      case BmiCategory.obese:
        return isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
    }
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.range,
  });

  final Color color;
  final String label;
  final String range;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            range,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
