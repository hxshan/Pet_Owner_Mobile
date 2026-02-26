import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/nutrition/meal_plan_card.dart';

import 'package:pet_owner_mobile/services/pet_service.dart';
import 'package:pet_owner_mobile/services/diet_plan_service.dart';

import 'package:pet_owner_mobile/widgets/nutrition/diet_form_dialog.dart';

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
        leading: CustomBackButton(),
        // IconButton(
        //   icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: sw * 0.05),
        //   onPressed: () => context.pop(),
        // ),
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
                                    (plan['profile'] as Map?)
                                        ?.cast<String, dynamic>() ??
                                    {};
                                final nutrition =
                                    (plan['nutrition'] as Map?)
                                        ?.cast<String, dynamic>() ??
                                    {};

                                final petId = (plan['petId'] ?? '').toString();
                                final pet = _pets.firstWhere(
                                  (p) => (p['_id'] ?? '').toString() == petId,
                                  orElse: () => <String, dynamic>{},
                                );

                                final petName = (pet['name'] ?? 'Pet')
                                    .toString();
                                final petBreed =
                                    (profile['breed'] ?? pet['breed'] ?? '')
                                        .toString();

                                final mealsCount =
                                    (nutrition['meals_per_day'] is num)
                                    ? (nutrition['meals_per_day'] as num)
                                          .toInt()
                                    : 0;

                                final createdAt = (plan['createdAt'] ?? '')
                                    .toString();
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
                                    bgColor: AppColors.darkPink.withOpacity(
                                      0.12,
                                    ),
                                    onTap: () {
                                      context.pushNamed(
                                        'NutritionPlanDetailsScreen',
                                        extra: {
                                          'plan': {
                                            ...plan,
                                            'petName': petName,
                                            'petBreed': petBreed,
                                          },
                                        },
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
            child: Icon(
              Icons.restaurant_menu,
              size: sw * 0.08,
              color: AppColors.darkPink,
            ),
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
              child: Icon(
                Icons.restaurant,
                size: sw * 0.15,
                color: Colors.grey[400],
              ),
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
              style: TextStyle(
                fontSize: sw * 0.038,
                color: Colors.black54,
                height: 1.5,
              ),
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
              style: TextStyle(
                fontSize: sw * 0.042,
                fontWeight: FontWeight.bold,
              ),
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
              style: TextStyle(
                fontSize: sw * 0.052,
                fontWeight: FontWeight.bold,
              ),
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
                    _openGenerateDialogFromPet(pet);
                  },
                  child: Container(
                    padding: EdgeInsets.all(sw * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(sw * 0.03),
                      border: Border.all(
                        color: Colors.pink.withOpacity(0.2),
                        width: 1,
                      ),
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
                        Icon(
                          Icons.arrow_forward_ios,
                          size: sw * 0.045,
                          color: Colors.black38,
                        ),
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

  Future<void> _openGenerateDialogFromPet(Map<String, dynamic> pet) async {
    try {
      final petId = (pet['_id'] ?? '').toString();
      if (petId.isEmpty) {
        _showSnack('Invalid pet selected');
        return;
      }

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return DietFormDialog(
            petId: petId,
            species: (pet['species'] ?? '').toString(),
            breed: (pet['breed'] ?? '').toString(),
            gender: (pet['gender'] ?? '').toString(),
            onGenerate:
                ({
                  required double ageMonths,
                  required double weightKg,
                  required String activityLevel,
                  required String disease,
                  required String allergy,
                }) async {
                  final plan = await _dietPlanService.generateDietPlan(
                    petId: petId,
                    ageMonths: ageMonths,
                    weightKg: weightKg,
                    activityLevel: activityLevel,
                    disease: disease,
                    allergy: allergy,
                  );

                  await _loadAll();
                  if (!mounted) return;

                  final petName = (pet['name'] ?? 'Pet').toString();
                  final petBreed = (pet['breed'] ?? '').toString();

                  context.goNamed(
                    'NutritionPlanDetailsScreen',
                    extra: {
                      'plan': {
                        ...plan,
                        'petName': petName,
                        'petBreed': petBreed,
                      },
                    },
                  );
                },
          );
        },
      );
    } catch (e) {
      _showSnack('Failed to open generate form');
    }
  }
}
