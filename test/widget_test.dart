import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bmi_calculator/core/repositories/history_repository.dart';
import 'package:bmi_calculator/core/repositories/settings_repository.dart';
import 'package:bmi_calculator/main.dart';

void main() {
  testWidgets('app keeps the existing splash-to-home launch flow',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      BmiCalculatorApp(
        settingsRepository: SettingsRepository(prefs),
        historyRepository: HistoryRepository(prefs),
      ),
    );

    expect(find.text('BMI Calculator'), findsOneWidget);
    expect(find.text('Calculate BMI'), findsNothing);

    await tester.pump(const Duration(milliseconds: 2800));
    await tester.pumpAndSettle();

    expect(find.text('BMI Calculator'), findsOneWidget);
    expect(find.text('Calculate BMI'), findsOneWidget);
  });
}
