import 'package:bmi_calculator/models/bmi_result.dart';

/// Health tips and suggestions mapped to each BMI category.
///
/// Used to show contextual advice in the result card.
class BmiTips {
  BmiTips._();

  static const Map<BmiCategory, List<String>> _tipsByCategory = {
    BmiCategory.underweight: [
      'Consider eating more frequent, nutrient-dense meals.',
      'Include healthy fats and protein in your diet.',
      'Talk to a doctor or dietitian for personalized advice.',
    ],
    BmiCategory.normal: [
      'Maintain your current habits with a balanced diet and regular activity.',
      'Stay hydrated and get enough sleep.',
    ],
    BmiCategory.overweight: [
      'Try to add more movement into your daily routine.',
      'Focus on whole foods and portion sizes.',
      'Small, sustainable changes often work best.',
    ],
    BmiCategory.obese: [
      'Consult a healthcare provider for a safe plan tailored to you.',
      'Focus on gradual changes in diet and physical activity.',
      'Even modest weight loss can improve health outcomes.',
    ],
  };

  /// Returns the list of tips for [category].
  static List<String> getTipsForCategory(BmiCategory category) {
    return List.unmodifiable(_tipsByCategory[category] ?? []);
  }
}
