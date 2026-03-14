import 'package:flutter/material.dart';

import 'package:bmi_calculator/core/constants/bmi_tips.dart';
import 'package:bmi_calculator/core/utils/bmi_calculator.dart';
import 'package:bmi_calculator/models/bmi_result.dart';

/// Main BMI calculator screen with header, input area, and result area.
class BmiHomeScreen extends StatefulWidget {
  const BmiHomeScreen({super.key});

  @override
  State<BmiHomeScreen> createState() => _BmiHomeScreenState();
}

class _BmiHomeScreenState extends State<BmiHomeScreen> {
  static const double _minHeightCm = 100;
  static const double _maxHeightCm = 220;
  static const double _minWeightKg = 30;
  static const double _maxWeightKg = 150;

  double _heightCm = 170;
  double _weightKg = 70;
  BmiResult? _result;

  void _onCalculate() {
    setState(() {
      _result = BmiCalculator.compute(_weightKg, _heightCm);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildInputCard(context),
                const SizedBox(height: 24),
                _buildCalculateButton(context),
                const SizedBox(height: 24),
                _buildResultCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'Check your body mass index',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildInputCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Height & Weight',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Height: ${_heightCm.round()} cm',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            Slider(
              value: _heightCm,
              min: _minHeightCm,
              max: _maxHeightCm,
              divisions: (_maxHeightCm - _minHeightCm).round(),
              onChanged: (v) => setState(() => _heightCm = v),
            ),
            const SizedBox(height: 8),
            Text(
              'Weight: ${_weightKg.round()} kg',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            Slider(
              value: _weightKg,
              min: _minWeightKg,
              max: _maxWeightKg,
              divisions: (_maxWeightKg - _minWeightKg).round(),
              onChanged: (v) => setState(() => _weightKg = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton(BuildContext context) {
    return FilledButton(
      onPressed: _onCalculate,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text('Calculate BMI'),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Result',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _result != null
                  ? _StyledResultContent(
                      key: ValueKey<double>(_result!.value),
                      result: _result!,
                      colorScheme: colorScheme,
                      textTheme: theme.textTheme,
                    )
                  : _EmptyResultPlaceholder(
                      key: const ValueKey<String>('empty'),
                      colorScheme: colorScheme,
                      textTheme: theme.textTheme,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyledResultContent extends StatelessWidget {
  const _StyledResultContent({
    required super.key,
    required this.result,
    required this.colorScheme,
    required this.textTheme,
  });

  final BmiResult result;
  final ColorScheme colorScheme;
  final TextTheme? textTheme;

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(colorScheme);
    final description = _descriptionForCategory(result.category);
    final tips = BmiTips.getTipsForCategory(result.category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                result.categoryLabel.toUpperCase(),
                style: textTheme?.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: categoryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                result.value.toStringAsFixed(1),
                style: textTheme?.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),
              Text(
                'BMI',
                style: textTheme?.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: textTheme?.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        if (tips.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Tips',
            style: textTheme?.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: textTheme?.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _categoryColor(ColorScheme scheme) {
    switch (result.category) {
      case BmiCategory.underweight:
        return scheme.tertiary;
      case BmiCategory.normal:
        return scheme.primary;
      case BmiCategory.overweight:
        return scheme.secondary;
      case BmiCategory.obese:
        return scheme.error;
    }
  }

  static String _descriptionForCategory(BmiCategory category) {
    switch (category) {
      case BmiCategory.underweight:
        return 'You have a lower than normal body weight.';
      case BmiCategory.normal:
        return 'You have a normal body weight. Good job!';
      case BmiCategory.overweight:
        return 'You have a higher than normal body weight.';
      case BmiCategory.obese:
        return 'You have a much higher than normal body weight.';
    }
  }
}

class _EmptyResultPlaceholder extends StatelessWidget {
  const _EmptyResultPlaceholder({
    required super.key,
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme? textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Enter your height and weight, then tap Calculate.',
      style: textTheme?.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
