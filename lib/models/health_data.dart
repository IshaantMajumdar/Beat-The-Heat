import 'package:flutter/foundation.dart';

enum HeatSensitivity {
  none,
  mild,
  moderate,
  severe
}

class Medication {
  final String name;
  final bool affectsHeatSensitivity;
  final String? notes;

  const Medication({
    required this.name,
    this.affectsHeatSensitivity = false,
    this.notes,
  });

  Medication copyWith({
    String? name,
    bool? affectsHeatSensitivity,
    String? notes,
  }) {
    return Medication(
      name: name ?? this.name,
      affectsHeatSensitivity: affectsHeatSensitivity ?? this.affectsHeatSensitivity,
      notes: notes ?? this.notes,
    );
  }
}

@immutable
class HealthData {
  final double? weight; // in kg
  final double? height; // in cm
  final HeatSensitivity heatSensitivity;
  final List<Medication> medications;
  final bool hasExperiencedHeatIssues;
  final String? heatIssuesDetails;

  const HealthData({
    this.weight,
    this.height,
    this.heatSensitivity = HeatSensitivity.none,
    this.medications = const [],
    this.hasExperiencedHeatIssues = false,
    this.heatIssuesDetails,
  });

  HealthData copyWith({
    double? weight,
    double? height,
    HeatSensitivity? heatSensitivity,
    List<Medication>? medications,
    bool? hasExperiencedHeatIssues,
    String? heatIssuesDetails,
  }) {
    return HealthData(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      heatSensitivity: heatSensitivity ?? this.heatSensitivity,
      medications: medications ?? this.medications,
      hasExperiencedHeatIssues: hasExperiencedHeatIssues ?? this.hasExperiencedHeatIssues,
      heatIssuesDetails: heatIssuesDetails ?? this.heatIssuesDetails,
    );
  }
}