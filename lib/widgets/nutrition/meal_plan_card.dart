import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class MealPlanCard extends StatelessWidget {
  final String petName;
  final String petBreed;
  final String petAge;
  final String planDate;
  final int mealsCount;
  final Color bgColor;
  final VoidCallback onTap;

  const MealPlanCard({
    Key? key,
    required this.petName,
    required this.petBreed,
    required this.petAge,
    required this.planDate,
    required this.mealsCount,
    required this.bgColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top section with pet info
            Container(
              padding: EdgeInsets.all(sw * 0.04),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sw * 0.04),
                  topRight: Radius.circular(sw * 0.04),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: sw * 0.16,
                    height: sw * 0.16,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pets,
                      size: sw * 0.08,
                      color: Colors.grey[400],
                    ),
                  ),
                  SizedBox(width: sw * 0.035),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          petName,
                          style: TextStyle(
                            fontSize: sw * 0.048,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: sh * 0.004),
                        Text(
                          petBreed,
                          style: TextStyle(
                            fontSize: sw * 0.035,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: sh * 0.002),
                        Text(
                          petAge,
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.03,
                      vertical: sh * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(sw * 0.05),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: sw * 0.04,
                          color: Colors.green,
                        ),
                        SizedBox(width: sw * 0.015),
                        Text(
                          'Active',
                          style: TextStyle(
                            fontSize: sw * 0.03,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom section with plan details
            Padding(
              padding: EdgeInsets.all(sw * 0.04),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildInfoChip(
                        sw,
                        sh,
                        Icons.restaurant,
                        '$mealsCount Meals/Day',
                        AppColors.darkPink,
                      ),
                      SizedBox(width: sw * 0.02),
                      _buildInfoChip(
                        sw,
                        sh,
                        Icons.calendar_today,
                        planDate.split(' on ')[1],
                        Colors.blue,
                      ),
                    ],
                  ),
                  SizedBox(height: sh * 0.015),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.04,
                      vertical: sh * 0.012,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(sw * 0.02),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'View Full Meal Plan',
                          style: TextStyle(
                            fontSize: sw * 0.036,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkPink,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: sw * 0.045,
                          color: AppColors.darkPink,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(double sw, double sh, IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.025,
          vertical: sh * 0.01,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(sw * 0.02),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: sw * 0.04,
              color: color,
            ),
            SizedBox(width: sw * 0.015),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: sw * 0.03,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}