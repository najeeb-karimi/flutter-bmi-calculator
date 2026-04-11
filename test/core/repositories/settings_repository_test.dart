import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bmi_calculator/core/repositories/settings_repository.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/models/personal_profile.dart';
import 'package:bmi_calculator/models/reminder_settings.dart';
import 'package:bmi_calculator/models/user_goal.dart';

void main() {
  group('SettingsRepository migration', () {
    test('migrates legacy target BMI when active goal is missing', () async {
      SharedPreferences.setMockInitialValues({
        'target_bmi': 24.5,
      });
      final prefs = await SharedPreferences.getInstance();
      final repository = SettingsRepository(prefs);

      await repository.migrateLegacySettingsIfNeeded();
      final goal = await repository.loadGoal();

      expect(goal, const UserGoal(type: GoalType.bmi, value: 24.5));
      expect(prefs.getDouble('target_bmi'), 24.5);
    });

    test('creates a default BMI goal when no legacy value exists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = SettingsRepository(prefs);

      await repository.migrateLegacySettingsIfNeeded();
      final goal = await repository.loadGoal();

      expect(goal, const UserGoal(type: GoalType.bmi, value: 22));
    });

    test('does not overwrite an existing migrated goal', () async {
      SharedPreferences.setMockInitialValues({
        'target_bmi': 19.5,
        'active_goal_json': '{"type":"weight","value":65.0}',
      });
      final prefs = await SharedPreferences.getInstance();
      final repository = SettingsRepository(prefs);

      await repository.migrateLegacySettingsIfNeeded();
      final goal = await repository.loadGoal();

      expect(goal, const UserGoal(type: GoalType.weight, value: 65));
    });
  });

  group('SettingsRepository persistence', () {
    test('saves and loads theme mode and default unit', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = SettingsRepository(prefs);

      await repository.saveThemeMode(ThemeMode.dark);
      await repository.saveDefaultUnit(MeasurementUnit.imperial);

      expect(await repository.loadThemeMode(), ThemeMode.dark);
      expect(await repository.loadDefaultUnit(), MeasurementUnit.imperial);
    });

    test('saves and loads profile and reminder settings', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = SettingsRepository(prefs);
      const profile = PersonalProfile(
        age: 29,
        sexAtBirth: SexAtBirth.female,
        activityLevel: ActivityLevel.moderate,
      );
      const reminderSettings = ReminderSettings(
        enabled: true,
        frequency: ReminderFrequency.weekly,
        hour: 9,
        minute: 30,
        dayValue: 2,
      );

      await repository.saveProfile(profile);
      await repository.saveReminderSettings(reminderSettings);

      expect(await repository.loadProfile(), profile);
      expect(await repository.loadReminderSettings(), reminderSettings);
    });
  });
}
