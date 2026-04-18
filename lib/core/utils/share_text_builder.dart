import 'package:bmi_calculator/core/utils/unit_converter.dart';
import 'package:bmi_calculator/models/bmi_entry.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/models/user_goal.dart';

String buildBmiShareText({required BmiEntry entry}) {
  final unit = entry.unitUsed;
  final height = unit == MeasurementUnit.metric
      ? entry.heightCm
      : UnitConverter.cmToIn(entry.heightCm);
  final weight = unit == MeasurementUnit.metric
      ? entry.weightKg
      : UnitConverter.kgToLb(entry.weightKg);
  final heightUnit = unit == MeasurementUnit.metric ? 'cm' : 'in';
  final weightUnit = unit == MeasurementUnit.metric ? 'kg' : 'lb';
  final localDateTime = entry.createdAt.toLocal();
  final dateText = _formatDateTime(localDateTime);
  final targetText = entry.goalSnapshot != null
      ? '\n${_goalText(entry.goalSnapshot!, unit)}'
      : '';

  return 'BMI Result\n'
      'BMI: ${entry.bmiValue.toStringAsFixed(1)} (${entry.category.name})\n'
      'Date: $dateText\n'
      'Height: ${height.toStringAsFixed(1)} $heightUnit\n'
      'Weight: ${weight.toStringAsFixed(1)} $weightUnit'
      '$targetText';
}

String _goalText(UserGoal goal, MeasurementUnit unit) {
  switch (goal.type) {
    case GoalType.bmi:
      return 'Target BMI: ${goal.value.toStringAsFixed(1)}';
    case GoalType.weight:
      final displayWeight =
          unit == MeasurementUnit.metric ? goal.value : UnitConverter.kgToLb(goal.value);
      final weightUnit = unit == MeasurementUnit.metric ? 'kg' : 'lb';
      return 'Target Weight: ${displayWeight.toStringAsFixed(1)} $weightUnit';
  }
}

String _formatDateTime(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.year}-$month-$day $hour:$minute';
}
