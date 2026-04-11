enum ReminderFrequency {
  weekly,
  monthly,
}

class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    this.frequency,
    this.hour,
    this.minute,
    this.dayValue,
  });

  final bool enabled;
  final ReminderFrequency? frequency;
  final int? hour;
  final int? minute;
  final int? dayValue;

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      if (frequency != null) 'frequency': frequency!.name,
      if (hour != null) 'hour': hour,
      if (minute != null) 'minute': minute,
      if (dayValue != null) 'dayValue': dayValue,
    };
  }

  factory ReminderSettings.fromMap(Map<String, dynamic> map) {
    return ReminderSettings(
      enabled: map['enabled'] == true,
      frequency: _frequencyFromName(map['frequency'] as String?),
      hour: _intFromRaw(map['hour']),
      minute: _intFromRaw(map['minute']),
      dayValue: _intFromRaw(map['dayValue']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderSettings &&
        other.enabled == enabled &&
        other.frequency == frequency &&
        other.hour == hour &&
        other.minute == minute &&
        other.dayValue == dayValue;
  }

  @override
  int get hashCode => Object.hash(enabled, frequency, hour, minute, dayValue);
}

ReminderFrequency? _frequencyFromName(String? raw) {
  for (final value in ReminderFrequency.values) {
    if (value.name == raw) return value;
  }
  return null;
}

int? _intFromRaw(Object? raw) {
  if (raw is num) return raw.toInt();
  return int.tryParse(raw?.toString() ?? '');
}
