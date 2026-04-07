import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/models/notification_model.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class NotificationCard extends StatelessWidget {
  final double sw;
  final double sh;
  final NotificationType type;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final String severity;
  final List<NotificationChange> changes;

  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationCard({
    Key? key,
    required this.sw,
    required this.sh,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.severity,
    required this.changes,
    this.isRead = false,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  Color _getSeverityColor() {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _getTypeIcon() {
    switch (type) {
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.vaccination:
        return Icons.medical_services;
      case NotificationType.reminder:
        return Icons.notifications_active;
      case NotificationType.health:
        return Icons.favorite;
      case NotificationType.dietUpdate:
        return Icons.monitor_weight;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor();
    final icon = _getTypeIcon();

    return Dismissible(
      key: Key(title + time),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: sw * 0.05),
        decoration: BoxDecoration(
          color: AppColors.errorMessage,
          borderRadius: BorderRadius.circular(sw * 0.03),
        ),
        child: Icon(Icons.delete, color: Colors.white, size: sw * 0.06),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: sh * 0.015),
          padding: EdgeInsets.all(sw * 0.04),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(sw * 0.03),
            border: Border.all(
              color: isRead ? Colors.grey.shade300 : color.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICON
              Container(
                padding: EdgeInsets.all(sw * 0.03),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(sw * 0.02),
                ),
                child: Icon(icon, color: color, size: sw * 0.055),
              ),

              SizedBox(width: sw * 0.035),

              // CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: sw * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: sw * 0.02,
                            height: sw * 0.02,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: sh * 0.006),

                    // MESSAGE
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: sw * 0.033,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    // CHANGES DISPLAY
                    if (changes.isNotEmpty) ...[
                      SizedBox(height: sh * 0.008),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: changes.map((c) {
                          return Text(
                            "${c.field}: ${c.oldValue} → ${c.newValue}",
                            style: TextStyle(
                              fontSize: sw * 0.03,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    SizedBox(height: sh * 0.01),

                    // TIME
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: sw * 0.03, color: Colors.grey),
                        SizedBox(width: sw * 0.01),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: sw * 0.028,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}