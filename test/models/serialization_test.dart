import 'package:flutter_test/flutter_test.dart';

import 'package:bmi_calculator/models/bmi_entry.dart';
import 'package:bmi_calculator/models/bmi_result.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/models/personal_profile.dart';
import 'package:bmi_calculator/models/reminder_settings.dart';
import 'package:bmi_calculator/models/user_goal.dart';

void main() {
  test('UserGoal serializes round-trip', () {
    const goal = UserGoal(type: GoalType.weight, value: 68.5);

    expect(UserGoal.fromMap(goal.toMap()), goal);
  });

  test('PersonalProfile serializes round-trip', () {
    const profile = PersonalProfile(
      age: 34,
      sexAtBirth: SexAtBirth.male,
      activityLevel: ActivityLevel.active,
    );

    expect(PersonalProfile.fromMap(profile.toMap()), profile);
  });

  test('ReminderSettings serializes round-trip', () {
    const settings = ReminderSettings(
      enabled: true,
      frequency: ReminderFrequency.monthly,
      hour: 8,
      minute: 15,
      dayValue: 12,
    );

    expect(ReminderSettings.fromMap(settings.toMap()), settings);
  });

  test('BmiEntry serializes round-trip with nested snapshots', () {
    final entry = BmiEntry(
      id: 'entry-1',
      createdAt: DateTime.utc(2026, 4, 11, 12, 30),
      heightCm: 175,
      weightKg: 72,
      unitUsed: MeasurementUnit.metric,
      bmiValue: 23.5,
      category: BmiCategory.normal,
      goalSnapshot: const UserGoal(type: GoalType.bmi, value: 22),
      profileSnapshot: const PersonalProfile(
        age: 28,
        sexAtBirth: SexAtBirth.preferNotToSay,
        activityLevel: ActivityLevel.light,
      ),
    );

    expect(BmiEntry.fromMap(entry.toMap()), entry);
  });
}
