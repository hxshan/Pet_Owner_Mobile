import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class AdoptionCenterHomeScreen extends StatefulWidget {
  const AdoptionCenterHomeScreen({super.key});

  @override
  State<AdoptionCenterHomeScreen> createState() =>
      _AdoptionCenterHomeScreenState();
}

class _AdoptionCenterHomeScreenState extends State<AdoptionCenterHomeScreen> {
  final TextEditingController _locationController = TextEditingController();

  void _onSearch() {
    final query = _locationController.text.trim();
    if (query.isEmpty) return;

    context.pushNamed('AdoptionCenterSearchResultScreen', extra: query);
  }

  void _onUseCurrentLocation() {
    context.pushNamed('AdoptionCenterSearchResultScreen', extra: 'Current Location');
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
                        'Adoption Centers',
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
                        'Find shelters and adoption centers near you',
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

                        // Search for Centers button
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
                              'Search for Centers',
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

                // Info Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(sw * 0.04),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(sw * 0.045),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(sw * 0.025),
                              decoration: BoxDecoration(
                                color: AppColors.darkPink.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(sw * 0.02),
                              ),
                              child: Icon(
                                Icons.pets,
                                color: AppColors.darkPink,
                                size: sw * 0.06,
                              ),
                            ),
                            SizedBox(width: sw * 0.03),
                            Expanded(
                              child: Text(
                                'Find Your Perfect Match',
                                style: TextStyle(
                                  fontSize: sw * 0.042,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: sh * 0.015),
                        Text(
                          'Search for adoption centers and shelters in your area. Browse their available pets and submit adoption applications directly through the app.',
                          style: TextStyle(
                            fontSize: sw * 0.034,
                            color: const Color(0xFF666666),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.02),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
