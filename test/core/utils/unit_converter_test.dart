import 'package:flutter_test/flutter_test.dart';

import 'package:bmi_calculator/core/utils/unit_converter.dart';

void main() {
  group('UnitConverter', () {
    test('converts kg to lb and back', () {
      final pounds = UnitConverter.kgToLb(70);
      final kilograms = UnitConverter.lbToKg(pounds);

      expect(pounds, closeTo(154.3236, 0.0001));
      expect(kilograms, closeTo(70, 0.0001));
    });

    test('converts cm to in and back', () {
      final inches = UnitConverter.cmToIn(175);
      final centimeters = UnitConverter.inToCm(inches);

      expect(inches, closeTo(68.8976, 0.0001));
      expect(centimeters, closeTo(175, 0.0001));
    });
  });
}
