import 'package:flutter/material.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerLowest,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Personalize your experience',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Choose your preferred units and appearance for a cleaner day-to-day experience.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsCard(
                      icon: Icons.straighten_rounded,
                      title: 'Default units',
                      subtitle: 'Choose app-wide preferred units',
                      child: DropdownButtonFormField<MeasurementUnit>(
                        value: defaultUnit,
                        decoration: const InputDecoration(
                          labelText: 'Measurement system',
                        ),
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
                    const SizedBox(height: 16),
                    _SettingsCard(
                      icon: Icons.palette_outlined,
                      title: 'Theme',
                      subtitle: 'Choose app appearance mode',
                      child: DropdownButtonFormField<ThemeMode>(
                        value: currentThemeMode,
                        decoration: const InputDecoration(
                          labelText: 'Appearance',
                        ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: colorScheme.secondary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}
