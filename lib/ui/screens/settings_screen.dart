import 'package:flutter/material.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';

/// Basic settings shell screen.
///
/// Phase 6.1 adds navigation and a settings scaffold only.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.defaultUnit,
    required this.currentThemeMode,
    required this.onDefaultUnitChanged,
    required this.onThemeModeChanged,
  });

  final MeasurementUnit defaultUnit;
  final ThemeMode currentThemeMode;
  final ValueChanged<MeasurementUnit> onDefaultUnitChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.straighten),
            title: const Text('Default units'),
            subtitle: const Text('Choose app-wide preferred units'),
            trailing: DropdownButton<MeasurementUnit>(
              value: defaultUnit,
              onChanged: (value) {
                if (value != null) onDefaultUnitChanged(value);
              },
              items: MeasurementUnit.values
                  .map(
                    (unit) => DropdownMenuItem<MeasurementUnit>(
                      value: unit,
                      child: Text(unit.label),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            subtitle: const Text('Choose app appearance mode'),
            trailing: DropdownButton<ThemeMode>(
              value: currentThemeMode,
              onChanged: (value) {
                if (value != null) onThemeModeChanged(value);
              },
              items: const [
                DropdownMenuItem<ThemeMode>(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem<ThemeMode>(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem<ThemeMode>(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
