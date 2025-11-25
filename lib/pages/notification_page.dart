import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/notification_card_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String selectedFilter = 'All';
  
  // Sample notification data
  List<Map<String, dynamic>> notifications = [
    {
      'type': NotificationType.appointment,
      'title': 'Appointment Reminder',
      'message': 'Annual checkup for Suddu Putha scheduled tomorrow at 10:30 AM with Dr. Sarah Johnson',
      'time': '2 hours ago',
      'isRead': false,
    },
    {
      'type': NotificationType.vaccination,
      'title': 'Vaccination Due',
      'message': 'Rabies vaccine for Suddu Putha is due in 3 days. Please schedule an appointment.',
      'time': '5 hours ago',
      'isRead': false,
    },
    {
      'type': NotificationType.health,
      'title': 'Health Alert',
      'message': 'Bordetella vaccine for Suddu Putha is overdue. Immediate attention required.',
      'time': '1 day ago',
      'isRead': true,
    },
    {
      'type': NotificationType.reminder,
      'title': 'Medication Reminder',
      'message': 'Time to give Suddu Putha the daily medication. Don\'t forget!',
      'time': '1 day ago',
      'isRead': true,
    },
    {
      'type': NotificationType.appointment,
      'title': 'Appointment Confirmed',
      'message': 'Your appointment for dental cleaning on 05/04/2025 has been confirmed.',
      'time': '2 days ago',
      'isRead': true,
    },
    {
      'type': NotificationType.general,
      'title': 'Profile Updated',
      'message': 'Pet profile for Suddu Putha has been successfully updated.',
      'time': '3 days ago',
      'isRead': true,
    },
    {
      'type': NotificationType.vaccination,
      'title': 'Vaccination Completed',
      'message': 'DHPP vaccine for Suddu Putha has been administered successfully.',
      'time': '1 week ago',
      'isRead': true,
    },
  ];

  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedFilter == 'All') {
      return notifications;
    } else if (selectedFilter == 'Unread') {
      return notifications.where((n) => !n['isRead']).toList();
    } else {
      return notifications.where((n) => n['isRead']).toList();
    }
  }

  int get unreadCount {
    return notifications.where((n) => !n['isRead']).length;
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notification deleted',
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: sw * 0.05,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: sw * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  fontSize: sw * 0.032,
                  color: AppColors.darkPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Tabs
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.05,
                vertical: sh * 0.015,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildFilterChip(sw, sh, 'All', notifications.length),
                  SizedBox(width: sw * 0.03),
                  _buildFilterChip(sw, sh, 'Unread', unreadCount),
                  SizedBox(width: sw * 0.03),
                  _buildFilterChip(
                    sw,
                    sh,
                    'Read',
                    notifications.length - unreadCount,
                  ),
                ],
              ),
            ),
        
            // Notifications List
            Expanded(
              child: filteredNotifications.isEmpty
                  ? _buildEmptyState(sw, sh)
                  : ListView.builder(
                      padding: EdgeInsets.all(sw * 0.05),
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = filteredNotifications[index];
                        return NotificationCard(
                          sw: sw,
                          sh: sh,
                          type: notification['type'],
                          title: notification['title'],
                          message: notification['message'],
                          time: notification['time'],
                          isRead: notification['isRead'],
                          onTap: () {
                            setState(() {
                              notification['isRead'] = true;
                            });
                            // Handle notification tap - navigate to relevant screen
                          },
                          onDismiss: () {
                            final originalIndex = notifications.indexOf(notification);
                            _deleteNotification(originalIndex);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(double sw, double sh, String label, int count) {
    final isSelected = selectedFilter == label;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sh * 0.01,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mainColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(sw * 0.05),
          border: Border.all(
            color: isSelected ? AppColors.darkPink : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.033,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.darkPink : Colors.grey.shade700,
              ),
            ),
            SizedBox(width: sw * 0.015),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.02,
                vertical: sh * 0.002,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.darkPink
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(sw * 0.03),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(double sw, double sh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: sw * 0.2,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: sh * 0.02),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: sw * 0.045,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: sh * 0.01),
          Text(
            selectedFilter == 'Unread'
                ? 'You\'re all caught up!'
                : 'No notifications to show',
            style: TextStyle(
              fontSize: sw * 0.035,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}