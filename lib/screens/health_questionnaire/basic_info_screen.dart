import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../widgets/questionnaire/question_card.dart';
import '../../widgets/questionnaire/progress_indicator.dart';

class BasicInfoScreen extends StatefulWidget {
  final Function(int age, Gender gender) onNext;

  const BasicInfoScreen({
    Key? key,
    required this.onNext,
  }) : super(key: key);

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  int age = 30;
  Gender gender = Gender.other;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Information'),
      ),
      body: Column(
        children: [
          const QuestionnaireProgress(currentStep: 1, totalSteps: 4),
          Expanded(
            child: ListView(
              children: [
                QuestionCard(
                  question: 'What is your age?',
                  helperText: 'Age is a key factor in heat risk assessment',
                  input: TextFormField(
                    initialValue: age.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      suffix: Text('years'),
                    ),
                    onChanged: (value) {
                      setState(() {
                        age = int.tryParse(value) ?? age;
                      });
                    },
                  ),
                ),
                QuestionCard(
                  question: 'What is your gender?',
                  helperText: 'This helps us provide more accurate risk assessment',
                  input: SegmentedButton<Gender>(
                    segments: const [
                      ButtonSegment(
                        value: Gender.male,
                        label: Text('Male'),
                      ),
                      ButtonSegment(
                        value: Gender.female,
                        label: Text('Female'),
                      ),
                      ButtonSegment(
                        value: Gender.other,
                        label: Text('Other'),
                      ),
                    ],
                    selected: {gender},
                    onSelectionChanged: (Set<Gender> selected) {
                      setState(() {
                        gender = selected.first;
                      });
                    },
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Theme.of(context).colorScheme.primaryContainer;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => widget.onNext(age, gender),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}