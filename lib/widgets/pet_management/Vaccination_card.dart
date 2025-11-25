import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

Widget vaccinationCard(
    double sw,
    double sh,
    String name,
    String givenDate,
    String nextDue,
    bool isUpToDate,
  ) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: isUpToDate
            ? Colors.green.withOpacity(0.05)
            : AppColors.errorMessage.withOpacity(0.05),
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(
          color: isUpToDate
              ? Colors.green.withOpacity(0.3)
              : AppColors.errorMessage.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.025),
            decoration: BoxDecoration(
              color: isUpToDate
                  ? Colors.green.withOpacity(0.2)
                  : AppColors.errorMessage.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUpToDate ? Icons.check_circle : Icons.warning,
              color: isUpToDate ? Colors.green : AppColors.errorMessage,
              size: sw * 0.05,
            ),
          ),
          SizedBox(width: sw * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: sw * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: sh * 0.004),
                Text(
                  'Given: $givenDate',
                  style: TextStyle(
                    fontSize: sw * 0.03,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: sh * 0.002),
                Text(
                  nextDue,
                  style: TextStyle(
                    fontSize: sw * 0.03,
                    color: isUpToDate ? Colors.green.shade700 : AppColors.errorMessage,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }