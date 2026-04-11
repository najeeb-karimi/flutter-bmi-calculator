import 'package:flutter/material.dart';

import 'package:bmi_calculator/models/bmi_entry.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/ui/screens/bmi_info_screen.dart';
import 'package:bmi_calculator/ui/screens/history_screen.dart';
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

  static Route<void> history({
    required Future<List<BmiEntry>> Function() loadEntries,
    required Future<void> Function(String id) onDeleteEntry,
    required Future<void> Function() onClearHistory,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => HistoryScreen(
        loadEntries: loadEntries,
        onDeleteEntry: onDeleteEntry,
        onClearHistory: onClearHistory,
      ),
    );
  }

  static Route<void> insightsPlaceholder() {
    return MaterialPageRoute<void>(
      builder: (_) => const InsightsPlaceholderScreen(),
    );
  }
}
