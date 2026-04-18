enum GoalType {
  bmi,
  weight,
}

extension GoalTypeLabel on GoalType {
  String get label {
    switch (this) {
      case GoalType.bmi:
        return 'BMI';
      case GoalType.weight:
        return 'Weight';
    }
  }
}

class UserGoal {
  const UserGoal({
    required this.type,
    required this.value,
  });

  final GoalType type;
  final double value;

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'value': value,
    };
  }

  factory UserGoal.fromMap(Map<String, dynamic> map) {
    final rawValue = map['value'];
    return UserGoal(
      type: _goalTypeFromName(map['type'] as String?),
      value: _doubleFromRaw(rawValue),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserGoal && other.type == type && other.value == value;
  }

  @override
  int get hashCode => Object.hash(type, value);
}

GoalType _goalTypeFromName(String? raw) {
  for (final type in GoalType.values) {
    if (type.name == raw) return type;
  }
  return GoalType.bmi;
}

double _doubleFromRaw(Object? raw) {
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw?.toString() ?? '') ?? 0;
}
