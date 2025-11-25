import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

enum NotificationType {
  appointment,
  vaccination,
  reminder,
  health,
  general,
}

class NotificationCard extends StatelessWidget {
  final double sw;
  final double sh;
  final NotificationType type;
  final String title;
  final String message;
  final String time;
  final bool isRead;
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
    this.isRead = false,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  Color _getTypeColor() {
    switch (type) {
      case NotificationType.appointment:
        return Colors.blue;
      case NotificationType.vaccination:
        return Colors.green;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.health:
        return AppColors.errorMessage;
      case NotificationType.general:
        return Colors.grey;
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
      case NotificationType.general:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();
    final typeIcon = _getTypeIcon();

    return Dismissible(
      key: Key(title + time),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        if (onDismiss != null) {
          onDismiss!();
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: sw * 0.05),
        decoration: BoxDecoration(
          color: AppColors.errorMessage,
          borderRadius: BorderRadius.circular(sw * 0.03),
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: sw * 0.06,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: sh * 0.015),
          padding: EdgeInsets.all(sw * 0.04),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : typeColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(sw * 0.03),
            border: Border.all(
              color: isRead
                  ? Colors.grey.shade300
                  : typeColor.withOpacity(0.3),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Section
              Container(
                padding: EdgeInsets.all(sw * 0.03),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(sw * 0.02),
                ),
                child: Icon(
                  typeIcon,
                  color: typeColor,
                  size: sw * 0.055,
                ),
              ),
              
              SizedBox(width: sw * 0.035),
              
              // Content Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: sw * 0.04,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: sw * 0.022,
                            height: sw * 0.022,
                            decoration: BoxDecoration(
                              color: typeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    
                    SizedBox(height: sh * 0.006),
                    
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: sw * 0.033,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: sh * 0.008),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: sw * 0.032,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: sw * 0.01),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: sw * 0.028,
                            color: Colors.grey.shade500,
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