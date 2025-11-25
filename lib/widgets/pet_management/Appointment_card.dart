import 'package:flutter/material.dart';

Widget appointmentCard(
    double sw,
    double sh,
    String title,
    String doctor,
    String date,
    String time,
    Color accentColor,
  ) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
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
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Icon(
              Icons.calendar_today,
              color: accentColor,
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
                SizedBox(height: sh * 0.006),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: sw * 0.035,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: sw * 0.01),
                    Text(
                      '$date • $time',
                      style: TextStyle(
                        fontSize: sw * 0.03,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }