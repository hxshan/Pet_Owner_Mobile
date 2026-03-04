enum NotificationType {
  appointment,
  vaccination,
  health,
  reminder,
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

    case 'GENERAL':
      return NotificationType.general;

    default:
      return NotificationType.unknown;
  }
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // Backend sample: { _id, type, message, createdAt, isRead, ... }
    final type = notificationTypeFromApi(json['type']?.toString());

    // If backend doesn't store title, we can generate a nice one by type
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
    );
  }
}