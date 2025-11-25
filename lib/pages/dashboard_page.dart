import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: sh * 0.02),
                _buildHeader(sw, sh),
                SizedBox(height: sh * 0.025),
                _buildMyPetsSection(sw, sh),
                SizedBox(height: sh * 0.03),
                _buildQuickAccessSection(sw, sh),
                SizedBox(height: sh * 0.03),
                _buildServicesSection(sw, sh),
                SizedBox(height: sh * 0.03),
                _buildUpcomingReminders(sw, sh),
                SizedBox(height: sh * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double sw, double sh) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Buruwa!',
              style: TextStyle(
                fontSize: sw * 0.07,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: sh * 0.005),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: sw * 0.04,
                  color: AppColors.darkPink,
                ),
                SizedBox(width: sw * 0.01),
                Text(
                  'Angoda, Sri Lanka',
                  style: TextStyle(
                    fontSize: sw * 0.035,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => {
            context.pushNamed('NotificationsScreen')
          },
          child: Container(
            padding: EdgeInsets.all(sw * 0.02),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(sw * 0.03),
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: sw * 0.07,
                  color: Colors.black87,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: sw * 0.025,
                    height: sw * 0.025,
                    decoration: const BoxDecoration(
                      color: AppColors.darkPink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyPetsSection(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Pets',
              style: TextStyle(
                fontSize: sw * 0.055,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                context.pushNamed('MyPetsScreen');
              },
              child: Text(
                'View all',
                style: TextStyle(
                  fontSize: sw * 0.038,
                  color: AppColors.darkPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.015),
        SizedBox(
          height: sh * 0.22,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildPetCard(sw, sh, 'Max', 'Golden Retriever', '3 years old', Colors.amber[100]!),
              SizedBox(width: sw * 0.04),
              _buildPetCard(sw, sh, 'Luna', 'Persian Cat', '2 years old', Colors.purple[100]!),
              SizedBox(width: sw * 0.04),
              _buildAddPetCard(sw, sh),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPetCard(double sw, double sh, String name, String breed, String age, Color bgColor) {
    return Container(
      width: sw * 0.42,
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: sw * 0.15,
            height: sw * 0.15,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets,
              size: sw * 0.08,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: sh * 0.015),
          Text(
            name,
            style: TextStyle(
              fontSize: sw * 0.048,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: sh * 0.005),
          Text(
            breed,
            style: TextStyle(
              fontSize: sw * 0.032,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: sh * 0.002),
          Text(
            age,
            style: TextStyle(
              fontSize: sw * 0.03,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPetCard(double sw, double sh) {
    return Container(
      width: sw * 0.42,
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(
          color: AppColors.mainColor,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: sw * 0.12,
            height: sw * 0.12,
            decoration: BoxDecoration(
              color: AppColors.mainColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: sw * 0.07,
            ),
          ),
          SizedBox(height: sh * 0.015),
          Text(
            'Add Pet',
            style: TextStyle(
              fontSize: sw * 0.04,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkPink, AppColors.mainColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.mainColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR SOLUTION,',
                  style: TextStyle(
                    fontSize: sw * 0.032,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'ONE TAP AWAY!',
                  style: TextStyle(
                    fontSize: sw * 0.048,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: sh * 0.008),
                Text(
                  'Everything Pet & Reliable',
                  style: TextStyle(
                    fontSize: sw * 0.032,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'Care at Your Fingertip',
                  style: TextStyle(
                    fontSize: sw * 0.032,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: sh * 0.015),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.darkPink,
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.06,
                      vertical: sh * 0.012,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.02),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: sw * 0.03),
          Container(
            width: sw * 0.28,
            height: sw * 0.28,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(sw * 0.03),
            ),
            child: Icon(
              Icons.pets,
              size: sw * 0.15,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Services',
              style: TextStyle(
                fontSize: sw * 0.055,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View all',
                style: TextStyle(
                  fontSize: sw * 0.038,
                  color: AppColors.darkPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.015),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: sw * 0.03,
          mainAxisSpacing: sh * 0.02,
          childAspectRatio: 0.85, // Fixed: Adjusted ratio to prevent overflow
          children: [
            _buildServiceItem(sw, sh, Icons.pets, 'Adoption', AppColors.mainColor),
            _buildServiceItem(sw, sh, Icons.shopping_bag, 'Shop', AppColors.mainColor),
            _buildServiceItem(sw, sh, Icons.restaurant, 'Nutrition', Colors.orange),
            _buildServiceItem(sw, sh, Icons.local_hospital, 'Vet Care', Colors.red[400]!),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceItem(double sw, double sh, IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Fixed: Prevents overflow
      children: [
        Container(
          width: sw * 0.15,
          height: sw * 0.15,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(sw * 0.03),
          ),
          child: Icon(
            icon,
            size: sw * 0.08,
            color: color,
          ),
        ),
        SizedBox(height: sh * 0.006), // Fixed: Reduced spacing
        Flexible( // Fixed: Wrapped text to prevent overflow
          child: Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.03,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingReminders(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Reminders',
          style: TextStyle(
            fontSize: sw * 0.055,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: sh * 0.015),
        _buildReminderCard(sw, sh, 'Max - Vaccination', 'Tomorrow, 10:00 AM', Icons.vaccines, Colors.blue),
        SizedBox(height: sh * 0.012),
        _buildReminderCard(sw, sh, 'Luna - Grooming', 'Nov 20, 2:00 PM', Icons.content_cut, Colors.pink),
      ],
    );
  }

  Widget _buildReminderCard(double sw, double sh, String title, String time, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: sw * 0.12,
            height: sw * 0.12,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(sw * 0.025),
            ),
            child: Icon(
              icon,
              size: sw * 0.06,
              color: color,
            ),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: sw * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: sh * 0.003),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: sw * 0.033,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: sw * 0.06,
            color: Colors.black38,
          ),
        ],
      ),
    );
  }
}