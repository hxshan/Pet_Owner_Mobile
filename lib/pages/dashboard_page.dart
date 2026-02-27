import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/utils/secure_storage.dart';
import 'package:pet_owner_mobile/services/pet_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String firstName;
  final PetService _petService = PetService();
  bool _loadingPets = true;
  List<Map<String, dynamic>> _myPets = [];

  @override
  initState() {
    super.initState();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await SecureStorage.getData('first_name');

    if (!mounted) return;

    setState(() {
      firstName = name ?? 'User';
    });
    _loadMyPets();
  }

  Future<void> _loadMyPets() async {
    setState(() => _loadingPets = true);
    try {
      final pets = await _petService.getMyPets();
      if (!mounted) return;
      setState(() {
        _myPets = pets;
        _loadingPets = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingPets = false);
      // silently fail; the UI will show empty state
    }
  }

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
              'Hello, $firstName!',
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
                  style: TextStyle(fontSize: sw * 0.035, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => {context.pushNamed('NotificationsScreen')},
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
          child: _loadingPets
              ? Center(child: CircularProgressIndicator())
              : _myPets.isEmpty
                  ? _buildNoPetsCard(sw, sh)
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // show only first 2 pets
                        for (var i = 0; i < (_myPets.length > 2 ? 2 : _myPets.length); i++)
                          Padding(
                            padding: EdgeInsets.only(right: sw * 0.04),
                            child: _buildPetCard(
                              sw,
                              sh,
                              _myPets[i]['name'] ?? 'Pet',
                              _myPets[i]['breed'] ?? _myPets[i]['species'] ?? '',
                              _formatPetAge(_myPets[i]),
                              i == 0 ? Colors.amber[100]! : Colors.purple[100]!,
                            ),
                          ),
                        // show AddPetCard only when user has less than 2 pets
                        if (_myPets.length < 2) ...[
                          SizedBox(width: sw * 0.02),
                          _buildAddPetCard(sw, sh),
                        ],
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildPetCard(
    double sw,
    double sh,
    String name,
    String breed,
    String age,
    Color bgColor,
  ) {
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
            child: Icon(Icons.pets, size: sw * 0.08, color: Colors.grey[400]),
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
            style: TextStyle(fontSize: sw * 0.032, color: Colors.black54),
          ),
          SizedBox(height: sh * 0.002),
          Text(
            age,
            style: TextStyle(fontSize: sw * 0.03, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  String _formatPetAge(Map<String, dynamic> pet) {
    try {
      if (pet.containsKey('dob') && pet['dob'] != null) {
        final dob = DateTime.parse(pet['dob']);
        final now = DateTime.now();
        int years = now.year - dob.year;
        final monthDiff = now.month - dob.month;
        if (monthDiff < 0 || (monthDiff == 0 && now.day < dob.day)) years--;
        return years > 0 ? '$years years old' : 'Young';
      }
      if (pet.containsKey('age') && pet['age'] != null) {
        return pet['age'].toString();
      }
    } catch (e) {
      // fallthrough
    }
    return '';
  }

  Widget _buildNoPetsCard(double sw, double sh) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.mainColor.withOpacity(0.06), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No pets yet',
                  style: TextStyle(
                    fontSize: sw * 0.046,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: sh * 0.01),
                Text(
                  'Add your first pet to start tracking health records and appointments.',
                  style: TextStyle(fontSize: sw * 0.034, color: Colors.black54),
                ),
                SizedBox(height: sh * 0.02),
                ElevatedButton(
                  onPressed: () async {
                    await context.pushNamed('AddPetScreen');
                    await _loadMyPets();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.02)),
                  ),
                  child: Text('Add a pet'),
                ),
              ],
            ),
          ),
          SizedBox(width: sw * 0.03),
          Container(
            width: sw * 0.28,
            height: sw * 0.28,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(sw * 0.03),
            ),
            child: Icon(Icons.pets, size: sw * 0.15, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPetCard(double sw, double sh) {
    return GestureDetector(
      onTap: () async {
        // Navigate to Add Pet screen and refresh pets when returning
        await context.pushNamed('AddPetScreen');
        await _loadMyPets();
      },
      child: Container(
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
              child: Icon(Icons.add, color: Colors.white, size: sw * 0.07),
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
                  style: TextStyle(fontSize: sw * 0.032, color: Colors.white70),
                ),
                Text(
                  'Care at Your Fingertip',
                  style: TextStyle(fontSize: sw * 0.032, color: Colors.white70),
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
            child: Icon(Icons.pets, size: sw * 0.15, color: Colors.white),
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
            // TextButton(
            //   onPressed: () {},
            //   child: Text(
            //     'View all',
            //     style: TextStyle(
            //       fontSize: sw * 0.038,
            //       color: AppColors.darkPink,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
          ],
        ),
        SizedBox(height: sh * 0.015),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: sw * 0.03,
          mainAxisSpacing: sh * 0.02,
          childAspectRatio: 0.85, 
          children: [
            _buildServiceItem(
              sw,
              sh,
              Icons.pets,
              'Adoption',
              AppColors.mainColor,
              'PetListingDashboard',
            ),
            _buildServiceItem(
              sw,
              sh,
              Icons.shopping_bag,
              'Shop',
              AppColors.mainColor,
              'EcommerceDashboardScreen',
            ),
            _buildServiceItem(
              sw,
              sh,
              Icons.restaurant,
              'Nutrition',
              Colors.orange,
              'NutritionPlanScreen',
            ),
            _buildServiceItem(
              sw,
              sh,
              Icons.local_hospital,
              'Vet Care',
              Colors.red[400]!,
              'VetHomeScreen',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceItem(
    double sw,
    double sh,
    IconData icon,
    String label,
    Color color,
    String route,
  ) {
    return GestureDetector(
      onTap: () => {context.pushNamed(route)},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: sw * 0.15,
            height: sw * 0.15,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(sw * 0.03),
            ),
            child: Icon(icon, size: sw * 0.08, color: color),
          ),
          SizedBox(height: sh * 0.006), // Fixed: Reduced spacing
          Flexible(
            // Fixed: Wrapped text to prevent overflow
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
      ),
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
        _buildReminderCard(
          sw,
          sh,
          'Max - Vaccination',
          'Tomorrow, 10:00 AM',
          Icons.vaccines,
          Colors.blue,
        ),
        SizedBox(height: sh * 0.012),
        _buildReminderCard(
          sw,
          sh,
          'Luna - Grooming',
          'Nov 20, 2:00 PM',
          Icons.content_cut,
          Colors.pink,
        ),
      ],
    );
  }

  Widget _buildReminderCard(
    double sw,
    double sh,
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
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
            child: Icon(icon, size: sw * 0.06, color: color),
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
                  style: TextStyle(fontSize: sw * 0.033, color: Colors.black54),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: sw * 0.06, color: Colors.black38),
        ],
      ),
    );
  }
}
