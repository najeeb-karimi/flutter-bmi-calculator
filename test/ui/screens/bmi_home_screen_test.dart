import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bmi_calculator/models/bmi_entry.dart';
import 'package:bmi_calculator/models/bmi_result.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/models/user_goal.dart';
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
        activeGoal: const UserGoal(type: GoalType.bmi, value: 22),
        personalProfile: null,
        currentThemeMode: ThemeMode.system,
        onDefaultUnitChanged: (_) {},
        onThemeModeChanged: (_) {},
        onGoalChanged: (_) {},
        onProfileChanged: (_) {},
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
    expect(find.text('Insights'), findsOneWidget);
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

  testWidgets('healthy range and goal progress appear after calculation',
      (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    final calculateButton = find.text('Calculate BMI');
    await tester.ensureVisible(calculateButton);
    await tester.tap(calculateButton);
    await tester.pumpAndSettle();

    expect(find.text('Healthy Weight Range'), findsOneWidget);
    expect(find.text('Goal Progress'), findsOneWidget);
    expect(
      find.textContaining('Derived target weight:'),
      findsOneWidget,
    );
    expect(
      find.textContaining('kg'),
      findsOneWidget,
    );
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
