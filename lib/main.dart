import 'package:flutter/material.dart';

import 'package:bmi_calculator/core/theme/app_theme.dart';

void main() {
  runApp(const BmiCalculatorApp());
}

class BmiCalculatorApp extends StatelessWidget {
  const BmiCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home:
          const Placeholder(), // Will be replaced with BMI home screen in later phases.
    );
  }
}
