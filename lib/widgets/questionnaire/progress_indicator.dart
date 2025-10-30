import 'package:flutter/material.dart';

class QuestionnaireProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const QuestionnaireProgress({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: currentStep / totalSteps,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Step $currentStep of $totalSteps',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}