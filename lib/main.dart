import 'package:flutter/material.dart';

import 'package:bmi_calculator/core/theme/app_theme.dart';
import 'package:bmi_calculator/core/utils/preferences.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/ui/screens/bmi_home_screen.dart';
import 'package:bmi_calculator/ui/screens/splash_screen.dart';

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
  double _targetBmi = 22;

  @override
  void initState() {
    super.initState();
    _loadPersistedSettings();
  }

  Future<void> _loadPersistedSettings() async {
    final persistedTheme = await AppPreferences.loadThemeMode();
    final persistedUnit = await AppPreferences.loadDefaultUnit();
    final persistedTargetBmi = await AppPreferences.loadTargetBmi();

    if (!mounted) return;
    setState(() {
      _themeMode = persistedTheme ?? ThemeMode.system;
      _defaultUnit = persistedUnit ?? MeasurementUnit.metric;
      _targetBmi = persistedTargetBmi ?? 22;
    });
  }

  void _onThemeModeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    AppPreferences.saveThemeMode(mode);
  }

  void _onDefaultUnitChanged(MeasurementUnit unit) {
    setState(() {
      _defaultUnit = unit;
    });
    AppPreferences.saveDefaultUnit(unit);
  }

  void _onTargetBmiChanged(double targetBmi) {
    setState(() {
      _targetBmi = targetBmi;
    });
    AppPreferences.saveTargetBmi(targetBmi);
  }

  @override
  Widget build(BuildContext context) {
    final homeScreen = BmiHomeScreen(
      defaultUnit: _defaultUnit,
      initialTargetBmi: _targetBmi,
      currentThemeMode: _themeMode,
      onDefaultUnitChanged: _onDefaultUnitChanged,
      onThemeModeChanged: _onThemeModeChanged,
      onTargetBmiChanged: _onTargetBmiChanged,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: SplashScreen(
        nextScreen: homeScreen,
      ),
    );
  }
}
