enum NotificationType {
  appointment,
  vaccination,
  health,
  reminder,
  dietUpdate,
  general,
  unknown,
}

NotificationType notificationTypeFromApi(String? v) {
  final s = (v ?? '').toUpperCase();
  switch (s) {
    case 'APPOINTMENT':
    case 'APPOINTMENT_REMINDER':
      return NotificationType.appointment;

    case 'VACCINATION':
    case 'VACCINATION_REMINDER':
      return NotificationType.vaccination;

    case 'HEALTH':
    case 'HEALTH_ALERT':
      return NotificationType.health;

    case 'REMINDER':
    case 'MEDICATION_REMINDER':
      return NotificationType.reminder;

    case 'DIET_PLAN_UPDATE':
      return NotificationType.dietUpdate;

    case 'GENERAL':
      return NotificationType.general;

    default:
      return NotificationType.unknown;
  }
}


class NotificationChange {
  final String field;
  final String oldValue;
  final String newValue;

  NotificationChange({
    required this.field,
    required this.oldValue,
    required this.newValue,
  });

  factory NotificationChange.fromJson(Map<String, dynamic> json) {
    return NotificationChange(
      field: json['field'] ?? '',
      oldValue: json['oldValue'] ?? '',
      newValue: json['newValue'] ?? '',
    );
  }
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

 
  final String severity;
  final List<NotificationChange> changes;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.severity,
    required this.changes,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final type = notificationTypeFromApi(json['type']?.toString());

    String autoTitle(NotificationType t) {
      switch (t) {
        case NotificationType.appointment:
          return 'Appointment';
        case NotificationType.vaccination:
          return 'Vaccination';
        case NotificationType.health:
          return 'Health Alert';
        case NotificationType.reminder:
          return 'Reminder';
        case NotificationType.dietUpdate:
          return 'Diet Plan Review Alert';
        case NotificationType.general:
          return 'Notification';
        default:
          return 'Notification';
      }
    }

    return AppNotification(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      type: type,
      title: (json['title'] ?? '').toString().trim().isNotEmpty
          ? json['title'].toString()
          : autoTitle(type),
      message: (json['message'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] == true,

      
      severity: (json['severity'] ?? 'low').toString(),
      changes: (json['changes'] as List? ?? [])
          .map((e) => NotificationChange.fromJson(e))
          .toList(),
    );
  }
}