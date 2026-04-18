import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/models/personal_profile.dart';
import 'package:bmi_calculator/models/reminder_settings.dart';
import 'package:bmi_calculator/models/user_goal.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  static const String _themeModeKey = 'theme_mode';
  static const String _defaultUnitKey = 'default_unit';
  static const String _targetBmiKey = 'target_bmi';
  static const String _activeGoalKey = 'active_goal_json';
  static const String _personalProfileKey = 'personal_profile_json';
  static const String _reminderSettingsKey = 'reminder_settings_json';
  static const double _defaultTargetBmi = 22;

  final SharedPreferences _prefs;

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
  }

  Future<ThemeMode?> loadThemeMode() async {
    return _themeModeFromName(_prefs.getString(_themeModeKey));
  }

  Future<void> saveDefaultUnit(MeasurementUnit unit) async {
    await _prefs.setString(_defaultUnitKey, unit.name);
  }

  Future<MeasurementUnit?> loadDefaultUnit() async {
    return _measurementUnitFromName(_prefs.getString(_defaultUnitKey));
  }

  Future<void> saveGoal(UserGoal goal) async {
    await _prefs.setString(_activeGoalKey, jsonEncode(goal.toMap()));
  }

  Future<UserGoal?> loadGoal() async {
    final raw = _prefs.getString(_activeGoalKey);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return UserGoal.fromMap(Map<String, dynamic>.from(decoded));
  }

  Future<void> saveProfile(PersonalProfile profile) async {
    await _prefs.setString(_personalProfileKey, jsonEncode(profile.toMap()));
  }

  Future<PersonalProfile?> loadProfile() async {
    final raw = _prefs.getString(_personalProfileKey);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return PersonalProfile.fromMap(Map<String, dynamic>.from(decoded));
  }

  Future<void> clearProfile() async {
    await _prefs.remove(_personalProfileKey);
  }

  Future<void> saveReminderSettings(ReminderSettings settings) async {
    await _prefs.setString(
      _reminderSettingsKey,
      jsonEncode(settings.toMap()),
    );
  }

  Future<ReminderSettings?> loadReminderSettings() async {
    final raw = _prefs.getString(_reminderSettingsKey);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return ReminderSettings.fromMap(Map<String, dynamic>.from(decoded));
  }

  Future<void> migrateLegacySettingsIfNeeded() async {
    if (_prefs.containsKey(_activeGoalKey)) return;

    final legacyTargetBmi = _prefs.getDouble(_targetBmiKey) ?? _defaultTargetBmi;
    await saveGoal(
      UserGoal(
        type: GoalType.bmi,
        value: legacyTargetBmi,
      ),
    );
  }
}

ThemeMode? _themeModeFromName(String? raw) {
  for (final mode in ThemeMode.values) {
    if (mode.name == raw) return mode;
  }
  return null;
}

MeasurementUnit? _measurementUnitFromName(String? raw) {
  for (final unit in MeasurementUnit.values) {
    if (unit.name == raw) return unit;
  }
  return null;
}
