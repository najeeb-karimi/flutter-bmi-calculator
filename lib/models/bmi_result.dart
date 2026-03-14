/// BMI category based on WHO-style ranges.
enum BmiCategory {
  underweight,
  normal,
  overweight,
  obese,
}

/// Result of a BMI calculation: value and category.
class BmiResult {
  const BmiResult({
    required this.value,
    required this.category,
  });

  /// BMI value (e.g. 22.5).
  final double value;

  /// Category derived from [value].
  final BmiCategory category;

  /// Short display label for the category (e.g. "Normal").
  String get categoryLabel {
    switch (category) {
      case BmiCategory.underweight:
        return 'Underweight';
      case BmiCategory.normal:
        return 'Normal';
      case BmiCategory.overweight:
        return 'Overweight';
      case BmiCategory.obese:
        return 'Obese';
    }
  }
}
