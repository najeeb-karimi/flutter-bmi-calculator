import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bmi_calculator/core/repositories/history_repository.dart';
import 'package:bmi_calculator/core/repositories/settings_repository.dart';
import 'package:bmi_calculator/core/theme/app_theme.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/models/personal_profile.dart';
import 'package:bmi_calculator/models/user_goal.dart';
import 'package:bmi_calculator/ui/screens/bmi_home_screen.dart';
import 'package:bmi_calculator/ui/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  runApp(
    BmiCalculatorApp(
      settingsRepository: SettingsRepository(prefs),
      historyRepository: HistoryRepository(prefs),
    ),
  );
}

class BmiCalculatorApp extends StatefulWidget {
  const BmiCalculatorApp({
    super.key,
    required this.settingsRepository,
    required this.historyRepository,
  });

  final SettingsRepository settingsRepository;
  final HistoryRepository historyRepository;

  @override
  State<BmiCalculatorApp> createState() => _BmiCalculatorAppState();
}

class _BmiCalculatorAppState extends State<BmiCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.system;
  MeasurementUnit _defaultUnit = MeasurementUnit.metric;
  UserGoal _activeGoal = const UserGoal(type: GoalType.bmi, value: 22);
  PersonalProfile? _personalProfile;

  @override
  void initState() {
    super.initState();
    _loadPersistedSettings();
  }

  Future<void> _loadPersistedSettings() async {
    await widget.settingsRepository.migrateLegacySettingsIfNeeded();

    final persistedTheme = await widget.settingsRepository.loadThemeMode();
    final persistedUnit = await widget.settingsRepository.loadDefaultUnit();
    final persistedGoal = await widget.settingsRepository.loadGoal();
    final persistedProfile = await widget.settingsRepository.loadProfile();

    if (!mounted) return;
    setState(() {
      _themeMode = persistedTheme ?? ThemeMode.system;
      _defaultUnit = persistedUnit ?? MeasurementUnit.metric;
      _activeGoal =
          persistedGoal ?? const UserGoal(type: GoalType.bmi, value: 22);
      _personalProfile = _normalizeProfile(persistedProfile);
    });
  }

  void _onThemeModeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    widget.settingsRepository.saveThemeMode(mode);
  }

  void _onDefaultUnitChanged(MeasurementUnit unit) {
    setState(() {
      _defaultUnit = unit;
    });
    widget.settingsRepository.saveDefaultUnit(unit);
  }

  void _onGoalChanged(UserGoal goal) {
    setState(() {
      _activeGoal = goal;
    });
    widget.settingsRepository.saveGoal(goal);
  }

  void _onProfileChanged(PersonalProfile? profile) {
    final normalizedProfile = _normalizeProfile(profile);
    setState(() {
      _personalProfile = normalizedProfile;
    });
    if (normalizedProfile == null) {
      widget.settingsRepository.clearProfile();
      return;
    }
    widget.settingsRepository.saveProfile(normalizedProfile);
  }

  @override
  Widget build(BuildContext context) {
    final homeScreen = BmiHomeScreen(
      defaultUnit: _defaultUnit,
      activeGoal: _activeGoal,
      personalProfile: _personalProfile,
      currentThemeMode: _themeMode,
      onDefaultUnitChanged: _onDefaultUnitChanged,
      onThemeModeChanged: _onThemeModeChanged,
      onGoalChanged: _onGoalChanged,
      onProfileChanged: _onProfileChanged,
      onSaveResult: widget.historyRepository.appendEntry,
      onLoadHistory: widget.historyRepository.loadEntries,
      onDeleteHistoryEntry: widget.historyRepository.deleteEntry,
      onClearHistory: widget.historyRepository.clearEntries,
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

  PersonalProfile? _normalizeProfile(PersonalProfile? profile) {
    if (profile == null) return null;
    final isEmpty = profile.age == null &&
        profile.sexAtBirth == null &&
        profile.activityLevel == null;
    return isEmpty ? null : profile;
  }
}
