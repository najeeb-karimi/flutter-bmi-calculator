import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bmi_calculator/models/bmi_entry.dart';
import 'package:bmi_calculator/models/bmi_result.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/ui/screens/bmi_home_screen.dart';

void main() {
  Widget buildTestApp({
    MeasurementUnit defaultUnit = MeasurementUnit.metric,
    Future<void> Function(BmiEntry entry)? onSaveResult,
    Future<List<BmiEntry>> Function()? onLoadHistory,
    Future<void> Function(String id)? onDeleteHistoryEntry,
    Future<void> Function()? onClearHistory,
  }) {
    return MaterialApp(
      home: BmiHomeScreen(
        defaultUnit: defaultUnit,
        initialTargetBmi: 22,
        currentThemeMode: ThemeMode.system,
        onDefaultUnitChanged: (_) {},
        onThemeModeChanged: (_) {},
        onTargetBmiChanged: (_) {},
        onSaveResult: onSaveResult ?? (_) async {},
        onLoadHistory: onLoadHistory ?? () async => const [],
        onDeleteHistoryEntry: onDeleteHistoryEntry ?? (_) async {},
        onClearHistory: onClearHistory ?? () async {},
      ),
    );
  }

  testWidgets('shows result after tapping Calculate BMI', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(
      find.text('Enter your height and weight, then tap Calculate.'),
      findsOneWidget,
    );

    final calculateButton = find.text('Calculate BMI');
    await tester.ensureVisible(calculateButton);
    await tester.tap(calculateButton);
    await tester.pumpAndSettle();

    expect(find.text('BMI'), findsOneWidget);
    expect(find.text('NORMAL'), findsOneWidget);
  });

  testWidgets('save and share actions appear only after calculation',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsNothing);
    expect(find.text('Share'), findsNothing);

    final calculateButton = find.text('Calculate BMI');
    await tester.ensureVisible(calculateButton);
    await tester.tap(calculateButton);
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });

  testWidgets('unit switch updates labels from metric to imperial',
      (tester) async {
    await tester.pumpWidget(buildTestApp(defaultUnit: MeasurementUnit.metric));
    await tester.pumpAndSettle();

    expect(_heightValueWithUnit('cm'), findsOneWidget);
    expect(_weightValueWithUnit('kg'), findsOneWidget);

    await tester.tap(find.text('Imperial'));
    await tester.pumpAndSettle();

    expect(_heightValueWithUnit('in'), findsOneWidget);
    expect(_weightValueWithUnit('lb'), findsOneWidget);
  });

  testWidgets('save result persists a history entry', (tester) async {
    final savedEntries = <BmiEntry>[];

    await tester.pumpWidget(
      buildTestApp(
        onSaveResult: (entry) async {
          savedEntries.add(entry);
        },
      ),
    );
    await tester.pumpAndSettle();

    final calculateButton = find.text('Calculate BMI');
    await tester.ensureVisible(calculateButton);
    await tester.tap(calculateButton);
    await tester.pumpAndSettle();

    final saveButton = find.text('Save');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(savedEntries, hasLength(1));
    expect(savedEntries.single.category, BmiCategory.normal);
    expect(savedEntries.single.heightCm, 170);
    expect(savedEntries.single.weightKg, 70);
  });

  testWidgets('inline text input updates height label when value is valid',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '180');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.textContaining('Height: 180.0 cm'), findsOneWidget);
  });

  testWidgets('invalid target BMI keeps previous value and shows error',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(2), '40');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.textContaining('Enter a value between 18.0 and 28.0'),
        findsOneWidget);
    expect(find.textContaining('Target BMI: 22.0'), findsOneWidget);
  });
}

Finder _heightValueWithUnit(String unit) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data != null &&
        widget.data!.startsWith('Height:') &&
        widget.data!.contains(' $unit'),
  );
}

Finder _weightValueWithUnit(String unit) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data != null &&
        widget.data!.startsWith('Weight:') &&
        widget.data!.contains(' $unit'),
  );
}
