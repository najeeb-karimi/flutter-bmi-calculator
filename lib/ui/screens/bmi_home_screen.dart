import 'package:flutter/material.dart';

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
            const SizedBox(height: 16),
            if (_result != null) ...[
              Text(
                _result!.value.toStringAsFixed(1),
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _result!.categoryLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ] else
              Text(
                'Enter your height and weight, then tap Calculate.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
