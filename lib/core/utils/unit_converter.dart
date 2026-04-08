/// Utility methods for converting between metric and imperial units.
class UnitConverter {
  UnitConverter._();

  static const double _kgToLb = 2.2046226218;
  static const double _cmToIn = 0.3937007874;

  static double kgToLb(double kilograms) => kilograms * _kgToLb;

  static double lbToKg(double pounds) => pounds / _kgToLb;

  static double cmToIn(double centimeters) => centimeters * _cmToIn;

  static double inToCm(double inches) => inches / _cmToIn;
}
