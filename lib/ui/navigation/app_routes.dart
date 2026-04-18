import 'package:flutter/material.dart';

import 'package:bmi_calculator/models/bmi_entry.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/models/personal_profile.dart';
import 'package:bmi_calculator/models/user_goal.dart';
import 'package:bmi_calculator/ui/screens/bmi_info_screen.dart';
import 'package:bmi_calculator/ui/screens/history_screen.dart';
import 'package:bmi_calculator/ui/screens/insights_screen.dart';
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
    required UserGoal currentGoal,
    required PersonalProfile? currentProfile,
    required ValueChanged<MeasurementUnit> onDefaultUnitChanged,
    required ValueChanged<ThemeMode> onThemeModeChanged,
    required ValueChanged<UserGoal> onGoalChanged,
    required ValueChanged<PersonalProfile?> onProfileChanged,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => SettingsScreen(
        defaultUnit: defaultUnit,
        currentThemeMode: currentThemeMode,
        currentGoal: currentGoal,
        currentProfile: currentProfile,
        onDefaultUnitChanged: onDefaultUnitChanged,
        onThemeModeChanged: onThemeModeChanged,
        onGoalChanged: onGoalChanged,
        onProfileChanged: onProfileChanged,
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

  static Route<void> insights({required BmiEntry entry}) {
    return MaterialPageRoute<void>(
      builder: (_) => InsightsScreen(entry: entry),
    );
  }
}
