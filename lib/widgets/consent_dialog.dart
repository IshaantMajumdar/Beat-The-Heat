import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class ConsentDialog extends StatefulWidget {
  final UserProfile? initial;
  const ConsentDialog({super.key, this.initial});

  @override
  State<ConsentDialog> createState() => _ConsentDialogState();
}

class _ConsentDialogState extends State<ConsentDialog> {
  final _formKey = GlobalKey<FormState>();
  int age = 30;
  Gender gender = Gender.other;
  bool cardio = false;
  bool respiratory = false;
  bool diabetes = false;
  bool hypertension = false;
  ActivityLevel activityLevel = ActivityLevel.moderate;
  bool consent = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      age = widget.initial!.age;
      gender = widget.initial!.gender;
      cardio = widget.initial!.hasCardio;
      respiratory = widget.initial!.hasRespiratory;
      diabetes = widget.initial!.hasDiabetes;
      hypertension = widget.initial!.hasHypertension;
      activityLevel = widget.initial!.activityLevel;
      consent = widget.initial!.consented;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Personalize and consent'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('We process personal info locally to provide better risk estimates. Do you consent?'),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Age:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: age.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        errorStyle: TextStyle(height: 0),
                        suffixText: 'years',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final parsedAge = int.tryParse(value);
                        if (parsedAge == null) {
                          return 'Invalid number';
                        }
                        if (parsedAge < 0 || parsedAge > 120) {
                          return 'Invalid age';
                        }
                        return null;
                      },
                      onChanged: (s) {
                        final newAge = int.tryParse(s);
                        if (newAge != null && newAge >= 0 && newAge <= 120) {
                          setState(() => age = newAge);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Gender:'),
              SegmentedButton<Gender>(
                segments: const [
                  ButtonSegment(value: Gender.male, label: Text('Male')),
                  ButtonSegment(value: Gender.female, label: Text('Female')),
                  ButtonSegment(value: Gender.other, label: Text('Other')),
                ],
                selected: {gender},
                onSelectionChanged: (Set<Gender> selected) {
                  setState(() {
                    gender = selected.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Medical Conditions:'),
              CheckboxListTile(
                value: cardio,
                onChanged: (v) => setState(() => cardio = v ?? false),
                title: const Text('Heart / cardiovascular condition'),
              ),
              CheckboxListTile(
                value: respiratory,
                onChanged: (v) => setState(() => respiratory = v ?? false),
                title: const Text('Respiratory condition'),
              ),
              CheckboxListTile(
                value: diabetes,
                onChanged: (v) => setState(() => diabetes = v ?? false),
                title: const Text('Diabetes'),
              ),
              CheckboxListTile(
                value: hypertension,
                onChanged: (v) => setState(() => hypertension = v ?? false),
                title: const Text('Hypertension'),
              ),
              const SizedBox(height: 16),
              const Text('Activity Level:'),
              const Text(
                'Select your typical daily activity level',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<ActivityLevel>(
                value: activityLevel,
                isExpanded: true,
                items: ActivityLevel.values.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level.toString().split('.').last
                        .split(RegExp(r'(?=[A-Z])'))
                        .map((s) => s.toLowerCase())
                        .map((s) => s[0].toUpperCase() + s.substring(1))
                        .join(' ')),
                  );
                }).toList(),
                onChanged: (ActivityLevel? value) {
                  if (value != null) {
                    setState(() {
                      activityLevel = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: consent,
                onChanged: (v) => setState(() => consent = v),
                title: const Text('I consent to local processing of my data'),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: !consent 
              ? null 
              : () {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please check the form for errors'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  final profile = UserProfile(
                    age: age,
                    gender: gender,
                    hasCardio: cardio,
                    hasRespiratory: respiratory,
                    hasDiabetes: diabetes,
                    hasHypertension: hypertension,
                    activityLevel: activityLevel,
                    consented: consent,
                  );
                  Navigator.of(context).pop(profile);
                },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
