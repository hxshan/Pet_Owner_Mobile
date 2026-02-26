import 'package:flutter/material.dart';
import '../../consts/diet_form_options.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

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

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 13.5),
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.darkPink, size: 20)
          : null,
      filled: true,
      fillColor: AppColors.lightGray,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkPink, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.errorMessage, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.errorMessage, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black45,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _bulletRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 13, color: AppColors.darkPink, height: 1.4)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diseaseItems = <String>['None', ...diseases.where((e) => e != 'None')];
    final allergyItems = <String>['None', ...allergies.where((e) => e != 'None')];

    if (!diseaseItems.contains(_disease)) _disease = 'None';
    if (!allergyItems.contains(_allergy)) _allergy = 'None';

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.mainColor.withOpacity(0.5),
                  AppColors.darkPink.withOpacity(0.35),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.restaurant_menu, color: AppColors.darkPink, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Meal Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Fill in your pet\'s details below',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Scrollable Form Body ─────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pet Info (read-only)
                    _sectionLabel('PET INFO'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: widget.species,
                            enabled: false,
                            style: const TextStyle(color: Colors.black54, fontSize: 14),
                            decoration: _inputDecoration('Species', icon: Icons.pets),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            initialValue: widget.gender,
                            enabled: false,
                            style: const TextStyle(color: Colors.black54, fontSize: 14),
                            decoration: _inputDecoration('Gender', icon: Icons.wc),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: widget.breed,
                      enabled: false,
                      style: const TextStyle(color: Colors.black54, fontSize: 14),
                      decoration: _inputDecoration('Breed', icon: Icons.category_outlined),
                    ),

                    const SizedBox(height: 18),

                    // Measurements
                    _sectionLabel('MEASUREMENTS'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Age (months)', icon: Icons.cake_outlined),
                            validator: (v) {
                              final x = double.tryParse((v ?? '').trim());
                              if (x == null || x <= 0) return 'Enter valid age';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _weightCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Weight (kg)', icon: Icons.monitor_weight_outlined),
                            validator: (v) {
                              final x = double.tryParse((v ?? '').trim());
                              if (x == null || x <= 0) return 'Enter valid weight';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Activity Level
                    _sectionLabel('ACTIVITY LEVEL'),
                    DropdownButtonFormField<String>(
                      value: _activity,
                      decoration: _inputDecoration('Activity Level', icon: Icons.directions_run),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      items: activityLevels
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                          .toList(),
                      onChanged: (v) => setState(() => _activity = v ?? 'Medium'),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.mainColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.mainColor.withOpacity(0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, size: 14, color: AppColors.darkPink),
                              SizedBox(width: 6),
                              Text(
                                'Activity Level Guide',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _bulletRow('Indoor-only cat or senior dog → Low'),
                          _bulletRow('Regular daily walks or garden play → Medium'),
                          _bulletRow('Working dog or highly energetic breed → High'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Health
                    _sectionLabel('HEALTH'),
                    DropdownButtonFormField<String>(
                      value: _disease,
                      decoration: _inputDecoration('Disease / Condition', icon: Icons.medical_services_outlined),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      items: diseaseItems
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                          .toList(),
                      onChanged: (v) => setState(() => _disease = v ?? 'None'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _allergy,
                      isExpanded: true,
                      decoration: _inputDecoration('Food Restrictions', icon: Icons.no_food_outlined),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      items: allergyItems
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                          .toList(),
                      onChanged: (v) => setState(() => _allergy = v ?? 'None'),
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Select foods to avoid due to allergies or health conditions',
                        style: TextStyle(fontSize: 11.5, color: Colors.black45),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // ── Actions ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkPink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, size: 18),
                              SizedBox(width: 8),
                              Text('Generate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}