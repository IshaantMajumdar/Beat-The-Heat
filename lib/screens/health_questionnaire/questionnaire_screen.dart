import 'package:flutter/material.dart';
import '../../models/health_data.dart';
import '../../models/user_profile.dart';
import './medical_history_screen.dart';
import './basic_info_screen.dart';
import './activity_level_screen.dart';
import './medication_screen.dart';

class HealthQuestionnaireScreen extends StatefulWidget {
  final UserProfile? initialProfile;

  const HealthQuestionnaireScreen({
    super.key,
    this.initialProfile,
  });

  @override
  State<HealthQuestionnaireScreen> createState() => _HealthQuestionnaireScreenState();
}

class _HealthQuestionnaireScreenState extends State<HealthQuestionnaireScreen> {
  late HealthData _healthData;
  late int _age;
  late Gender _gender;
  late bool _hasCardio;
  late bool _hasRespiratory;
  late bool _hasDiabetes;
  late bool _hasHypertension;
  late ActivityLevel _activityLevel;
  late bool _consent;

  @override
  void initState() {
    super.initState();
    _healthData = widget.initialProfile?.healthData ?? const HealthData();
    _age = widget.initialProfile?.age ?? 30;
    _gender = widget.initialProfile?.gender ?? Gender.other;
    _hasCardio = widget.initialProfile?.hasCardio ?? false;
    _hasRespiratory = widget.initialProfile?.hasRespiratory ?? false;
    _hasDiabetes = widget.initialProfile?.hasDiabetes ?? false;
    _hasHypertension = widget.initialProfile?.hasHypertension ?? false;
    _activityLevel = widget.initialProfile?.activityLevel ?? ActivityLevel.moderate;
    _consent = widget.initialProfile?.consented ?? false;
  }

  void _handleBasicInfoNext(int age, Gender gender) {
    setState(() {
      _age = age;
      _gender = gender;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalHistoryScreen(
          onNext: _handleMedicalHistoryNext,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _handleMedicalHistoryNext(
    bool hasCardio,
    bool hasRespiratory,
    bool hasDiabetes,
    bool hasHypertension,
  ) {
    setState(() {
      _hasCardio = hasCardio;
      _hasRespiratory = hasRespiratory;
      _hasDiabetes = hasDiabetes;
      _hasHypertension = hasHypertension;
    });

    // Push to the medication screen first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationScreen(
          medications: _healthData.medications,
          onUpdate: (medications) {
            setState(() {
              _healthData = _healthData.copyWith(medications: medications);
            });
          },
          onNext: _handleMedicationNext,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _handleMedicationNext() {
    // Replace current screen with activity level screen instead of pushing
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityLevelScreen(
          onComplete: _handleActivityLevelComplete,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _handleActivityLevelComplete(ActivityLevel activityLevel) {
    print('Activity level complete called with: ${activityLevel.name}');
    
    setState(() {
      _activityLevel = activityLevel;
      _consent = true; // User has completed the questionnaire
    });

    print('Creating profile with:');
    print('Age: $_age');
    print('Gender: $_gender');
    print('Medical conditions: Cardio: $_hasCardio, Respiratory: $_hasRespiratory');
    print('Activity Level: $_activityLevel');

    final profile = UserProfile(
      age: _age,
      gender: _gender,
      hasCardio: _hasCardio,
      hasRespiratory: _hasRespiratory,
      hasDiabetes: _hasDiabetes,
      hasHypertension: _hasHypertension,
      activityLevel: _activityLevel,
      consented: _consent,
      healthData: _healthData,
    );

    print('Completing questionnaire with profile: $profile');
    
    // Pop the questionnaire screen with the profile result
    // This will return to the main screen since we used pushReplacement for navigation
    Navigator.of(context).pop(profile);
  }

  @override
  Widget build(BuildContext context) {
    return BasicInfoScreen(
      onNext: _handleBasicInfoNext,
    );
  }
}