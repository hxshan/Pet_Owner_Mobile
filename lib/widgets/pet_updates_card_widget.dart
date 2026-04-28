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
  final VoidCallback? onTap;
  final IconData? icon;

  const UpdateCard({
    required this.sw,
    required this.sh,
    required this.backgroundColor,
    required this.borderColor,
    required this.title,
    required this.date,
    required this.description,
    required this.titleColor,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: sw * 0.004),
        borderRadius: BorderRadius.circular(sw * 0.03),
        color: backgroundColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: titleColor, size: sw * 0.045),
            SizedBox(width: sw * 0.03),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: sw * 0.032,
                          color: titleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: sw * 0.028,
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: sh * 0.008),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: sw * 0.03,
                    color: Colors.black87,
                  ),
                ),

                if (onTap != null) ...[
                  SizedBox(height: sh * 0.008),
                  Text(
                    'Tap to view →',
                    style: TextStyle(
                      fontSize: sw * 0.028,
                      color: titleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}