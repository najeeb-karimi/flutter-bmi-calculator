import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bmi_calculator/core/constants/bmi_tips.dart';
import 'package:bmi_calculator/core/utils/bmi_calculator.dart';
import 'package:bmi_calculator/core/utils/goal_progress_calculator.dart';
import 'package:bmi_calculator/core/utils/healthy_weight_calculator.dart';
import 'package:bmi_calculator/core/utils/share_text_builder.dart';
import 'package:bmi_calculator/core/utils/unit_converter.dart';
import 'package:bmi_calculator/models/bmi_entry.dart';
import 'package:bmi_calculator/models/bmi_result.dart';
import 'package:bmi_calculator/models/goal_progress.dart';
import 'package:bmi_calculator/models/healthy_weight_range.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/models/personal_profile.dart';
import 'package:bmi_calculator/models/user_goal.dart';
import 'package:bmi_calculator/ui/navigation/app_routes.dart';

/// Main BMI calculator screen with header, input area, and result area.
class BmiHomeScreen extends StatefulWidget {
  const BmiHomeScreen({
    super.key,
    required this.defaultUnit,
    required this.activeGoal,
    required this.personalProfile,
    required this.currentThemeMode,
    required this.onDefaultUnitChanged,
    required this.onThemeModeChanged,
    required this.onGoalChanged,
    required this.onProfileChanged,
    required this.onSaveResult,
    required this.onLoadHistory,
    required this.onDeleteHistoryEntry,
    required this.onClearHistory,
  });

  final MeasurementUnit defaultUnit;
  final UserGoal activeGoal;
  final PersonalProfile? personalProfile;
  final ThemeMode currentThemeMode;
  final ValueChanged<MeasurementUnit> onDefaultUnitChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<UserGoal> onGoalChanged;
  final ValueChanged<PersonalProfile?> onProfileChanged;
  final Future<void> Function(BmiEntry entry) onSaveResult;
  final Future<List<BmiEntry>> Function() onLoadHistory;
  final Future<void> Function(String id) onDeleteHistoryEntry;
  final Future<void> Function() onClearHistory;

  @override
  State<BmiHomeScreen> createState() => _BmiHomeScreenState();
}

class _BmiHomeScreenState extends State<BmiHomeScreen> {
  static const double _minHeightCm = 100;
  static const double _maxHeightCm = 220;
  static const double _minWeightKg = 30;
  static const double _maxWeightKg = 150;

  late MeasurementUnit _unit;
  double _heightCm = 170;
  double _weightKg = 70;
  BmiResult? _result;
  bool _isCalculatePressed = false;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final FocusNode _heightFocusNode;
  late final FocusNode _weightFocusNode;
  String? _heightErrorText;
  String? _weightErrorText;

  @override
  void initState() {
    super.initState();
    _unit = widget.defaultUnit;
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _heightFocusNode = FocusNode()..addListener(_commitHeightFromTextIfNeeded);
    _weightFocusNode = FocusNode()..addListener(_commitWeightFromTextIfNeeded);
    _syncInputControllers();
  }

  @override
  void didUpdateWidget(covariant BmiHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultUnit != widget.defaultUnit) {
      _unit = widget.defaultUnit;
      _syncInputControllers();
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _heightFocusNode
      ..removeListener(_commitHeightFromTextIfNeeded)
      ..dispose();
    _weightFocusNode
      ..removeListener(_commitWeightFromTextIfNeeded)
      ..dispose();
    super.dispose();
  }

  void _onUnitChanged(MeasurementUnit newUnit) {
    if (_unit == newUnit) return;
    setState(() {
      _unit = newUnit;
      _heightErrorText = null;
      _weightErrorText = null;
    });
    _syncInputControllers();
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

  void _syncInputControllers() {
    _heightController.text = _formatOneDecimal(_displayHeightForCurrentUnit);
    _weightController.text = _formatOneDecimal(_displayWeightForCurrentUnit);
  }

  double get _displayHeightForCurrentUnit {
    return _unit == MeasurementUnit.metric
        ? _heightCm
        : UnitConverter.cmToIn(_heightCm);
  }

  double get _displayWeightForCurrentUnit {
    return _unit == MeasurementUnit.metric
        ? _weightKg
        : UnitConverter.kgToLb(_weightKg);
  }

  String _formatOneDecimal(double value) => value.toStringAsFixed(1);

  void _commitHeightFromTextIfNeeded() {
    if (_heightFocusNode.hasFocus) return;
    _applyHeightFromInput(_heightController.text);
  }

  void _commitWeightFromTextIfNeeded() {
    if (_weightFocusNode.hasFocus) return;
    _applyWeightFromInput(_weightController.text);
  }

  void _applyHeightFromInput(String rawValue) {
    final parsedValue = double.tryParse(rawValue.trim());
    final minHeight = _unit == MeasurementUnit.metric
        ? _minHeightCm
        : UnitConverter.cmToIn(_minHeightCm);
    final maxHeight = _unit == MeasurementUnit.metric
        ? _maxHeightCm
        : UnitConverter.cmToIn(_maxHeightCm);
    final unitLabel = _unit == MeasurementUnit.metric ? 'cm' : 'in';

    if (parsedValue == null ||
        parsedValue < minHeight ||
        parsedValue > maxHeight) {
      setState(() {
        _heightErrorText =
            'Enter a value between ${_formatOneDecimal(minHeight)} and ${_formatOneDecimal(maxHeight)} $unitLabel';
      });
      return;
    }

    setState(() {
      _heightCm = _unit == MeasurementUnit.metric
          ? parsedValue
          : UnitConverter.inToCm(parsedValue);
      _heightErrorText = null;
    });
    _heightController.text = _formatOneDecimal(_displayHeightForCurrentUnit);
  }

  void _applyWeightFromInput(String rawValue) {
    final parsedValue = double.tryParse(rawValue.trim());
    final minWeight = _unit == MeasurementUnit.metric
        ? _minWeightKg
        : UnitConverter.kgToLb(_minWeightKg);
    final maxWeight = _unit == MeasurementUnit.metric
        ? _maxWeightKg
        : UnitConverter.kgToLb(_maxWeightKg);
    final unitLabel = _unit == MeasurementUnit.metric ? 'kg' : 'lb';

    if (parsedValue == null ||
        parsedValue < minWeight ||
        parsedValue > maxWeight) {
      setState(() {
        _weightErrorText =
            'Enter a value between ${_formatOneDecimal(minWeight)} and ${_formatOneDecimal(maxWeight)} $unitLabel';
      });
      return;
    }

    setState(() {
      _weightKg = _unit == MeasurementUnit.metric
          ? parsedValue
          : UnitConverter.lbToKg(parsedValue);
      _weightErrorText = null;
    });
    _weightController.text = _formatOneDecimal(_displayWeightForCurrentUnit);
  }

  BmiEntry _buildCurrentEntry() {
    final result = _result!;
    final now = DateTime.now();
    final idSuffix = result.value.toStringAsFixed(1).replaceAll('.', '');
    return BmiEntry(
      id: 'bmi-${now.microsecondsSinceEpoch}-$idSuffix',
      createdAt: now,
      heightCm: _heightCm,
      weightKg: _weightKg,
      unitUsed: _unit,
      bmiValue: result.value,
      category: result.category,
      goalSnapshot: widget.activeGoal,
      profileSnapshot: widget.personalProfile,
    );
  }

  Future<void> _saveCurrentResult() async {
    if (_result == null) return;

    final entry = _buildCurrentEntry();
    await widget.onSaveResult(entry);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Result saved to history.'),
      ),
    );
  }

  Future<void> _shareCurrentResult() async {
    if (_result == null) return;

    final entry = _buildCurrentEntry();
    final shareText = buildBmiShareText(entry: entry);
    await Share.share(shareText);
  }

  void _openInsights() {
    if (_result == null) return;
    Navigator.of(context).push(AppRoutes.insights(entry: _buildCurrentEntry()));
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
            tooltip: 'History',
            onPressed: () {
              Navigator.of(context).push(
                AppRoutes.history(
                  loadEntries: widget.onLoadHistory,
                  onDeleteEntry: widget.onDeleteHistoryEntry,
                  onClearHistory: widget.onClearHistory,
                ),
              );
            },
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            tooltip: 'BMI info',
            onPressed: () {
              Navigator.of(context).push(AppRoutes.bmiInfo());
            },
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                AppRoutes.settings(
                  defaultUnit: _unit,
                  currentThemeMode: widget.currentThemeMode,
                  currentGoal: widget.activeGoal,
                  currentProfile: widget.personalProfile,
                  onDefaultUnitChanged: (unit) {
                    widget.onDefaultUnitChanged(unit);
                    if (_unit != unit) {
                      setState(() {
                        _unit = unit;
                      });
                      _syncInputControllers();
                    }
                  },
                  onThemeModeChanged: widget.onThemeModeChanged,
                  onGoalChanged: widget.onGoalChanged,
                  onProfileChanged: widget.onProfileChanged,
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
    final heightValue = _displayHeightForCurrentUnit;
    final weightValue = _displayWeightForCurrentUnit;
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
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<MeasurementUnit>(
                showSelectedIcon: true,
                style: ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.padded,
                  visualDensity: VisualDensity.standard,
                  minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 44)),
                  padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                segments: const [
                  ButtonSegment<MeasurementUnit>(
                    value: MeasurementUnit.metric,
                    label: Text(
                      'Metric',
                      softWrap: false,
                      maxLines: 1,
                    ),
                  ),
                  ButtonSegment<MeasurementUnit>(
                    value: MeasurementUnit.imperial,
                    label: Text(
                      'Imperial',
                      softWrap: false,
                      maxLines: 1,
                    ),
                  ),
                ],
                selected: <MeasurementUnit>{_unit},
                onSelectionChanged: (selection) {
                  _onUnitChanged(selection.first);
                },
              ),
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
                  _heightErrorText = null;
                  _heightController.text =
                      _formatOneDecimal(_displayHeightForCurrentUnit);
                }),
              ),
            ),
            const SizedBox(height: 12),
            _buildValueEditor(
              controller: _heightController,
              focusNode: _heightFocusNode,
              label: 'Height input',
              unit: heightUnit,
              errorText: _heightErrorText,
              onSubmitted: _applyHeightFromInput,
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
                  _weightErrorText = null;
                  _weightController.text =
                      _formatOneDecimal(_displayWeightForCurrentUnit);
                }),
              ),
            ),
            const SizedBox(height: 12),
            _buildValueEditor(
              controller: _weightController,
              focusNode: _weightFocusNode,
              label: 'Weight input',
              unit: weightUnit,
              errorText: _weightErrorText,
              onSubmitted: _applyWeightFromInput,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueEditor({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String? unit,
    required String? errorText,
    required ValueChanged<String> onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        errorText: errorText,
      ),
    );
  }

  Widget _buildCalculateButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          style: FilledButton.styleFrom(
            elevation: 0,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size.fromHeight(40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            textStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          icon: const Icon(Icons.monitor_weight_outlined),
          label: const Text('Calculate BMI'),
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
                        displayUnit: _unit,
                        activeGoal: widget.activeGoal,
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
            if (_result != null) ...[
              const SizedBox(height: 18),
              _buildResultActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: _saveCurrentResult,
            style: FilledButton.styleFrom(
              elevation: 0,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              textStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _shareCurrentResult,
            style: FilledButton.styleFrom(
              elevation: 0,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              textStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text('Share'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _openInsights,
            style: FilledButton.styleFrom(
              elevation: 0,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              textStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: const Icon(Icons.insights_outlined),
            label: const Text('Insights'),
          ),
        ),
      ],
    );
  }
}

class _StyledResultContent extends StatelessWidget {
  const _StyledResultContent({
    required super.key,
    required this.result,
    required this.heightCm,
    required this.weightKg,
    required this.displayUnit,
    required this.activeGoal,
    required this.colorScheme,
    required this.textTheme,
  });

  final BmiResult result;
  final double heightCm;
  final double weightKg;
  final MeasurementUnit displayUnit;
  final UserGoal activeGoal;
  final ColorScheme colorScheme;
  final TextTheme? textTheme;

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(colorScheme);
    final description = _descriptionForCategory(result.category);
    final tips = BmiTips.getTipsForCategory(result.category);
    final previewEntry = BmiEntry(
      id: 'preview',
      createdAt: DateTime.now(),
      heightCm: heightCm,
      weightKg: weightKg,
      unitUsed: MeasurementUnit.metric,
      bmiValue: result.value,
      category: result.category,
      goalSnapshot: activeGoal,
    );
    final healthyRange = HealthyWeightCalculator.forHeightCm(heightCm);
    final goalProgress = GoalProgressCalculator.fromEntry(entry: previewEntry);
    final healthyRangeText = healthyRange == null
        ? null
        : _healthyRangeText(healthyRange);

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
        if (healthyRange != null) ...[
          const SizedBox(height: 16),
          _ResultInfoCard(
            title: 'Healthy Weight Range',
            text: '$healthyRangeText for your current height.',
          ),
        ],
        if (goalProgress != null) ...[
          const SizedBox(height: 12),
          _ResultInfoCard(
            title: 'Goal Progress',
            text:
                '${goalProgress.summaryText}\n${_secondaryGoalLine(goalProgress)}',
          ),
        ],
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

  String _secondaryGoalLine(GoalProgress progress) {
    switch (progress.goalType) {
      case GoalType.bmi:
        final targetWeight = displayUnit == MeasurementUnit.metric
            ? progress.targetWeightKg
            : UnitConverter.kgToLb(progress.targetWeightKg);
        final unitLabel = displayUnit == MeasurementUnit.metric ? 'kg' : 'lb';
        return 'Derived target weight: ${targetWeight.toStringAsFixed(1)} $unitLabel';
      case GoalType.weight:
        return 'Derived target BMI: ${progress.targetBmi.toStringAsFixed(1)}';
    }
  }

  String _healthyRangeText(HealthyWeightRange healthyRange) {
    final minWeight = displayUnit == MeasurementUnit.metric
        ? healthyRange.minWeightKg
        : UnitConverter.kgToLb(healthyRange.minWeightKg);
    final maxWeight = displayUnit == MeasurementUnit.metric
        ? healthyRange.maxWeightKg
        : UnitConverter.kgToLb(healthyRange.maxWeightKg);
    final unitLabel = displayUnit == MeasurementUnit.metric ? 'kg' : 'lb';
    return '${minWeight.toStringAsFixed(1)} $unitLabel - ${maxWeight.toStringAsFixed(1)} $unitLabel';
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

class _ResultInfoCard extends StatelessWidget {
  const _ResultInfoCard({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
          ),
        ],
      ),
    );
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
