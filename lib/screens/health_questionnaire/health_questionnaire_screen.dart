import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../widgets/questionnaire/progress_indicator.dart';
import 'basic_info_screen.dart';
import 'medical_history_screen.dart';
import 'activity_level_screen.dart';

class HealthQuestionnaireScreen extends StatefulWidget {
  final UserProfile? initialProfile;

  const HealthQuestionnaireScreen({super.key, this.initialProfile});

  @override
  State<HealthQuestionnaireScreen> createState() => _HealthQuestionnaireScreenState();
}

class _HealthQuestionnaireScreenState extends State<HealthQuestionnaireScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int? _age;
  Gender? _gender;
  bool? _hasCardio;
  bool? _hasRespiratory;
  bool? _hasDiabetes;
  bool? _hasHypertension;
  ActivityLevel? _activityLevel;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialProfile != null) {
      _age = widget.initialProfile!.age;
      _gender = widget.initialProfile!.gender;
      _hasCardio = widget.initialProfile!.hasCardio;
      _hasRespiratory = widget.initialProfile!.hasRespiratory;
      _hasDiabetes = widget.initialProfile!.hasDiabetes;
      _hasHypertension = widget.initialProfile!.hasHypertension;
      _activityLevel = widget.initialProfile!.activityLevel;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _nextPage() async {
    if (_currentPage < 2) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (mounted) {
        if (_age != null &&
            _gender != null &&
            _hasCardio != null &&
            _hasRespiratory != null &&
            _hasDiabetes != null &&
            _hasHypertension != null &&
            _activityLevel != null) {
          final profile = UserProfile(
            age: _age!,
            gender: _gender!,
            hasCardio: _hasCardio!,
            hasRespiratory: _hasRespiratory!,
            hasDiabetes: _hasDiabetes!,
            hasHypertension: _hasHypertension!,
            activityLevel: _activityLevel!,
            consented: true,
          );
          Navigator.of(context).pop(profile);
        }
      }
    }
  }

  Future<void> _previousPage() async {
    if (_currentPage > 0) {
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (mounted) {
        Navigator.of(context).pop(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Questionnaire'),
        leading: _currentPage == 0
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(null),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              ),
      ),
      body: Column(
        children: [
          QuestionnaireProgress(
            currentStep: _currentPage + 1,
            totalSteps: 3,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                BasicInfoScreen(
                  onNext: (age, gender) {
                    // TODO: Update with new profile data when integrating
                    _nextPage();
                  },
                ),
                MedicalHistoryScreen(
                  onNext: (hasCardio, hasRespiratory, hasDiabetes, hasHypertension) {
                    // TODO: Update with new profile data when integrating
                    _nextPage();
                  },
                  onBack: _previousPage,
                ),
                ActivityLevelScreen(
                  onComplete: (activityLevel) {
                    setState(() => _activityLevel = activityLevel);
                    _nextPage();
                  },
                  onBack: _previousPage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}