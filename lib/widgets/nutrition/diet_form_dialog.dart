import 'package:flutter/material.dart';
import '../../consts/diet_form_options.dart';

class DietFormDialog extends StatefulWidget {
  final String petId;
  final String species;
  final String breed;
  final String gender;
  final Future<void> Function({
    required double ageMonths,
    required double weightKg,
    required String activityLevel,
    required String disease,
    required String allergy,
  }) onGenerate;

  const DietFormDialog({
    super.key,
    required this.petId,
    required this.species,
    required this.breed,
    required this.gender,
    required this.onGenerate,
  });

  @override
  State<DietFormDialog> createState() => _DietFormDialogState();
}

class _DietFormDialogState extends State<DietFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String _activity = 'Medium';
  String _disease = 'None';
  String _allergy = 'None';
  bool _loading = false;

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Generate Meal Plan"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // locked values from pet profile
              TextFormField(
                initialValue: widget.species,
                enabled: false,
                decoration: const InputDecoration(labelText: "Species"),
              ),
              TextFormField(
                initialValue: widget.breed,
                enabled: false,
                decoration: const InputDecoration(labelText: "Breed"),
              ),
              TextFormField(
                initialValue: widget.gender,
                enabled: false,
                decoration: const InputDecoration(labelText: "Gender"),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age (Months)"),
                validator: (v) {
                  final x = double.tryParse((v ?? '').trim());
                  if (x == null || x <= 0) return "Enter valid age in months";
                  return null;
                },
              ),
              TextFormField(
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Weight (Kg)"),
                validator: (v) {
                  final x = double.tryParse((v ?? '').trim());
                  if (x == null || x <= 0) return "Enter valid weight";
                  return null;
                },
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _activity,
                decoration: const InputDecoration(labelText: "Activity Level"),
                items: activityLevels
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _activity = v ?? 'Medium'),
              ),

              DropdownButtonFormField<String>(
                value: _disease,
                decoration: const InputDecoration(labelText: "Disease"),
                items: diseases
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _disease = v ?? 'None'),
              ),

              DropdownButtonFormField<String>(
                value: _allergy,
                decoration: const InputDecoration(labelText: "Allergy"),
                items: allergies
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _allergy = v ?? 'None'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;

                  setState(() => _loading = true);

                  try {
                    await widget.onGenerate(
                      ageMonths: double.parse(_ageCtrl.text.trim()),
                      weightKg: double.parse(_weightCtrl.text.trim()),
                      activityLevel: _activity,
                      disease: _disease,
                      allergy: _allergy,
                    );
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                },
          child: _loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Generate"),
        ),
      ],
    );
  }
}
