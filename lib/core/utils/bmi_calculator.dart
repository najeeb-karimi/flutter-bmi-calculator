import 'package:bmi_calculator/models/bmi_result.dart';

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
}
