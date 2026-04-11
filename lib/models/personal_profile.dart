enum SexAtBirth {
  female,
  male,
  other,
  preferNotToSay,
}

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive,
}

class PersonalProfile {
  const PersonalProfile({
    this.age,
    this.sexAtBirth,
    this.activityLevel,
  });

  final int? age;
  final SexAtBirth? sexAtBirth;
  final ActivityLevel? activityLevel;

  Map<String, dynamic> toMap() {
    return {
      if (age != null) 'age': age,
      if (sexAtBirth != null) 'sexAtBirth': sexAtBirth!.name,
      if (activityLevel != null) 'activityLevel': activityLevel!.name,
    };
  }

  factory PersonalProfile.fromMap(Map<String, dynamic> map) {
    final rawAge = map['age'];
    return PersonalProfile(
      age: rawAge is num ? rawAge.toInt() : int.tryParse(rawAge?.toString() ?? ''),
      sexAtBirth: _sexAtBirthFromName(map['sexAtBirth'] as String?),
      activityLevel: _activityLevelFromName(map['activityLevel'] as String?),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PersonalProfile &&
        other.age == age &&
        other.sexAtBirth == sexAtBirth &&
        other.activityLevel == activityLevel;
  }

  @override
  int get hashCode => Object.hash(age, sexAtBirth, activityLevel);
}

SexAtBirth? _sexAtBirthFromName(String? raw) {
  for (final value in SexAtBirth.values) {
    if (value.name == raw) return value;
  }
  return null;
}

ActivityLevel? _activityLevelFromName(String? raw) {
  for (final value in ActivityLevel.values) {
    if (value.name == raw) return value;
  }
  return null;
}
