import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

Widget medicalReportCard(
    double sw,
    double sh,
    String title,
    String date,
    String doctor,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.03),
            decoration: BoxDecoration(
              color: AppColors.mainColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Icon(
              icon,
              color: AppColors.darkPink,
              size: sw * 0.055,
            ),
          ),
          SizedBox(width: sw * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: sw * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: sh * 0.004),
                Text(
                  doctor,
                  style: TextStyle(
                    fontSize: sw * 0.032,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: sh * 0.004),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: sw * 0.03,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: sw * 0.04,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
