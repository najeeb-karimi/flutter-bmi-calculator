import 'package:flutter/material.dart';

import 'package:bmi_calculator/core/constants/bmi_tips.dart';
import 'package:bmi_calculator/core/utils/goal_progress_calculator.dart';
import 'package:bmi_calculator/core/utils/healthy_weight_calculator.dart';
import 'package:bmi_calculator/core/utils/unit_converter.dart';
import 'package:bmi_calculator/models/bmi_entry.dart';
import 'package:bmi_calculator/models/bmi_result.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/models/personal_profile.dart';
import 'package:bmi_calculator/models/user_goal.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({
    super.key,
    required this.entry,
  });

  final BmiEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = GoalProgressCalculator.fromEntry(entry: entry);
    final range = HealthyWeightCalculator.forHeightCm(entry.heightCm);
    final measurements = _measurementSummary(entry);
    final tailoredTips = _tailoredTips(entry.profileSnapshot, entry.category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _InsightsSection(
              title: 'BMI Meaning',
              child: Text(
                'Your BMI is ${entry.bmiValue.toStringAsFixed(1)}. It is a screening number based on your height and weight, designed to offer a broad weight-health reference point.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
            _InsightsSection(
              title: 'Current Category Explanation',
              child: Text(
                _categoryExplanation(entry.category),
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
            _InsightsSection(
              title: 'Healthy Weight Range',
              child: Text(
                range == null
                    ? 'Healthy range is unavailable until a valid height is provided.'
                    : '${range.minWeightKg.toStringAsFixed(1)} kg to ${range.maxWeightKg.toStringAsFixed(1)} kg for your current height. Current measurement snapshot: $measurements.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
            _InsightsSection(
              title: 'Goal Progress',
              child: Text(
                progress == null
                    ? 'No active goal snapshot was found for this entry.'
                    : '${progress.summaryText} ${_goalSecondary(progress.goalType, progress.targetWeightKg, progress.targetBmi)}',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
            _InsightsSection(
              title: 'Tailored Tips',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tailoredTips
                    .map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '- $tip',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            _InsightsSection(
              title: 'Medical Disclaimer and Next Steps',
              child: Text(
                'BMI is a useful screening metric, but it is not a diagnosis. Use it as a starting point, not a final judgment. If you have health concerns, a major goal, or a medical condition, consult a qualified healthcare professional.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightsSection extends StatelessWidget {
  const _InsightsSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

String _categoryExplanation(BmiCategory category) {
  switch (category) {
    case BmiCategory.underweight:
      return 'This result falls below the common normal BMI range. It may be worth reviewing your nutrition, energy levels, and general health context.';
    case BmiCategory.normal:
      return 'This result falls within the commonly used normal BMI range. Maintaining your current routine may help preserve that balance.';
    case BmiCategory.overweight:
      return 'This result falls above the common normal BMI range. Steady lifestyle adjustments can often help move closer to your goal.';
    case BmiCategory.obese:
      return 'This result falls well above the common normal BMI range. A structured, supportive plan may be more effective than quick changes.';
  }
}

String _goalSecondary(GoalType goalType, double targetWeightKg, double targetBmi) {
  switch (goalType) {
    case GoalType.bmi:
      return 'That goal corresponds to a target weight of ${targetWeightKg.toStringAsFixed(1)} kg.';
    case GoalType.weight:
      return 'That goal corresponds to a target BMI of ${targetBmi.toStringAsFixed(1)}.';
  }
}

String _measurementSummary(BmiEntry entry) {
  final isMetric = entry.unitUsed == MeasurementUnit.metric;
  final height = isMetric ? entry.heightCm : UnitConverter.cmToIn(entry.heightCm);
  final weight = isMetric ? entry.weightKg : UnitConverter.kgToLb(entry.weightKg);
  return 'Height ${height.toStringAsFixed(1)} ${isMetric ? 'cm' : 'in'}, weight ${weight.toStringAsFixed(1)} ${isMetric ? 'kg' : 'lb'}';
}

List<String> _tailoredTips(PersonalProfile? profile, BmiCategory category) {
  final tips = [...BmiTips.getTipsForCategory(category)];
  if (profile == null) {
    return tips;
  }
  if (profile.activityLevel == ActivityLevel.sedentary) {
    tips.add('Consider building movement into your week gradually if your routine is mostly sedentary.');
  } else if (profile.activityLevel == ActivityLevel.active ||
      profile.activityLevel == ActivityLevel.veryActive) {
    tips.add('Balance training effort with enough recovery, hydration, and sleep.');
  }
  if (profile.sexAtBirth == SexAtBirth.preferNotToSay || profile.sexAtBirth == null) {
    return tips;
  }
  tips.add('Your profile information is used only to adjust wording and context, not the BMI calculation itself.');
  return tips;
}
