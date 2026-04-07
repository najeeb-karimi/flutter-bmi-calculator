import 'package:flutter/material.dart';

import 'package:bmi_calculator/core/theme/app_theme.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/ui/screens/bmi_home_screen.dart';

void main() {
  runApp(const BmiCalculatorApp());
}

class BmiCalculatorApp extends StatefulWidget {
  const BmiCalculatorApp({super.key});

  @override
  State<BmiCalculatorApp> createState() => _BmiCalculatorAppState();
}

class _BmiCalculatorAppState extends State<BmiCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.system;
  MeasurementUnit _defaultUnit = MeasurementUnit.metric;

  void _onThemeModeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void _onDefaultUnitChanged(MeasurementUnit unit) {
    setState(() {
      _defaultUnit = unit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: BmiHomeScreen(
        defaultUnit: _defaultUnit,
        currentThemeMode: _themeMode,
        onDefaultUnitChanged: _onDefaultUnitChanged,
        onThemeModeChanged: _onThemeModeChanged,
      ),
    );
  }
}
