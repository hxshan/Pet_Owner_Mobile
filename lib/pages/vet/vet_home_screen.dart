import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class VetHomeScreen extends StatefulWidget {
  const VetHomeScreen({super.key});

  @override
  State<VetHomeScreen> createState() => _VetHomeScreenState();
}

class _VetHomeScreenState extends State<VetHomeScreen> {
  final TextEditingController _locationController = TextEditingController();

  void _onSearch() {
    final query = _locationController.text.trim();
    if (query.isEmpty) return;

    context.pushNamed('VetSearchResultScreen', extra: query);
  }

  void _onUseCurrentLocation() {
    context.pushNamed('VetSearchResultScreen', extra: 'Current Location');
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: topPadding + sh * 0.18,
              color: AppColors.darkPink,
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: topPadding + sh * 0.025,
                    left: sw * 0.06,
                    right: sw * 0.06,
                    bottom: sh * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VetFinder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.072,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: sh * 0.005),
                      Text(
                        'Find and book veterinary appointments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.036,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(sw * 0.045),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.09),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(sw * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter your location',
                          style: TextStyle(
                            fontSize: sw * 0.036,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        SizedBox(height: sh * 0.012),

                        // Location TextField
                        TextField(
                          controller: _locationController,
                          onSubmitted: (_) => _onSearch(),
                          style: TextStyle(
                            fontSize: sw * 0.036,
                            color: const Color(0xFF333333),
                          ),
                          decoration: InputDecoration(
                            hintText: 'City, ZIP code, or address',
                            hintStyle: TextStyle(
                              color: const Color(0xFFAAAAAA),
                              fontSize: sw * 0.036,
                            ),
                            prefixIcon: Icon(
                              Icons.location_on_outlined,
                              color: const Color(0xFFAAAAAA),
                              size: sw * 0.052,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: sh * 0.018,
                              horizontal: sw * 0.04,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(sw * 0.026),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(sw * 0.026),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(sw * 0.026),
                              borderSide: const BorderSide(
                                color: AppColors.darkPink,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: sh * 0.018),

                        // Search for Vets button
                        SizedBox(
                          width: double.infinity,
                          height: sh * 0.062,
                          child: ElevatedButton.icon(
                            onPressed: _onSearch,
                            icon: Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                              size: sw * 0.052,
                            ),
                            label: Text(
                              'Search for Vets',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: sw * 0.04,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkPink,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(sw * 0.026),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: sh * 0.014),

                        // Use Current Location button
                        SizedBox(
                          width: double.infinity,
                          height: sh * 0.062,
                          child: OutlinedButton.icon(
                            onPressed: _onUseCurrentLocation,
                            icon: Icon(
                              Icons.near_me_outlined,
                              color: AppColors.darkPink,
                              size: sw * 0.052,
                            ),
                            label: Text(
                              'Use Current Location',
                              style: TextStyle(
                                color: AppColors.darkPink,
                                fontSize: sw * 0.04,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.darkPink,
                              side: const BorderSide(
                                color: AppColors.darkPink,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(sw * 0.026),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.028),

                // Quick Actions Label
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                  child: Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: sw * 0.04,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.014),

                // Vaccination Records
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                  child: _QuickActionCard(
                    icon: Icons.vaccines_outlined,
                    iconBgColor: AppColors.mainColor.withOpacity(0.5),
                    iconColor: AppColors.darkPink,
                    title: 'Vaccination Records',
                    subtitle: 'View & manage pet vaccinations',
                    onTap: () {
                      context.pushNamed('VaccinationsScreen');
                    },
                    sw: sw,
                    sh: sh,
                  ),
                ),

                SizedBox(height: sh * 0.012),

                // My Appointments
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                  child: _QuickActionCard(
                    icon: Icons.calendar_month_outlined,
                    iconBgColor: AppColors.mainColor.withOpacity(0.35),
                    iconColor: AppColors.darkPink,
                    title: 'My Appointments',
                    subtitle: 'View upcoming & past visits',
                    onTap: () {
                      context.pushNamed('MyVetAppointmentScreen');
                    },
                    sw: sw,
                    sh: sh,
                  ),
                ),

                SizedBox(height: sh * 0.04),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Action Card ──────────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double sw;
  final double sh;

  const _QuickActionCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.036),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sh * 0.016,
        ),
        child: Row(
          children: [
            Container(
              width: sw * 0.138,
              height: sw * 0.138,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: sw * 0.066),
            ),
            SizedBox(width: sw * 0.036),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF222222),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: sh * 0.004),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: sw * 0.033,
                      color: const Color(0xFF888888),
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
