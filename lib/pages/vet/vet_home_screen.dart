import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class VetHomeScreen extends StatefulWidget {
  const VetHomeScreen({super.key});

  @override
  State<VetHomeScreen> createState() => _VetHomeScreenState();
}

class _VetHomeScreenState extends State<VetHomeScreen> {
  // Radius options in km
  static const List<int> _radiusOptions = [5, 10, 25, 50, 100];
  int _selectedRadiusKm = 10;

  void _onFindVets() {
    context.pushNamed('VetSearchResultScreen', extra: {
      'radiusMeters': _selectedRadiusKm * 1000,
      'radiusKm': _selectedRadiusKm,
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header banner ──────────────────────────────────────────
            Container(
              width: double.infinity,
              color: AppColors.mainColor.withOpacity(0.18),
              padding: EdgeInsets.only(
                top: topPadding + sh * 0.025,
                left: sw * 0.06,
                right: sw * 0.06,
                bottom: sh * 0.024,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(sw * 0.026),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.local_hospital_outlined,
                        color: AppColors.darkPink, size: sw * 0.055),
                  ),
                  SizedBox(width: sw * 0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vet Finder',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: sw * 0.056,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        'Find and book veterinary appointments',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: sw * 0.033,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: sh * 0.024),

            // ── Search Card ────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(sw * 0.045),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(sw * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location indicator (read-only)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.04,
                        vertical: sh * 0.018,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(sw * 0.026),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.near_me_rounded,
                              color: AppColors.darkPink, size: sw * 0.048),
                          SizedBox(width: sw * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Using your current location',
                                  style: TextStyle(
                                    fontSize: sw * 0.034,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF222222),
                                  ),
                                ),
                                SizedBox(height: sh * 0.003),
                                Text(
                                  'GPS will be used to find nearby vets',
                                  style: TextStyle(
                                    fontSize: sw * 0.029,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: sh * 0.022),

                    // Radius label
                    Row(
                      children: [
                        Icon(Icons.radar_rounded,
                            color: AppColors.darkPink, size: sw * 0.042),
                        SizedBox(width: sw * 0.02),
                        Text(
                          'Search radius',
                          style: TextStyle(
                            fontSize: sw * 0.036,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.03,
                            vertical: sh * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(sw * 0.02),
                          ),
                          child: Text(
                            '$_selectedRadiusKm km',
                            style: TextStyle(
                              fontSize: sw * 0.034,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkPink,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: sh * 0.014),

                    // Radius chips
                    Wrap(
                      spacing: sw * 0.025,
                      runSpacing: sh * 0.01,
                      children: _radiusOptions.map((km) {
                        final isSelected = km == _selectedRadiusKm;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedRadiusKm = km),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.045,
                              vertical: sh * 0.011,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.darkPink
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(sw * 0.06),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.darkPink
                                    : const Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              '$km km',
                              style: TextStyle(
                                fontSize: sw * 0.034,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF666666),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: sh * 0.024),

                    // Find button
                    SizedBox(
                      width: double.infinity,
                      height: sh * 0.062,
                      child: ElevatedButton.icon(
                        onPressed: _onFindVets,
                        icon: Icon(Icons.search_rounded,
                            color: Colors.white, size: sw * 0.052),
                        label: Text(
                          'Find Vets Near Me',
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
                  ],
                ),
              ),
            ),

            SizedBox(height: sh * 0.028),

            // ── Quick Actions ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: sw * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: sh * 0.014),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
              child: _QuickActionCard(
                icon: Icons.vaccines_outlined,
                iconBgColor: Colors.blue.shade600.withOpacity(0.1),
                iconColor: Colors.blue.shade600,
                title: 'Vaccination Records',
                subtitle: 'View & manage pet vaccinations',
                onTap: () => context.pushNamed('VaccinationsScreen'),
                sw: sw,
                sh: sh,
              ),
            ),
            SizedBox(height: sh * 0.012),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
              child: _QuickActionCard(
                icon: Icons.calendar_month_outlined,
                iconBgColor: Colors.teal.shade600.withOpacity(0.1),
                iconColor: Colors.teal.shade600,
                title: 'My Appointments',
                subtitle: 'View upcoming & past visits',
                onTap: () => context.pushNamed('MyVetAppointmentScreen'),
                sw: sw,
                sh: sh,
              ),
            ),
            SizedBox(height: sh * 0.04),
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
