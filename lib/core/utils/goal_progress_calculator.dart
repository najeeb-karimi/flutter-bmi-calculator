import 'package:bmi_calculator/models/bmi_entry.dart';
import 'package:bmi_calculator/models/goal_progress.dart';
import 'package:bmi_calculator/models/user_goal.dart';

class GoalProgressCalculator {
  GoalProgressCalculator._();

  static GoalProgress? fromEntry({required BmiEntry entry}) {
    final goal = entry.goalSnapshot;
    if (goal == null || entry.heightCm <= 0) return null;

    final heightM = entry.heightCm / 100;
    final currentBmi = entry.bmiValue;
    final currentWeightKg = entry.weightKg;

    switch (goal.type) {
      case GoalType.bmi:
        final targetWeightKg = goal.value * heightM * heightM;
        final weightDeltaKg = targetWeightKg - currentWeightKg;
        final bmiDelta = goal.value - currentBmi;
        return GoalProgress(
          goalType: goal.type,
          goalValue: goal.value,
          targetWeightKg: targetWeightKg,
          targetBmi: goal.value,
          weightDeltaKg: weightDeltaKg,
          bmiDelta: bmiDelta,
          isWithinGoalThreshold: bmiDelta.abs() < 0.3,
          summaryText: _summaryForGoal(
            goalType: goal.type,
            weightDeltaKg: weightDeltaKg,
            bmiDelta: bmiDelta,
            targetValue: goal.value,
          ),
        );
      case GoalType.weight:
        final targetWeightKg = goal.value;
        final targetBmi = targetWeightKg / (heightM * heightM);
        final weightDeltaKg = targetWeightKg - currentWeightKg;
        final bmiDelta = targetBmi - currentBmi;
        return GoalProgress(
          goalType: goal.type,
          goalValue: goal.value,
          targetWeightKg: targetWeightKg,
          targetBmi: targetBmi,
          weightDeltaKg: weightDeltaKg,
          bmiDelta: bmiDelta,
          isWithinGoalThreshold: weightDeltaKg.abs() < 0.5,
          summaryText: _summaryForGoal(
            goalType: goal.type,
            weightDeltaKg: weightDeltaKg,
            bmiDelta: bmiDelta,
            targetValue: goal.value,
          ),
        );
    }
  }

  static String _summaryForGoal({
    required GoalType goalType,
    required double weightDeltaKg,
    required double bmiDelta,
    required double targetValue,
  }) {
    switch (goalType) {
      case GoalType.bmi:
        if (bmiDelta.abs() < 0.3) {
          return 'You are very close to your BMI goal of ${targetValue.toStringAsFixed(1)}.';
        }
        if (bmiDelta < 0) {
          return 'You are ${bmiDelta.abs().toStringAsFixed(1)} BMI points above your goal.';
        }
        return 'You are ${bmiDelta.toStringAsFixed(1)} BMI points below your goal.';
      case GoalType.weight:
        if (weightDeltaKg.abs() < 0.5) {
          return 'You are very close to your weight goal of ${targetValue.toStringAsFixed(1)} kg.';
        }
        if (weightDeltaKg < 0) {
          return 'You are ${weightDeltaKg.abs().toStringAsFixed(1)} kg above your weight goal.';
        }
        return 'You are ${weightDeltaKg.toStringAsFixed(1)} kg below your weight goal.';
    }
  }
}
