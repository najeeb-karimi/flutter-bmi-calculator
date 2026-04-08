import 'package:flutter_test/flutter_test.dart';

import 'package:bmi_calculator/main.dart';

void main() {
  testWidgets('app renders BMI calculator title', (WidgetTester tester) async {
    await tester.pumpWidget(const BmiCalculatorApp());

    expect(find.text('BMI Calculator'), findsOneWidget);
    expect(find.text('Calculate BMI'), findsOneWidget);
  });
}
