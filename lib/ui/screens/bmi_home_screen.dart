import 'package:flutter/material.dart';

import 'package:bmi_calculator/core/constants/bmi_tips.dart';
import 'package:bmi_calculator/core/utils/bmi_calculator.dart';
import 'package:bmi_calculator/core/utils/unit_converter.dart';
import 'package:bmi_calculator/models/bmi_result.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/ui/screens/settings_screen.dart';

/// Main BMI calculator screen with header, input area, and result area.
class BmiHomeScreen extends StatefulWidget {
  const BmiHomeScreen({
    super.key,
    required this.defaultUnit,
    required this.initialTargetBmi,
    required this.currentThemeMode,
    required this.onDefaultUnitChanged,
    required this.onThemeModeChanged,
    required this.onTargetBmiChanged,
  });

  final MeasurementUnit defaultUnit;
  final double initialTargetBmi;
  final ThemeMode currentThemeMode;
  final ValueChanged<MeasurementUnit> onDefaultUnitChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<double> onTargetBmiChanged;

  @override
  State<BmiHomeScreen> createState() => _BmiHomeScreenState();
}

class _BmiHomeScreenState extends State<BmiHomeScreen> {
  static const double _minHeightCm = 100;
  static const double _maxHeightCm = 220;
  static const double _minWeightKg = 30;
  static const double _maxWeightKg = 150;
  static const double _minTargetBmi = 18;
  static const double _maxTargetBmi = 28;

  late MeasurementUnit _unit;
  double _heightCm = 170;
  double _weightKg = 70;
  late double _targetBmi;
  BmiResult? _result;
  bool _isCalculatePressed = false;

  double _clampTargetBmi(double value) {
    return value.clamp(_minTargetBmi, _maxTargetBmi);
  }

  @override
  void initState() {
    super.initState();
    _unit = widget.defaultUnit;
    _targetBmi = _clampTargetBmi(widget.initialTargetBmi);
  }

  @override
  void didUpdateWidget(covariant BmiHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultUnit != widget.defaultUnit) {
      _unit = widget.defaultUnit;
    }
    if (oldWidget.initialTargetBmi != widget.initialTargetBmi) {
      _targetBmi = _clampTargetBmi(widget.initialTargetBmi);
    }
  }

  void _onUnitChanged(MeasurementUnit newUnit) {
    if (_unit == newUnit) return;
    setState(() {
      _unit = newUnit;
    });
    widget.onDefaultUnitChanged(newUnit);
  }

  void _onCalculate() {
    final isMetric = _unit == MeasurementUnit.metric;
    final displayHeight =
        isMetric ? _heightCm : UnitConverter.cmToIn(_heightCm);
    final displayWeight =
        isMetric ? _weightKg : UnitConverter.kgToLb(_weightKg);

    if (!displayHeight.isFinite || !displayWeight.isFinite) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid values detected. Please adjust your inputs.'),
        ),
      );
      return;
    }

    setState(() {
      _result = BmiCalculator.computeWithUnit(
        weight: displayWeight,
        height: displayHeight,
        unit: _unit,
      );
    });
  }

  void _setCalculatePressed(bool value) {
    if (_isCalculatePressed == value) return;
    setState(() {
      _isCalculatePressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pulse = (DateTime.now().millisecond / 1000);
    final animatedTop = Color.lerp(
      colorScheme.surface,
      colorScheme.primary.withValues(alpha: 0.08),
      pulse,
    )!;
    final animatedBottom = Color.lerp(
      colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
      colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
      pulse,
    )!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SettingsScreen(
                    defaultUnit: _unit,
                    currentThemeMode: widget.currentThemeMode,
                    onDefaultUnitChanged: (unit) {
                      widget.onDefaultUnitChanged(unit);
                      if (_unit != unit) {
                        setState(() {
                          _unit = unit;
                        });
                      }
                    },
                    onThemeModeChanged: widget.onThemeModeChanged,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          final topColor = Color.lerp(colorScheme.surface, animatedTop, value)!;
          final bottomColor = Color.lerp(
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            animatedBottom,
            value,
          )!;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [topColor, bottomColor],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding =
                  constraints.maxWidth >= 700 ? 28.0 : 20.0;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 20),
                        _buildInputCard(context),
                        const SizedBox(height: 20),
                        _buildCalculateButton(context),
                        const SizedBox(height: 20),
                        AnimatedScale(
                          scale: _result == null ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutBack,
                          child: _buildResultCard(context),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Check your body mass index',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Use your height and weight to calculate your BMI and review tips tailored to your result.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard(BuildContext context) {
    final theme = Theme.of(context);
    final isMetric = _unit == MeasurementUnit.metric;
    final heightValue = isMetric ? _heightCm : UnitConverter.cmToIn(_heightCm);
    final weightValue = isMetric ? _weightKg : UnitConverter.kgToLb(_weightKg);
    final minHeight =
        isMetric ? _minHeightCm : UnitConverter.cmToIn(_minHeightCm);
    final maxHeight =
        isMetric ? _maxHeightCm : UnitConverter.cmToIn(_maxHeightCm);
    final minWeight =
        isMetric ? _minWeightKg : UnitConverter.kgToLb(_minWeightKg);
    final maxWeight =
        isMetric ? _maxWeightKg : UnitConverter.kgToLb(_maxWeightKg);
    final heightUnit = isMetric ? 'cm' : 'in';
    final weightUnit = isMetric ? 'kg' : 'lb';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<MeasurementUnit>(
              segments: const [
                ButtonSegment<MeasurementUnit>(
                  value: MeasurementUnit.metric,
                  label: Text('Metric'),
                ),
                ButtonSegment<MeasurementUnit>(
                  value: MeasurementUnit.imperial,
                  label: Text('Imperial'),
                ),
              ],
              selected: <MeasurementUnit>{_unit},
              onSelectionChanged: (selection) {
                _onUnitChanged(selection.first);
              },
            ),
            const SizedBox(height: 20),
            _buildSectionLabel(context, 'Height & Weight'),
            const SizedBox(height: 20),
            Semantics(
              label: 'Height ${heightValue.toStringAsFixed(1)} $heightUnit',
              child: Text(
                'Height: ${heightValue.toStringAsFixed(1)} $heightUnit',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Semantics(
              label: 'Height slider',
              value: '${heightValue.toStringAsFixed(1)} $heightUnit',
              increasedValue:
                  '${(heightValue + 1).clamp(minHeight, maxHeight).toStringAsFixed(1)} $heightUnit',
              decreasedValue:
                  '${(heightValue - 1).clamp(minHeight, maxHeight).toStringAsFixed(1)} $heightUnit',
              child: Slider(
                value: heightValue.clamp(minHeight, maxHeight),
                min: minHeight,
                max: maxHeight,
                divisions: (maxHeight - minHeight).round(),
                onChanged: (v) => setState(() {
                  _heightCm = isMetric ? v : UnitConverter.inToCm(v);
                }),
              ),
            ),
            const SizedBox(height: 10),
            Semantics(
              label: 'Weight ${weightValue.toStringAsFixed(1)} $weightUnit',
              child: Text(
                'Weight: ${weightValue.toStringAsFixed(1)} $weightUnit',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Semantics(
              label: 'Weight slider',
              value: '${weightValue.toStringAsFixed(1)} $weightUnit',
              increasedValue:
                  '${(weightValue + 1).clamp(minWeight, maxWeight).toStringAsFixed(1)} $weightUnit',
              decreasedValue:
                  '${(weightValue - 1).clamp(minWeight, maxWeight).toStringAsFixed(1)} $weightUnit',
              child: Slider(
                value: weightValue.clamp(minWeight, maxWeight),
                min: minWeight,
                max: maxWeight,
                divisions: (maxWeight - minWeight).round(),
                onChanged: (v) => setState(() {
                  _weightKg = isMetric ? v : UnitConverter.lbToKg(v);
                }),
              ),
            ),
            const SizedBox(height: 10),
            Semantics(
              label: 'Target BMI ${_targetBmi.toStringAsFixed(1)}',
              child: Text(
                'Target BMI: ${_targetBmi.toStringAsFixed(1)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Semantics(
              label: 'Target BMI slider',
              value: _targetBmi.toStringAsFixed(1),
              child: Slider(
                value: _targetBmi,
                min: _minTargetBmi,
                max: _maxTargetBmi,
                divisions: ((_maxTargetBmi - _minTargetBmi) * 2).round(),
                onChanged: (v) {
                  setState(() {
                    _targetBmi = _clampTargetBmi(v);
                  });
                  widget.onTargetBmiChanged(_targetBmi);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setCalculatePressed(true),
      onTapCancel: () => _setCalculatePressed(false),
      onTapUp: (_) => _setCalculatePressed(false),
      child: AnimatedScale(
        scale: _isCalculatePressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: FilledButton.icon(
          onPressed: _onCalculate,
          icon: const Icon(Icons.monitor_weight_outlined),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Calculate BMI'),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel(context, 'Your Result'),
            const SizedBox(height: 18),
            Semantics(
              liveRegion: true,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _result != null
                    ? _StyledResultContent(
                        key: ValueKey<double>(_result!.value),
                        result: _result!,
                        heightCm: _heightCm,
                        weightKg: _weightKg,
                        targetBmi: _targetBmi,
                        colorScheme: colorScheme,
                        textTheme: theme.textTheme,
                      )
                    : _EmptyResultPlaceholder(
                        key: const ValueKey<String>('empty'),
                        colorScheme: colorScheme,
                        textTheme: theme.textTheme,
                      ),
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
    required this.heightCm,
    required this.weightKg,
    required this.targetBmi,
    required this.colorScheme,
    required this.textTheme,
  });

  final BmiResult result;
  final double heightCm;
  final double weightKg;
  final double targetBmi;
  final ColorScheme colorScheme;
  final TextTheme? textTheme;

  /// Target weight in kg for [targetBmi] at [heightCm]. Formula: targetBmi * (heightM)^2.
  static double _targetWeightKg(double targetBmi, double heightCm) {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100;
    return targetBmi * (heightM * heightM);
  }

  /// Short guidance string: how far current weight is from target weight for the given target BMI.
  static String _targetGuidance(
      double weightKg, double heightCm, double targetBmi) {
    final targetW = _targetWeightKg(targetBmi, heightCm);
    final diffKg = weightKg - targetW;
    if (diffKg.abs() < 1) {
      return 'You\'re at your target weight for BMI ${targetBmi.toStringAsFixed(1)}.';
    }
    final absKg = diffKg.abs().toStringAsFixed(1);
    if (diffKg > 0) {
      return 'To reach a BMI of ${targetBmi.toStringAsFixed(1)}, aim to lose about $absKg kg.';
    } else {
      return 'To reach a BMI of ${targetBmi.toStringAsFixed(1)}, aim to gain about $absKg kg.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(colorScheme);
    final description = _descriptionForCategory(result.category);
    final tips = BmiTips.getTipsForCategory(result.category);
    final targetGuidance = _targetGuidance(weightKg, heightCm, targetBmi);

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
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.flag_outlined, size: 20, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  targetGuidance,
                  style: textTheme?.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _categoryColor(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;

    switch (result.category) {
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
