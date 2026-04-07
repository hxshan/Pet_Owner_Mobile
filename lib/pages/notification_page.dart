import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/models/notification_model.dart';
import 'package:pet_owner_mobile/services/notification_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/notification_card_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String selectedFilter = 'All';

  bool isLoading = true;
  String? errorText;

  List<AppNotification> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      final list = await NotificationService.instance.fetchNotifications();
      setState(() => notifications = list);
    } catch (e) {
      setState(() => errorText = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<AppNotification> get filteredNotifications {
    if (selectedFilter == 'All') return notifications;
    if (selectedFilter == 'Unread') {
      return notifications.where((n) => !n.isRead).toList();
    }
    return notifications.where((n) => n.isRead).toList();
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> _markAllAsRead() async {
    try {
      await NotificationService.instance.markAllRead();

      setState(() {
        notifications = notifications.map((n) {
          return AppNotification(
            id: n.id,
            type: n.type,
            title: n.title,
            message: n.message,
            createdAt: n.createdAt,
            isRead: true,
            severity: n.severity,
            changes: n.changes,
          );
        }).toList();
      });
    } catch (e) {
      _showSnack(e.toString());
    }
  }

  Future<void> _markOneRead(AppNotification n) async {
    setState(() {
      notifications = notifications.map((x) {
        if (x.id == n.id) {
          return AppNotification(
            id: x.id,
            type: x.type,
            title: x.title,
            message: x.message,
            createdAt: x.createdAt,
            isRead: true,
            severity: x.severity,
            changes: x.changes,
          );
        }
        return x;
      }).toList();
    });

    try {
      await NotificationService.instance.markRead(n.id);
    } catch (e) {
      _showSnack("Failed to mark as read");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.black87),
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
        leading: CustomBackButton(),
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
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
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
              child: Builder(
                builder: (_) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (errorText != null) {
                    return Center(child: Text(errorText!));
                  }

                  if (filteredNotifications.isEmpty) {
                    return _buildEmptyState(sw, sh);
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(sw * 0.05),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final n = filteredNotifications[index];
                      return NotificationCard(
                        sw: sw,
                        sh: sh,
                        type: n.type,
                        title: n.title,
                        message: n.message,
                        time: NotificationService.instance.timeAgo(n.createdAt),
                        isRead: n.isRead,

                        severity: n.severity,
                        changes: n.changes,

                        onTap: () => _markOneRead(n),
                        onDismiss: () async {
                        
                          final removed = n;

                          setState(() {
                            notifications.removeWhere((x) => x.id == n.id);
                          });

                          
                          try {
                            await NotificationService.instance
                                .deleteNotification(n.id);
                          } catch (e) {
                            
                            setState(() {
                              notifications.insert(0, removed);
                            });

                            _showSnack("Failed to delete notification");
                          }
                        },
                      );
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
                color: isSelected ? AppColors.darkPink : Colors.grey.shade400,
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
            style: TextStyle(fontSize: sw * 0.035, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
