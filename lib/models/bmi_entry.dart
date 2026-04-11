import 'package:bmi_calculator/models/bmi_result.dart';
import 'package:bmi_calculator/models/measurement_unit.dart';
import 'package:bmi_calculator/models/personal_profile.dart';
import 'package:bmi_calculator/models/user_goal.dart';

class BmiEntry {
  const BmiEntry({
    required this.id,
    required this.createdAt,
    required this.heightCm,
    required this.weightKg,
    required this.unitUsed,
    required this.bmiValue,
    required this.category,
    this.goalSnapshot,
    this.profileSnapshot,
  });

  final String id;
  final DateTime createdAt;
  final double heightCm;
  final double weightKg;
  final MeasurementUnit unitUsed;
  final double bmiValue;
  final BmiCategory category;
  final UserGoal? goalSnapshot;
  final PersonalProfile? profileSnapshot;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'heightCm': heightCm,
      'weightKg': weightKg,
      'unitUsed': unitUsed.name,
      'bmiValue': bmiValue,
      'category': category.name,
      if (goalSnapshot != null) 'goalSnapshot': goalSnapshot!.toMap(),
      if (profileSnapshot != null) 'profileSnapshot': profileSnapshot!.toMap(),
    };
  }

  factory BmiEntry.fromMap(Map<String, dynamic> map) {
    final rawGoalSnapshot = map['goalSnapshot'];
    final rawProfileSnapshot = map['profileSnapshot'];

    return BmiEntry(
      id: map['id'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      heightCm: _doubleFromRaw(map['heightCm']),
      weightKg: _doubleFromRaw(map['weightKg']),
      unitUsed: _measurementUnitFromName(map['unitUsed'] as String?),
      bmiValue: _doubleFromRaw(map['bmiValue']),
      category: _bmiCategoryFromName(map['category'] as String?),
      goalSnapshot: rawGoalSnapshot is Map
          ? UserGoal.fromMap(Map<String, dynamic>.from(rawGoalSnapshot))
          : null,
      profileSnapshot: rawProfileSnapshot is Map
          ? PersonalProfile.fromMap(
              Map<String, dynamic>.from(rawProfileSnapshot),
            )
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BmiEntry &&
        other.id == id &&
        other.createdAt == createdAt &&
        other.heightCm == heightCm &&
        other.weightKg == weightKg &&
        other.unitUsed == unitUsed &&
        other.bmiValue == bmiValue &&
        other.category == category &&
        other.goalSnapshot == goalSnapshot &&
        other.profileSnapshot == profileSnapshot;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      createdAt,
      heightCm,
      weightKg,
      unitUsed,
      bmiValue,
      category,
      goalSnapshot,
      profileSnapshot,
    );
  }
}

MeasurementUnit _measurementUnitFromName(String? raw) {
  for (final value in MeasurementUnit.values) {
    if (value.name == raw) return value;
  }
  return MeasurementUnit.metric;
}

BmiCategory _bmiCategoryFromName(String? raw) {
  for (final value in BmiCategory.values) {
    if (value.name == raw) return value;
  }
  return BmiCategory.normal;
}

double _doubleFromRaw(Object? raw) {
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw?.toString() ?? '') ?? 0;
}
