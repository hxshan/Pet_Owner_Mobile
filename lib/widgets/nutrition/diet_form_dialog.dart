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

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diseaseItems = <String>['None', ...diseases.where((e) => e != 'None')];
    final allergyItems = <String>['None', ...allergies.where((e) => e != 'None')];

    if (!diseaseItems.contains(_disease)) _disease = 'None';
    if (!allergyItems.contains(_allergy)) _allergy = 'None';

    Widget bulletRow(String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("•  ", style: TextStyle(fontSize: 13, height: 1.35)),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AlertDialog(
      title: const Text("Generate Meal Plan"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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

              // ✅ Point guide under Activity Level
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Activity Level Guide",
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    bulletRow("Indoor-only cat or senior dog → Low"),
                    bulletRow("Regular daily walks or garden play → Medium"),
                    bulletRow("Working dog or highly energetic breed with long exercise → High"),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _disease,
                decoration: const InputDecoration(labelText: "Disease"),
                items: diseaseItems
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _disease = v ?? 'None'),
              ),

              DropdownButtonFormField<String>(
                value: _allergy,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Food Restrictions",
                  helperText: "Select foods to avoid due to allergies or health conditions",
                ),
                items: allergyItems
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

                    if (mounted) Navigator.pop(context);
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