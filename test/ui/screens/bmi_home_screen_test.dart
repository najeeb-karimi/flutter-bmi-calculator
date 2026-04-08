import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/ui/screens/bmi_home_screen.dart';

void main() {
  Widget buildTestApp({MeasurementUnit defaultUnit = MeasurementUnit.metric}) {
    return MaterialApp(
      home: BmiHomeScreen(
        defaultUnit: defaultUnit,
        initialTargetBmi: 22,
        currentThemeMode: ThemeMode.system,
        onDefaultUnitChanged: (_) {},
        onThemeModeChanged: (_) {},
        onTargetBmiChanged: (_) {},
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
