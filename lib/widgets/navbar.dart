import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarComponent extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigationBarComponent({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavigationBarComponent> createState() =>
      _BottomNavigationBarComponentState();
}

class _BottomNavigationBarComponentState
    extends State<BottomNavigationBarComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.13),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex,
          onTap: widget.onTap,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color.fromRGBO(94, 31, 135, 1),
          unselectedItemColor: const Color.fromRGBO(34, 31, 31, 0.6),
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications, size: 28),
              label: 'Notification',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble, size: 28),
              label: 'Chat',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_rounded, size: 28),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildNotificationIcon(int unreadCount) {
  //   if (unreadCount > 0) {
  //     return Badge(
  //       label: Text(
  //         unreadCount > 99 ? '99+' : unreadCount.toString(),
  //         style: const TextStyle(
  //           color: Colors.white,
  //           fontSize: 10,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       backgroundColor: Colors.red,
  //       child: const Icon(Icons.notifications, size: 28),
  //     );
  //   }
  //   return const Icon(Icons.notifications, size: 28);
  // }

  //  Widget _buildChatIcon(UnreadMessagesProvider unreadMessagesProvider) {
  //   // Show plain chat icon until unread messages are initialized
  //   if (!unreadMessagesProvider.isInitialized) {
  //     return const Icon(Icons.chat_bubble, size: 28);
  //   }

  //   final unreadCount = unreadMessagesProvider.unreadCounts.total;

  //   if (unreadCount > 0) {
  //     return Badge(
  //       label: Text(
  //         unreadCount > 99 ? '99+' : unreadCount.toString(),
  //         style: const TextStyle(
  //           color: Colors.white,
  //           fontSize: 10,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       backgroundColor: const Color.fromARGB(255, 255, 0, 0),
  //       child: const Icon(Icons.chat_bubble, size: 28),
  //     );
  //   }
  //   return const Icon(Icons.chat_bubble, size: 28);
  // }
}
