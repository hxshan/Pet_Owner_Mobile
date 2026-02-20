import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class MealPlanDetailsScreen extends StatefulWidget {
  final String petName;
  final String petBreed;

  const MealPlanDetailsScreen({
    Key? key,
    required this.petName,
    required this.petBreed,
  }) : super(key: key);

  @override
  State<MealPlanDetailsScreen> createState() => _MealPlanDetailsScreenState();
}

class _MealPlanDetailsScreenState extends State<MealPlanDetailsScreen> {
  // Sample meal plan data - replace with actual data from your backend
  final List<Map<String, dynamic>> mealPlan = [
    {
      'mealName': 'Meal 1',
      'mealTime': 'Breakfast - 8:00 AM',
      'ingredients': [
        {'name': 'Boiled Seer Fish', 'amount': '19 g'},
        {'name': 'Boiled Sweet Potato', 'amount': '34 g'},
        {'name': 'Fish Oil', 'amount': '1 g'},
      ],
      'totalCalories': '120 kcal',
      'icon': Icons.wb_sunny,
      'iconColor': Colors.orange,
    },
    {
      'mealName': 'Meal 2',
      'mealTime': 'Lunch - 1:00 PM',
      'ingredients': [
        {'name': 'Boiled Egg Whole', 'amount': '37 g'},
        {'name': 'Cooked Pumpkin', 'amount': '104 g'},
        {'name': 'Omega 3 Supplement', 'amount': '1 g'},
      ],
      'totalCalories': '145 kcal',
      'icon': Icons.wb_sunny_outlined,
      'iconColor': Colors.amber,
    },
    {
      'mealName': 'Meal 3',
      'mealTime': 'Dinner - 6:00 PM',
      'ingredients': [
        {'name': 'Cooked Red Dhal', 'amount': '52 g'},
        {'name': 'Pork & Coconut Rice', 'amount': '27 g'},
        {'name': 'Coconut Oil', 'amount': '1 g'},
      ],
      'totalCalories': '165 kcal',
      'icon': Icons.nightlight,
      'iconColor': Colors.indigo,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(sw, sh),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPetInfoSection(sw, sh),
                    SizedBox(height: sh * 0.02),
                    _buildNutritionSummary(sw, sh),
                    SizedBox(height: sh * 0.025),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Meal Plan',
                            style: TextStyle(
                              fontSize: sw * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: sh * 0.015),
                          ...mealPlan.asMap().entries.map((entry) {
                            final index = entry.key;
                            final meal = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(bottom: sh * 0.015),
                              child: _buildMealCard(sw, sh, meal, index),
                            );
                          }),
                          SizedBox(height: sh * 0.02),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildActionButtons(sw, sh),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(sw * 0.05),
      child: Row(
        children: [
          CustomBackButton(showPadding: false,),
          Expanded(
            child: Center(
              child: Text(
                'Meal Plan Details',
                style: TextStyle(
                  fontSize: sw * 0.048,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _showMoreOptions(sw, sh);
            },
            child: Container(
              padding: EdgeInsets.all(sw * 0.02),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(sw * 0.025),
              ),
              child: Icon(
                Icons.more_vert,
                size: sw * 0.05,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetInfoSection(double sw, double sh) {
    // Use a gradient background instead of bgColor
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.05),
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.mainColor.withOpacity(0.4),
            AppColors.darkPink.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: sw * 0.18,
            height: sw * 0.18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.pets, size: sw * 0.09, color: Colors.grey[400]),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.petName,
                  style: TextStyle(
                    fontSize: sw * 0.055,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: sh * 0.005),
                Text(
                  widget.petBreed,
                  style: TextStyle(fontSize: sw * 0.038, color: Colors.black54),
                ),
                SizedBox(height: sh * 0.008),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.025,
                    vertical: sh * 0.006,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(sw * 0.015),
                  ),
                  child: Text(
                    'Plan valid for 7 days',
                    style: TextStyle(
                      fontSize: sw * 0.03,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkPink,
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

  Widget _buildNutritionSummary(double sw, double sh) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sw * 0.05),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkPink, AppColors.mainColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Nutrition Summary',
            style: TextStyle(
              fontSize: sw * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: sh * 0.02),
          // First row - 3 items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionItem(
                sw,
                sh,
                '14.03g',
                'Protein',
                Icons.fitness_center,
              ),
              _buildNutritionItem(
                sw,
                sh,
                '20.25g',
                'Carbs',
                Icons.bakery_dining,
              ),
              _buildNutritionItem(sw, sh, '3.9g', 'Fats', Icons.water_drop),
            ],
          ),
          SizedBox(height: sh * 0.02),
          // Second row - 2 items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNutritionItem(
                sw,
                sh,
                '181.99',
                'kcal',
                Icons.local_fire_department,
              ),
              _buildNutritionItem(sw, sh, '3', 'meals', Icons.restaurant),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(
    double sw,
    double sh,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(sw * 0.025),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(sw * 0.025),
          ),
          child: Icon(icon, size: sw * 0.06, color: Colors.white),
        ),
        SizedBox(height: sh * 0.008),
        Text(
          value,
          style: TextStyle(
            fontSize: sw * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: sw * 0.03, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildMealCard(
    double sw,
    double sh,
    Map<String, dynamic> meal,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Meal header
          Container(
            padding: EdgeInsets.all(sw * 0.04),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(sw * 0.04),
                topRight: Radius.circular(sw * 0.04),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(sw * 0.025),
                  decoration: BoxDecoration(
                    color: meal['iconColor'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Icon(
                    meal['icon'],
                    size: sw * 0.055,
                    color: meal['iconColor'],
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal['mealName'],
                        style: TextStyle(
                          fontSize: sw * 0.042,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: sh * 0.003),
                      Text(
                        meal['mealTime'],
                        style: TextStyle(
                          fontSize: sw * 0.032,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.025,
                    vertical: sh * 0.006,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkPink.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(sw * 0.015),
                  ),
                  child: Text(
                    meal['totalCalories'],
                    style: TextStyle(
                      fontSize: sw * 0.03,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkPink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Ingredients list
          Padding(
            padding: EdgeInsets.all(sw * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: sw * 0.036,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: sh * 0.01),
                ...meal['ingredients'].map<Widget>((ingredient) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: sh * 0.008),
                    child: Row(
                      children: [
                        Container(
                          width: sw * 0.015,
                          height: sw * 0.015,
                          decoration: BoxDecoration(
                            color: AppColors.darkPink,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: sw * 0.025),
                        Expanded(
                          child: Text(
                            ingredient['name'],
                            style: TextStyle(
                              fontSize: sw * 0.035,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          ingredient['amount'],
                          style: TextStyle(
                            fontSize: sw * 0.034,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double sw, double sh) {
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _showShareOptions(sw, sh);
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: sh * 0.016),
                side: const BorderSide(color: AppColors.darkPink, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sw * 0.03),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share, size: sw * 0.05, color: AppColors.darkPink),
                  SizedBox(width: sw * 0.02),
                  Text(
                    'Share',
                    style: TextStyle(
                      fontSize: sw * 0.04,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkPink,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Meal plan downloaded successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPink,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: sh * 0.016),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sw * 0.03),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download, size: sw * 0.05),
                  SizedBox(width: sw * 0.02),
                  Text(
                    'Download',
                    style: TextStyle(
                      fontSize: sw * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(double sw, double sh) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
            _buildOptionItem(sw, sh, Icons.edit, 'Edit Meal Plan', Colors.blue),
            _buildOptionItem(
              sw,
              sh,
              Icons.refresh,
              'Regenerate Plan',
              Colors.green,
            ),
            _buildOptionItem(sw, sh, Icons.delete, 'Delete Plan', Colors.red),
            SizedBox(height: sh * 0.01),
          ],
        ),
      ),
    );
  }

  void _showShareOptions(double sw, double sh) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
              'Share Meal Plan',
              style: TextStyle(
                fontSize: sw * 0.048,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: sh * 0.02),
            _buildOptionItem(
              sw,
              sh,
              Icons.email,
              'Share via Email',
              Colors.orange,
            ),
            _buildOptionItem(
              sw,
              sh,
              Icons.message,
              'Share via SMS',
              Colors.green,
            ),
            _buildOptionItem(
              sw,
              sh,
              Icons.content_copy,
              'Copy to Clipboard',
              Colors.blue,
            ),
            SizedBox(height: sh * 0.01),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    double sw,
    double sh,
    IconData icon,
    String label,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label selected'), backgroundColor: color),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: sh * 0.012),
        padding: EdgeInsets.all(sw * 0.04),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(sw * 0.03),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(sw * 0.025),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(sw * 0.02),
              ),
              child: Icon(icon, size: sw * 0.055, color: color),
            ),
            SizedBox(width: sw * 0.035),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: sw * 0.038,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: sw * 0.04,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
