import 'package:flutter_test/flutter_test.dart';

import 'package:bmi_calculator/core/utils/share_text_builder.dart';
import 'package:bmi_calculator/models/bmi_entry.dart';
import 'package:bmi_calculator/models/bmi_result.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/models/user_goal.dart';

void main() {
  test('buildBmiShareText returns the expected plain-text summary', () {
    final text = buildBmiShareText(
      entry: BmiEntry(
        id: 'entry-1',
        createdAt: DateTime(2026, 4, 11, 14, 5),
        heightCm: 170,
        weightKg: 70,
        unitUsed: MeasurementUnit.metric,
        bmiValue: 24.2,
        category: BmiCategory.normal,
        goalSnapshot: const UserGoal(type: GoalType.bmi, value: 22),
      ),
    );

    expect(text, contains('BMI Result'));
    expect(text, contains('BMI: 24.2 (normal)'));
    expect(text, contains('Height: 170.0 cm'));
    expect(text, contains('Weight: 70.0 kg'));
    expect(text, contains('Target BMI: 22.0'));
  });
}
