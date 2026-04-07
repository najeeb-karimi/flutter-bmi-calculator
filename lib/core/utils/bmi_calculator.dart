import 'package:bmi_calculator/models/bmi_result.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/core/utils/unit_converter.dart';

/// BMI calculation and category mapping (metric: kg and cm).
class BmiCalculator {
  BmiCalculator._();

  /// Computes BMI from weight in kg and height in cm.
  ///
  /// Formula: weight / (height in m)².
  /// Returns 0 if height is 0 or invalid.
  static double calculateBmiKgM(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Maps a BMI value to a [BmiCategory] (WHO-style ranges).
  static BmiCategory getCategory(double bmi) {
    if (bmi < 18.5) return BmiCategory.underweight;
    if (bmi < 25) return BmiCategory.normal;
    if (bmi < 30) return BmiCategory.overweight;
    return BmiCategory.obese;
  }

  /// Computes BMI and returns a [BmiResult] with value and category.
  static BmiResult compute(double weightKg, double heightCm) {
    final value = calculateBmiKgM(weightKg, heightCm);
    final category = getCategory(value);
    return BmiResult(value: value, category: category);
  }

  /// Computes BMI from either metric or imperial input values.
  ///
  /// - Metric: [weight] in kg, [height] in cm
  /// - Imperial: [weight] in lb, [height] in inches
  ///
  /// Internally, values are converted to metric before calculation.
  static BmiResult computeWithUnit({
    required double weight,
    required double height,
    required MeasurementUnit unit,
  }) {
    switch (unit) {
      case MeasurementUnit.metric:
        return compute(weight, height);
      case MeasurementUnit.imperial:
        final weightKg = UnitConverter.lbToKg(weight);
        final heightCm = UnitConverter.inToCm(height);
        return compute(weightKg, heightCm);
    }
  }
}
