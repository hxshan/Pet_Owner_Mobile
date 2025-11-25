import 'package:flutter/material.dart';

class UpdateCard extends StatelessWidget {
  final double sw;
  final double sh;
  final Color backgroundColor;
  final Color borderColor;
  final String title;
  final String date;
  final String description;
  final Color titleColor;

  const UpdateCard({
    required this.sw,
    required this.sh,
    required this.backgroundColor,
    required this.borderColor,
    required this.title,
    required this.date,
    required this.description,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: sw * 0.004),
        borderRadius: BorderRadius.circular(sw * 0.03),
        color: backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: sw * 0.032,
                  color: titleColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: sw * 0.032,
                  color: titleColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: sh * 0.01),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: sw * 0.028,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}