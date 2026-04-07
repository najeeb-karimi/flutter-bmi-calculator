/// Supported unit systems for user input and display.
enum MeasurementUnit {
  metric,
  imperial,
}

extension MeasurementUnitLabel on MeasurementUnit {
  String get label {
    switch (this) {
      case MeasurementUnit.metric:
        return 'Metric';
      case MeasurementUnit.imperial:
        return 'Imperial';
    }
  }
}

