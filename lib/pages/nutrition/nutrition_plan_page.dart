import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/nutrition/meal_plan_card.dart';

import 'package:pet_owner_mobile/services/pet_service.dart';
import 'package:pet_owner_mobile/services/diet_plan_service.dart';

class NutritionPlanScreen extends StatefulWidget {
  const NutritionPlanScreen({Key? key}) : super(key: key);

  @override
  State<NutritionPlanScreen> createState() => _NutritionPlanScreenState();
}

class _NutritionPlanScreenState extends State<NutritionPlanScreen> {
  final _petService = PetService();
  final _dietPlanService = DietPlanService();

  bool _loading = true;
  List<Map<String, dynamic>> _pets = [];
  List<Map<String, dynamic>> _plans = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final pets = await _petService.getMyPets();
      final plans = await _dietPlanService.getMyDietPlans();

      if (!mounted) return;
      setState(() {
        _pets = pets;
        _plans = plans;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('Failed to load meal plans');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.darkPink),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: sw * 0.05),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Nutrition Plans',
          style: TextStyle(
            fontSize: sw * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _plans.isEmpty
                      ? _buildEmptyState(sw, sh)
                      : RefreshIndicator(
                          onRefresh: _loadAll,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: sh * 0.02),
                                  _buildHeaderSection(sw, sh),
                                  SizedBox(height: sh * 0.025),
                                  Text(
                                    'Active Meal Plans',
                                    style: TextStyle(
                                      fontSize: sw * 0.048,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: sh * 0.015),

                                  ..._plans.map((plan) {
                                    final profile =
                                        (plan['profile'] as Map?)?.cast<String, dynamic>() ?? {};
                                    final nutrition =
                                        (plan['nutrition'] as Map?)?.cast<String, dynamic>() ?? {};

                                    final petId = (plan['petId'] ?? '').toString();
                                    final pet = _pets.firstWhere(
                                      (p) => (p['_id'] ?? '').toString() == petId,
                                      orElse: () => <String, dynamic>{},
                                    );

                                    final petName = (pet['name'] ?? 'Pet').toString();
                                    final petBreed = (profile['breed'] ?? pet['breed'] ?? '').toString();

                                    final mealsCount = (nutrition['meals_per_day'] is num)
                                        ? (nutrition['meals_per_day'] as num).toInt()
                                        : 0;

                                    final createdAt = (plan['createdAt'] ?? '').toString();
                                    final planDate = createdAt.isNotEmpty
                                        ? 'Generated on $createdAt'
                                        : 'Generated recently';

                                    return Padding(
                                      padding: EdgeInsets.only(bottom: sh * 0.015),
                                      child: MealPlanCard(
                                        petName: petName,
                                        petBreed: petBreed,
                                        petAge: _formatAgeFromProfile(profile),
                                        planDate: planDate,
                                        mealsCount: mealsCount,
                                        // if MealPlanCard expects a Color:
                                        bgColor: AppColors.darkPink.withOpacity(0.12),
                                        onTap: () {
                                          context.goNamed(
                                            'NutritionPlanDetailsScreen',
                                            extra: {'plan': plan},
                                          );
                                        },
                                      ),
                                    );
                                  }).toList(),

                                  SizedBox(height: sh * 0.02),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
            _buildGenerateButton(sw, sh),
          ],
        ),
      ),
    );
  }

  String _formatAgeFromProfile(Map<String, dynamic> profile) {
    final ageMonths = profile['ageMonths'];
    if (ageMonths is num) {
      final months = ageMonths.toInt();
      if (months >= 12) {
        final years = months ~/ 12;
        final rem = months % 12;
        return rem == 0 ? '$years years' : '$years years $rem months';
      }
      return '$months months';
    }
    return '';
  }

  Widget _buildHeaderSection(double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.mainColor.withOpacity(0.3),
            AppColors.darkPink.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(sw * 0.04),
      ),
      child: Row(
        children: [
          Container(
            width: sw * 0.15,
            height: sw * 0.15,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(sw * 0.03),
            ),
            child: Icon(Icons.restaurant_menu, size: sw * 0.08, color: AppColors.darkPink),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personalized Nutrition',
                  style: TextStyle(
                    fontSize: sw * 0.042,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: sh * 0.005),
                Text(
                  'AI-powered meal plans tailored for your pets',
                  style: TextStyle(fontSize: sw * 0.033, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(double sw, double sh) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: sw * 0.3,
              height: sw * 0.3,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.restaurant, size: sw * 0.15, color: Colors.grey[400]),
            ),
            SizedBox(height: sh * 0.03),
            Text(
              'No Meal Plans Yet',
              style: TextStyle(
                fontSize: sw * 0.055,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: sh * 0.01),
            Text(
              'Generate personalized nutrition plans for your pets to keep them healthy and happy',
              style: TextStyle(fontSize: sw * 0.038, color: Colors.black54, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(sw * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _pets.isEmpty
            ? () => _showSnack('No pets found. Please add a pet first.')
            : () => _showSelectPetSheet(sw, sh),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPink,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: sh * 0.018),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sw * 0.03),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: sw * 0.055),
            SizedBox(width: sw * 0.02),
            Text(
              'Generate Meal Plan',
              style: TextStyle(fontSize: sw * 0.042, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectPetSheet(double sw, double sh) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(sw * 0.05),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(sw * 0.06),
            topRight: Radius.circular(sw * 0.06),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: sw * 0.12,
              height: sh * 0.005,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(sw * 0.01),
              ),
            ),
            SizedBox(height: sh * 0.025),
            Text(
              'Select Pet',
              style: TextStyle(fontSize: sw * 0.052, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: sh * 0.02),
            ..._pets.map((pet) {
              final name = (pet['name'] ?? 'Pet').toString();
              final breed = (pet['breed'] ?? '').toString();

              return Padding(
                padding: EdgeInsets.only(bottom: sh * 0.012),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    // ✅ IMPORTANT: do NOT call getPetById again. Use already-loaded pet map.
                    _openGenerateFormFromPet(pet);
                  },
                  child: Container(
                    padding: EdgeInsets.all(sw * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(sw * 0.03),
                      border: Border.all(color: Colors.pink.withOpacity(0.2), width: 1),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.pets, color: Colors.grey),
                        ),
                        SizedBox(width: sw * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: sw * 0.042,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                breed,
                                style: TextStyle(
                                  fontSize: sw * 0.033,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: sw * 0.045, color: Colors.black38),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: sh * 0.01),
          ],
        ),
      ),
    );
  }

  Future<void> _openGenerateFormFromPet(Map<String, dynamic> pet) async {
    try {
      final petId = (pet['_id'] ?? '').toString();
      if (petId.isEmpty) {
        _showSnack('Invalid pet selected');
        return;
      }

      if (!mounted) return;
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _GenerateDietFormSheet(
          petId: petId,
          petName: (pet['name'] ?? 'Pet').toString(),
          species: (pet['species'] ?? '').toString(),
          breed: (pet['breed'] ?? '').toString(),
          gender: (pet['gender'] ?? '').toString(),
          onGenerated: (plan) async {
            await _loadAll();
            if (!mounted) return;
            context.goNamed('NutritionPlanDetailsScreen', extra: {'plan': plan});
          },
        ),
      );
    } catch (e) {
      _showSnack('Failed to open generate form');
    }
  }
}

class _GenerateDietFormSheet extends StatefulWidget {
  final String petId;
  final String petName;
  final String species;
  final String breed;
  final String gender;
  final Future<void> Function(Map<String, dynamic> plan) onGenerated;

  const _GenerateDietFormSheet({
    required this.petId,
    required this.petName,
    required this.species,
    required this.breed,
    required this.gender,
    required this.onGenerated,
  });

  @override
  State<_GenerateDietFormSheet> createState() => _GenerateDietFormSheetState();
}

class _GenerateDietFormSheetState extends State<_GenerateDietFormSheet> {
  final _dietService = DietPlanService();
  final _formKey = GlobalKey<FormState>();

  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String _activityLevel = 'Medium';
  String _disease = 'None';
  String _allergy = 'None';

  bool _submitting = false;

  static const activityLevels = ['Low', 'Medium', 'High'];

  static const diseases = [
    'Ehrlichiosis',
    'Babesiosis',
    'Upper Respiratory_infections',
    'Chronic Kidney',
    'Pavovirus',
    'None',
  ];

  static const allergies = [
    'Beef',
    'Pork',
    'Diary',
    'Wheat',
    'Chicken',
    'Fish',
    'None',
  ];

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(
        left: sw * 0.05,
        right: sw * 0.05,
        top: sw * 0.04,
        bottom: MediaQuery.of(context).viewInsets.bottom + sw * 0.05,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(sw * 0.06),
          topRight: Radius.circular(sw * 0.06),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: sw * 0.12,
                  height: sh * 0.005,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(sw * 0.01),
                  ),
                ),
              ),
              SizedBox(height: sh * 0.02),
              Text(
                'Generate Plan for ${widget.petName}',
                style: TextStyle(fontSize: sw * 0.05, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: sh * 0.015),

              _readOnlyField('Species', widget.species),
              _readOnlyField('Breed', widget.breed),
              _readOnlyField('Gender', widget.gender),

              SizedBox(height: sh * 0.015),

              TextFormField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age (Months)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final x = double.tryParse((v ?? '').trim());
                  if (x == null || x <= 0) return 'Enter valid age in months';
                  return null;
                },
              ),
              SizedBox(height: sh * 0.012),
              TextFormField(
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (Kg)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final x = double.tryParse((v ?? '').trim());
                  if (x == null || x <= 0) return 'Enter valid weight';
                  return null;
                },
              ),

              SizedBox(height: sh * 0.012),
              DropdownButtonFormField<String>(
                value: _activityLevel,
                items: activityLevels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _activityLevel = v ?? 'Medium'),
                decoration: const InputDecoration(
                  labelText: 'Activity Level',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: sh * 0.012),
              DropdownButtonFormField<String>(
                value: _disease,
                items: diseases.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _disease = v ?? 'None'),
                decoration: const InputDecoration(
                  labelText: 'Disease',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: sh * 0.012),
              DropdownButtonFormField<String>(
                value: _allergy,
                items: allergies.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _allergy = v ?? 'None'),
                decoration: const InputDecoration(
                  labelText: 'Allergy',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: sh * 0.02),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPink,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: sh * 0.016),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.03)),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Generate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final plan = await _dietService.generateDietPlan(
        petId: widget.petId,
        ageMonths: double.parse(_ageCtrl.text.trim()),
        weightKg: double.parse(_weightCtrl.text.trim()),
        activityLevel: _activityLevel,
        disease: _disease,
        allergy: _allergy,
      );

      if (!mounted) return;
      Navigator.pop(context); // close sheet
      await widget.onGenerated(plan);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diet generation failed')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}