import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bmi_calculator/core/repositories/history_repository.dart';
import 'package:bmi_calculator/models/bmi_entry.dart';
import 'package:bmi_calculator/models/bmi_result.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';

void main() {
  test('appendEntry trims history to newest 500 entries', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = HistoryRepository(prefs);

    for (var index = 0; index < 501; index++) {
      await repository.appendEntry(
        BmiEntry(
          id: 'entry-$index',
          createdAt: DateTime(2026, 1, 1).add(Duration(days: index)),
          heightCm: 170,
          weightKg: 70.0 + index,
          unitUsed: MeasurementUnit.metric,
          bmiValue: 22.0 + index,
          category: BmiCategory.normal,
        ),
      );
    }

    final entries = await repository.loadEntries();

    expect(entries, hasLength(500));
    expect(entries.first.id, 'entry-1');
    expect(entries.last.id, 'entry-500');
  });

  test('deleteEntry and clearEntries update stored history', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = HistoryRepository(prefs);
    final firstEntry = BmiEntry(
      id: 'first',
      createdAt: DateTime(2026, 1, 1),
      heightCm: 170,
      weightKg: 70,
      unitUsed: MeasurementUnit.metric,
      bmiValue: 22,
      category: BmiCategory.normal,
    );
    final secondEntry = BmiEntry(
      id: 'second',
      createdAt: DateTime(2026, 1, 2),
      heightCm: 172,
      weightKg: 72,
      unitUsed: MeasurementUnit.metric,
      bmiValue: 24,
      category: BmiCategory.overweight,
    );

    await repository.saveEntries([firstEntry, secondEntry]);
    await repository.deleteEntry('first');

    expect(await repository.loadEntries(), [secondEntry]);

    await repository.clearEntries();

    expect(await repository.loadEntries(), isEmpty);
  });
}
