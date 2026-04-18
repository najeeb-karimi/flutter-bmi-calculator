import 'package:bmi_calculator/models/healthy_weight_range.dart';

class HealthyWeightCalculator {
  HealthyWeightCalculator._();

  static const double _minHealthyBmi = 18.5;
  static const double _maxHealthyBmi = 24.9;

  static HealthyWeightRange? forHeightCm(double heightCm) {
    if (heightCm <= 0) return null;
    final heightM = heightCm / 100;
    final squared = heightM * heightM;
    return HealthyWeightRange(
      minWeightKg: _minHealthyBmi * squared,
      maxWeightKg: _maxHealthyBmi * squared,
    );
  }
}
