import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../widgets/questionnaire/question_card.dart';
import '../../widgets/questionnaire/progress_indicator.dart';

class ActivityLevelScreen extends StatefulWidget {
  final Function(ActivityLevel activityLevel) onComplete;
  final Function() onBack;

  const ActivityLevelScreen({
    Key? key,
    required this.onComplete,
    required this.onBack,
  }) : super(key: key);

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  ActivityLevel activityLevel = ActivityLevel.moderate;

  String _getActivityDescription(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Little to no physical activity (e.g., desk job with minimal exercise)';
      case ActivityLevel.light:
        return 'Light physical activity (e.g., walking, light housework)';
      case ActivityLevel.moderate:
        return 'Moderate activity (e.g., regular exercise 3-5 times a week)';
      case ActivityLevel.active:
        return 'Active lifestyle (e.g., daily exercise or physical job)';
      case ActivityLevel.veryActive:
        return 'Very active (e.g., intense exercise or heavy physical labor)';
    }
  }

  void _handleComplete() {
    print('Activity Level Screen: Complete button pressed');
    print('Selected activity level: ${activityLevel.name}');
    
    // Only call the completion callback, let parent handle navigation
    widget.onComplete(activityLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Level'),
        leading: BackButton(onPressed: widget.onBack),
      ),
      body: Column(
        children: [
          const QuestionnaireProgress(currentStep: 4, totalSteps: 4),
          Expanded(
            child: ListView(
              children: [
                QuestionCard(
                  question: 'What is your typical activity level?',
                  helperText: 'This helps us assess your heat risk during physical activity',
                  input: Column(
                    children: ActivityLevel.values.map((level) {
                      return RadioListTile<ActivityLevel>(
                        title: Text(level.name.toUpperCase()),
                        subtitle: Text(_getActivityDescription(level)),
                        value: level,
                        groupValue: activityLevel,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => activityLevel = value);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _handleComplete,
              child: const Text('Complete'),
            ),
          ),
        ],
      ),
    );
  }
}