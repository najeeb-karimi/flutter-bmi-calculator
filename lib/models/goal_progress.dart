import 'package:bmi_calculator/models/user_goal.dart';

class GoalProgress {
  const GoalProgress({
    required this.goalType,
    required this.goalValue,
    required this.targetWeightKg,
    required this.targetBmi,
    required this.weightDeltaKg,
    required this.bmiDelta,
    required this.isWithinGoalThreshold,
    required this.summaryText,
  });

  final GoalType goalType;
  final double goalValue;
  final double targetWeightKg;
  final double targetBmi;
  final double weightDeltaKg;
  final double bmiDelta;
  final bool isWithinGoalThreshold;
  final String summaryText;
}
