import 'package:flutter/material.dart';

import 'package:bmi_calculator/core/theme/app_theme.dart';
import 'package:bmi_calculator/ui/screens/bmi_home_screen.dart';

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
      home: const BmiHomeScreen(),
    );
  }
}
