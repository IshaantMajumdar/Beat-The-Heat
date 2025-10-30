import 'health_data.dart';

enum Gender { male, female, other }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

class UserProfile {
  final int age;
  final Gender gender;
  final bool hasCardio;
  final bool hasRespiratory;
  final bool hasDiabetes;
  final bool hasHypertension;
  final ActivityLevel activityLevel;
  final bool consented;
  final HealthData healthData;

  UserProfile({
    required this.age,
    required this.gender,
    required this.hasCardio,
    required this.hasRespiratory,
    required this.hasDiabetes,
    required this.hasHypertension,
    required this.activityLevel,
    required this.consented,
    this.healthData = const HealthData(),
  });

  // Copy with method for creating a new instance with some updated values
  UserProfile copyWith({
    int? age,
    Gender? gender,
    bool? hasCardio,
    bool? hasRespiratory,
    bool? hasDiabetes,
    bool? hasHypertension,
    ActivityLevel? activityLevel,
    bool? consented,
    HealthData? healthData,
  }) {
    return UserProfile(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      hasCardio: hasCardio ?? this.hasCardio,
      hasRespiratory: hasRespiratory ?? this.hasRespiratory,
      hasDiabetes: hasDiabetes ?? this.hasDiabetes,
      hasHypertension: hasHypertension ?? this.hasHypertension,
      activityLevel: activityLevel ?? this.activityLevel,
      consented: consented ?? this.consented,
      healthData: healthData ?? this.healthData,
    );
  }
}
