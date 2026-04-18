import 'package:flutter/material.dart';

import 'package:bmi_calculator/core/utils/unit_converter.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/models/personal_profile.dart';
import 'package:bmi_calculator/models/user_goal.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.defaultUnit,
    required this.currentThemeMode,
    required this.currentGoal,
    required this.currentProfile,
    required this.onDefaultUnitChanged,
    required this.onThemeModeChanged,
    required this.onGoalChanged,
    required this.onProfileChanged,
  });

  final MeasurementUnit defaultUnit;
  final ThemeMode currentThemeMode;
  final UserGoal currentGoal;
  final PersonalProfile? currentProfile;
  final ValueChanged<MeasurementUnit> onDefaultUnitChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<UserGoal> onGoalChanged;
  final ValueChanged<PersonalProfile?> onProfileChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const double _minBmiGoal = 18;
  static const double _maxBmiGoal = 35;
  static const int _minAge = 18;
  static const int _maxAge = 120;
  static const double _minWeightKg = 30;
  static const double _maxWeightKg = 150;

  late MeasurementUnit _defaultUnit;
  late ThemeMode _themeMode;
  late GoalType _goalType;
  late final TextEditingController _goalController;
  late final TextEditingController _ageController;
  SexAtBirth? _sexAtBirth;
  ActivityLevel? _activityLevel;
  String? _goalErrorText;
  String? _ageErrorText;

  @override
  void initState() {
    super.initState();
    _defaultUnit = widget.defaultUnit;
    _themeMode = widget.currentThemeMode;
    _goalType = widget.currentGoal.type;
    _goalController = TextEditingController();
    _ageController = TextEditingController();
    _loadInitialValues();
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultUnit != widget.defaultUnit ||
        oldWidget.currentThemeMode != widget.currentThemeMode ||
        oldWidget.currentGoal != widget.currentGoal ||
        oldWidget.currentProfile != widget.currentProfile) {
      _defaultUnit = widget.defaultUnit;
      _themeMode = widget.currentThemeMode;
      _goalType = widget.currentGoal.type;
      _loadInitialValues();
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _loadInitialValues() {
    final profile = widget.currentProfile;
    _sexAtBirth = profile?.sexAtBirth;
    _activityLevel = profile?.activityLevel;
    _ageController.text = profile?.age?.toString() ?? '';
    _goalController.text = _formatGoalForDisplay(widget.currentGoal);
  }

  String _formatGoalForDisplay(UserGoal goal) {
    switch (goal.type) {
      case GoalType.bmi:
        return goal.value.toStringAsFixed(1);
      case GoalType.weight:
        final displayWeight = _defaultUnit == MeasurementUnit.metric
            ? goal.value
            : UnitConverter.kgToLb(goal.value);
        return displayWeight.toStringAsFixed(1);
    }
  }

  String get _goalSuffix {
    switch (_goalType) {
      case GoalType.bmi:
        return 'BMI';
      case GoalType.weight:
        return _defaultUnit == MeasurementUnit.metric ? 'kg' : 'lb';
    }
  }

  Future<void> _saveHealthSettings() async {
    final rawAge = _ageController.text.trim();
    final rawGoal = _goalController.text.trim();
    final parsedAge = rawAge.isEmpty ? null : int.tryParse(rawAge);
    final parsedGoal = double.tryParse(rawGoal);

    setState(() {
      _ageErrorText = null;
      _goalErrorText = null;
    });

    if (parsedAge != null && (parsedAge < _minAge || parsedAge > _maxAge)) {
      setState(() {
        _ageErrorText = 'Enter an age between $_minAge and $_maxAge';
      });
      return;
    }

    if (parsedGoal == null) {
      setState(() {
        _goalErrorText = 'Enter a valid goal value';
      });
      return;
    }

    if (_goalType == GoalType.bmi &&
        (parsedGoal < _minBmiGoal || parsedGoal > _maxBmiGoal)) {
      setState(() {
        _goalErrorText =
            'Enter a BMI goal between ${_minBmiGoal.toStringAsFixed(1)} and ${_maxBmiGoal.toStringAsFixed(1)}';
      });
      return;
    }

    final minWeight = _defaultUnit == MeasurementUnit.metric
        ? _minWeightKg
        : UnitConverter.kgToLb(_minWeightKg);
    final maxWeight = _defaultUnit == MeasurementUnit.metric
        ? _maxWeightKg
        : UnitConverter.kgToLb(_maxWeightKg);

    if (_goalType == GoalType.weight &&
        (parsedGoal < minWeight || parsedGoal > maxWeight)) {
      setState(() {
        _goalErrorText =
            'Enter a weight goal between ${minWeight.toStringAsFixed(1)} and ${maxWeight.toStringAsFixed(1)} $_goalSuffix';
      });
      return;
    }

    final goal = UserGoal(
      type: _goalType,
      value: _goalType == GoalType.bmi
          ? parsedGoal
          : (_defaultUnit == MeasurementUnit.metric
              ? parsedGoal
              : UnitConverter.lbToKg(parsedGoal)),
    );

    final profile = PersonalProfile(
      age: parsedAge,
      sexAtBirth: _sexAtBirth,
      activityLevel: _activityLevel,
    );

    widget.onGoalChanged(goal);
    widget.onProfileChanged(
      parsedAge == null && _sexAtBirth == null && _activityLevel == null
          ? null
          : profile,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Health settings saved.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceContainerLowest,
              ],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Personalize your experience',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Manage appearance, goals, and optional profile details that shape your insights.',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SettingsCard(
                        icon: Icons.straighten_rounded,
                        title: 'Default units',
                        subtitle: 'Choose app-wide preferred units',
                        child: DropdownButtonFormField<MeasurementUnit>(
                          value: _defaultUnit,
                          decoration: const InputDecoration(
                            labelText: 'Measurement system',
                          ),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _defaultUnit = value;
                              _goalController.text =
                                  _formatGoalForDisplay(widget.currentGoal);
                            });
                            widget.onDefaultUnitChanged(value);
                          },
                          items: MeasurementUnit.values
                              .map(
                                (unit) => DropdownMenuItem<MeasurementUnit>(
                                  value: unit,
                                  child: Text(unit.label),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SettingsCard(
                        icon: Icons.palette_outlined,
                        title: 'Theme',
                        subtitle: 'Choose app appearance mode',
                        child: DropdownButtonFormField<ThemeMode>(
                          value: _themeMode,
                          decoration: const InputDecoration(
                            labelText: 'Appearance',
                          ),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _themeMode = value;
                            });
                            widget.onThemeModeChanged(value);
                          },
                          items: const [
                            DropdownMenuItem<ThemeMode>(
                              value: ThemeMode.system,
                              child: Text('System'),
                            ),
                            DropdownMenuItem<ThemeMode>(
                              value: ThemeMode.light,
                              child: Text('Light'),
                            ),
                            DropdownMenuItem<ThemeMode>(
                              value: ThemeMode.dark,
                              child: Text('Dark'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SettingsCard(
                        icon: Icons.flag_outlined,
                        title: 'Goal',
                        subtitle: 'Track either a BMI target or a weight target',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SegmentedButton<GoalType>(
                              segments: const [
                                ButtonSegment<GoalType>(
                                  value: GoalType.bmi,
                                  label: Text('BMI'),
                                ),
                                ButtonSegment<GoalType>(
                                  value: GoalType.weight,
                                  label: Text('Weight'),
                                ),
                              ],
                              selected: <GoalType>{_goalType},
                              onSelectionChanged: (selection) {
                                setState(() {
                                  _goalType = selection.first;
                                  _goalErrorText = null;
                                  _goalController.text = _goalType == GoalType.bmi
                                      ? '22.0'
                                      : (_defaultUnit == MeasurementUnit.metric
                                          ? '70.0'
                                          : UnitConverter.kgToLb(70)
                                              .toStringAsFixed(1));
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _goalController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Goal value',
                                suffixText: _goalSuffix,
                                errorText: _goalErrorText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SettingsCard(
                        icon: Icons.person_outline_rounded,
                        title: 'Personal Profile',
                        subtitle:
                            'Optional inputs used to tailor explanations and wording',
                        child: Column(
                          children: [
                            TextField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Age',
                                errorText: _ageErrorText,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<SexAtBirth>(
                              value: _sexAtBirth,
                              decoration: const InputDecoration(
                                labelText: 'Sex at birth',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _sexAtBirth = value;
                                });
                              },
                              items: const [
                                DropdownMenuItem<SexAtBirth>(
                                  value: SexAtBirth.female,
                                  child: Text('Female'),
                                ),
                                DropdownMenuItem<SexAtBirth>(
                                  value: SexAtBirth.male,
                                  child: Text('Male'),
                                ),
                                DropdownMenuItem<SexAtBirth>(
                                  value: SexAtBirth.other,
                                  child: Text('Other'),
                                ),
                                DropdownMenuItem<SexAtBirth>(
                                  value: SexAtBirth.preferNotToSay,
                                  child: Text('Prefer not to say'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<ActivityLevel>(
                              value: _activityLevel,
                              decoration: const InputDecoration(
                                labelText: 'Activity level',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _activityLevel = value;
                                });
                              },
                              items: const [
                                DropdownMenuItem<ActivityLevel>(
                                  value: ActivityLevel.sedentary,
                                  child: Text('Sedentary'),
                                ),
                                DropdownMenuItem<ActivityLevel>(
                                  value: ActivityLevel.light,
                                  child: Text('Light'),
                                ),
                                DropdownMenuItem<ActivityLevel>(
                                  value: ActivityLevel.moderate,
                                  child: Text('Moderate'),
                                ),
                                DropdownMenuItem<ActivityLevel>(
                                  value: ActivityLevel.active,
                                  child: Text('Active'),
                                ),
                                DropdownMenuItem<ActivityLevel>(
                                  value: ActivityLevel.veryActive,
                                  child: Text('Very active'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _saveHealthSettings,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save health settings'),
                      ),
                    ],
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: colorScheme.secondary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}
