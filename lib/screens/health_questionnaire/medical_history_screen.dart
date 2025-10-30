import 'package:flutter/material.dart';
import '../../widgets/questionnaire/question_card.dart';
import '../../widgets/questionnaire/progress_indicator.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final Function(bool hasCardio, bool hasRespiratory, bool hasDiabetes, bool hasHypertension) onNext;
  final Function() onBack;

  const MedicalHistoryScreen({
    Key? key,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  bool hasCardio = false;
  bool hasRespiratory = false;
  bool hasDiabetes = false;
  bool hasHypertension = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History'),
        leading: BackButton(onPressed: widget.onBack),
      ),
      body: Column(
        children: [
          const QuestionnaireProgress(currentStep: 2, totalSteps: 4),
          Expanded(
            child: ListView(
              children: [
                QuestionCard(
                  question: 'Do you have any of the following conditions?',
                  helperText: 'Select all that apply',
                  input: Column(
                    children: [
                      CheckboxListTile(
                        title: const Text('Heart / Cardiovascular condition'),
                        value: hasCardio,
                        onChanged: (value) => setState(() => hasCardio = value ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Respiratory condition'),
                        value: hasRespiratory,
                        onChanged: (value) => setState(() => hasRespiratory = value ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Diabetes'),
                        value: hasDiabetes,
                        onChanged: (value) => setState(() => hasDiabetes = value ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Hypertension (High Blood Pressure)'),
                        value: hasHypertension,
                        onChanged: (value) => setState(() => hasHypertension = value ?? false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => widget.onNext(hasCardio, hasRespiratory, hasDiabetes, hasHypertension),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}