import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bmi_calculator/models/bmi_entry.dart';
import 'package:bmi_calculator/models/bmi_result.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/ui/screens/history_screen.dart';

void main() {
  testWidgets('shows empty state when there are no saved entries',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HistoryScreen(
          loadEntries: () async => const [],
          onDeleteEntry: (_) async {},
          onClearHistory: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No saved BMI results yet.'), findsOneWidget);
  });

  testWidgets('renders entries newest first and deletes on swipe',
      (tester) async {
    final deletedIds = <String>[];
    final entries = [
      BmiEntry(
        id: 'older',
        createdAt: DateTime(2026, 4, 10, 9),
        heightCm: 170,
        weightKg: 70,
        unitUsed: MeasurementUnit.metric,
        bmiValue: 22,
        category: BmiCategory.normal,
      ),
      BmiEntry(
        id: 'newer',
        createdAt: DateTime(2026, 4, 11, 9),
        heightCm: 172,
        weightKg: 74,
        unitUsed: MeasurementUnit.metric,
        bmiValue: 25,
        category: BmiCategory.overweight,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: HistoryScreen(
          loadEntries: () async => entries,
          onDeleteEntry: (id) async {
            deletedIds.add(id);
          },
          onClearHistory: () async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('BMI 25.0'), findsOneWidget);

    await tester.drag(find.byType(Dismissible).first, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(deletedIds, ['newer']);
    expect(find.textContaining('BMI 25.0'), findsNothing);
  });
}
