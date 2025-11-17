import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

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
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: sh * 0.01),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(sw, sh, Icons.home, 'Home', 0),
            _buildNavItem(sw, sh, Icons.shopping_bag_outlined, 'Shop', 1),
            _buildNavItem(sw, sh, Icons.pets, 'My Pets', 2),
            _buildNavItem(sw, sh, Icons.person_outline, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(double sw, double sh, IconData icon, String label, int index) {
    final isSelected = widget.currentIndex == index;
    return GestureDetector(
      onTap: () {
        widget.onTap(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: sw * 0.07,
            color: isSelected ? AppColors.darkPink : Colors.black38,
          ),
          SizedBox(height: sh * 0.005),
          Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.03,
              color: isSelected ? AppColors.darkPink : Colors.black38,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}