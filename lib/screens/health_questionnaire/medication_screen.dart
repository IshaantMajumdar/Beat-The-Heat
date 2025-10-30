import 'package:flutter/material.dart';
import '../../models/health_data.dart';
import '../../widgets/questionnaire/question_card.dart';
import '../../widgets/questionnaire/progress_indicator.dart';

class MedicationScreen extends StatefulWidget {
  final List<Medication> medications;
  final Function(List<Medication>) onUpdate;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const MedicationScreen({
    super.key,
    required this.medications,
    required this.onUpdate,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  late List<Medication> _medications;

  @override
  void initState() {
    super.initState();
    _medications = List.from(widget.medications);
  }

  void _addMedication() {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        onSave: (medication) {
          setState(() {
            _medications.add(medication);
          });
          widget.onUpdate(_medications);
        },
      ),
    );
  }

  void _editMedication(int index) {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        initialMedication: _medications[index],
        onSave: (medication) {
          setState(() {
            _medications[index] = medication;
          });
          widget.onUpdate(_medications);
        },
      ),
    );
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
    widget.onUpdate(_medications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        leading: BackButton(onPressed: widget.onBack),
      ),
      body: Column(
        children: [
          const QuestionnaireProgress(currentStep: 3, totalSteps: 4),
          Expanded(
            child: ListView(
              children: [
                QuestionCard(
                  question: 'Do you take any medications?',
                  helperText: 'List any medications that might affect your heat sensitivity',
                  input: Column(
                    children: [
                      ..._medications.asMap().entries.map((entry) {
                        final index = entry.key;
                        final med = entry.value;
                        return ListTile(
                          title: Text(med.name),
                          subtitle: med.notes != null ? Text(med.notes!) : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (med.affectsHeatSensitivity)
                                const Chip(
                                  label: Text('Heat Sensitive'),
                                  backgroundColor: Colors.amber,
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editMedication(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeMedication(index),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _addMedication,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Medication'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              onPressed: widget.onNext,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationDialog extends StatefulWidget {
  final Medication? initialMedication;
  final Function(Medication) onSave;

  const _MedicationDialog({
    this.initialMedication,
    required this.onSave,
  });

  @override
  State<_MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<_MedicationDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late bool _affectsHeatSensitivity;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialMedication?.name ?? '',
    );
    _notesController = TextEditingController(
      text: widget.initialMedication?.notes ?? '',
    );
    _affectsHeatSensitivity = widget.initialMedication?.affectsHeatSensitivity ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialMedication == null ? 'Add Medication' : 'Edit Medication'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Medication Name',
                hintText: 'Enter medication name',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any relevant notes',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Affects heat sensitivity'),
              subtitle: const Text('Check if this medication affects your response to heat'),
              value: _affectsHeatSensitivity,
              onChanged: (value) => setState(() => _affectsHeatSensitivity = value ?? false),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) return;
            widget.onSave(
              Medication(
                name: _nameController.text.trim(),
                notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                affectsHeatSensitivity: _affectsHeatSensitivity,
              ),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}