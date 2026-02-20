import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/nutrition/meal_plan_card.dart';

class NutritionPlanScreen extends StatefulWidget {
  const NutritionPlanScreen({Key? key}) : super(key: key);

  @override
  State<NutritionPlanScreen> createState() => _NutritionPlanScreenState();
}

class _NutritionPlanScreenState extends State<NutritionPlanScreen> {
  // Sample data - replace with actual data from your backend
  final List<Map<String, dynamic>> petMealPlans = [
    {
      'petName': 'Max',
      'petBreed': 'Golden Retriever',
      'petAge': '3 years old',
      'planDate': 'Generated on Nov 15, 2024',
      'mealsCount': 3,
      'bgColor': Colors.amber[100],
    },
    {
      'petName': 'Luna',
      'petBreed': 'Persian Cat',
      'petAge': '2 years old',
      'planDate': 'Generated on Nov 10, 2024',
      'mealsCount': 3,
      'bgColor': Colors.purple[100],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: sw * 0.09,
              height: sw * 0.09,
              decoration: BoxDecoration(
                color: AppColors.darkPink,
                borderRadius: BorderRadius.circular(sw * 0.025),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: sw * 0.042,
              ),
            ),
          ),
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
              child: petMealPlans.isEmpty
                  ? _buildEmptyState(sw, sh)
                  : SingleChildScrollView(
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
                            ...petMealPlans.map(
                              (plan) => Padding(
                                padding: EdgeInsets.only(bottom: sh * 0.015),
                                child: MealPlanCard(
                                  petName: plan['petName'],
                                  petBreed: plan['petBreed'],
                                  petAge: plan['petAge'],
                                  planDate: plan['planDate'],
                                  mealsCount: plan['mealsCount'],
                                  bgColor: plan['bgColor'],
                                  onTap: () {
                                    // Navigate to meal plan details
                                    context.pushNamed(
                                      'NutritionPlanDetailsScreen',
                                      extra: {
                                        'petName': plan['petName'],
                                        'petBreed': plan['petBreed'],
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: sh * 0.02),
                          ],
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
        onPressed: () {
          _showGeneratePlanDialog(sw, sh);
        },
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

  void _showGeneratePlanDialog(double sw, double sh) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
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
                color: Colors.black87,
              ),
            ),
            SizedBox(height: sh * 0.02),
            Text(
              'Choose which pet you want to generate a meal plan for',
              style: TextStyle(fontSize: sw * 0.036, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: sh * 0.025),
            _buildPetSelectionItem(
              sw,
              sh,
              'Max',
              'Golden Retriever',
              Colors.amber[100]!,
            ),
            SizedBox(height: sh * 0.012),
            _buildPetSelectionItem(
              sw,
              sh,
              'Luna',
              'Persian Cat',
              Colors.purple[100]!,
            ),
            SizedBox(height: sh * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildPetSelectionItem(
    double sw,
    double sh,
    String name,
    String breed,
    Color bgColor,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Navigate to form or generate plan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generating meal plan for $name...'),
            backgroundColor: AppColors.darkPink,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(sw * 0.04),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(sw * 0.03),
          border: Border.all(color: bgColor.withOpacity(0.5), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: sw * 0.12,
              height: sw * 0.12,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.pets, size: sw * 0.06, color: Colors.grey[400]),
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
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: sh * 0.003),
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
    );
  }
}
