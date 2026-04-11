import 'package:flutter/material.dart';

import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/ui/screens/bmi_info_screen.dart';
import 'package:bmi_calculator/ui/screens/history_placeholder_screen.dart';
import 'package:bmi_calculator/ui/screens/insights_placeholder_screen.dart';
import 'package:bmi_calculator/ui/screens/settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  static Route<void> bmiInfo() {
    return MaterialPageRoute<void>(
      builder: (_) => const BmiInfoScreen(),
    );
  }

  static Route<void> settings({
    required MeasurementUnit defaultUnit,
    required ThemeMode currentThemeMode,
    required ValueChanged<MeasurementUnit> onDefaultUnitChanged,
    required ValueChanged<ThemeMode> onThemeModeChanged,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => SettingsScreen(
        defaultUnit: defaultUnit,
        currentThemeMode: currentThemeMode,
        onDefaultUnitChanged: onDefaultUnitChanged,
        onThemeModeChanged: onThemeModeChanged,
      ),
    );
  }

  static Route<void> historyPlaceholder() {
    return MaterialPageRoute<void>(
      builder: (_) => const HistoryPlaceholderScreen(),
    );
  }

  static Route<void> insightsPlaceholder() {
    return MaterialPageRoute<void>(
      builder: (_) => const InsightsPlaceholderScreen(),
    );
  }
}
