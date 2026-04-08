import 'package:flutter_test/flutter_test.dart';

import 'package:bmi_calculator/core/utils/bmi_calculator.dart';
import 'package:bmi_calculator/models/bmi_result.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';

void main() {
  group('BmiCalculator.calculateBmiKgM', () {
    test('returns expected BMI for known metric inputs', () {
      final bmi = BmiCalculator.calculateBmiKgM(70, 175);
      expect(bmi, closeTo(22.86, 0.01));
    });

    test('returns 0 for zero height', () {
      final bmi = BmiCalculator.calculateBmiKgM(70, 0);
      expect(bmi, 0);
    });
  });

  group('BmiCalculator.getCategory', () {
    test('maps to underweight below 18.5', () {
      expect(BmiCalculator.getCategory(18.4), BmiCategory.underweight);
    });

    test('maps to normal from 18.5 to below 25', () {
      expect(BmiCalculator.getCategory(18.5), BmiCategory.normal);
      expect(BmiCalculator.getCategory(24.9), BmiCategory.normal);
    });

    test('maps to overweight from 25 to below 30', () {
      expect(BmiCalculator.getCategory(25.0), BmiCategory.overweight);
      expect(BmiCalculator.getCategory(29.9), BmiCategory.overweight);
    });

    test('maps to obese at 30 and above', () {
      expect(BmiCalculator.getCategory(30.0), BmiCategory.obese);
    });
  });

  group('BmiCalculator.computeWithUnit', () {
    test('matches metric and imperial calculations for equivalent values', () {
      final metric = BmiCalculator.computeWithUnit(
        weight: 70,
        height: 175,
        unit: MeasurementUnit.metric,
      );

      final imperial = BmiCalculator.computeWithUnit(
        weight: 154.3236, // ~70kg
        height: 68.8976, // ~175cm
        unit: MeasurementUnit.imperial,
      );

      expect(imperial.value, closeTo(metric.value, 0.02));
      expect(imperial.category, metric.category);
    });
  });
}
