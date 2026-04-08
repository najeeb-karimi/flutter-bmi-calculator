import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bmi_calculator/models/measurement_unit.dart';

/// Centralized helper for app settings persistence.
class AppPreferences {
  AppPreferences._();

  static const String _themeModeKey = 'theme_mode';
  static const String _defaultUnitKey = 'default_unit';
  static const String _targetBmiKey = 'target_bmi';

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  static Future<ThemeMode?> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeModeKey);
    if (raw == null) return null;
    return ThemeMode.values
        .where((mode) => mode.name == raw)
        .cast<ThemeMode?>()
        .firstOrNull;
  }

  static Future<void> saveDefaultUnit(MeasurementUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultUnitKey, unit.name);
  }

  static Future<MeasurementUnit?> loadDefaultUnit() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_defaultUnitKey);
    if (raw == null) return null;
    return MeasurementUnit.values
        .where((unit) => unit.name == raw)
        .cast<MeasurementUnit?>()
        .firstOrNull;
  }

  static Future<void> saveTargetBmi(double targetBmi) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_targetBmiKey, targetBmi);
  }

  static Future<double?> loadTargetBmi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_targetBmiKey);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
