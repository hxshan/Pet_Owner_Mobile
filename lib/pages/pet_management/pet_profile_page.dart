import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/pet_management/Appointment_card.dart';
import 'package:pet_owner_mobile/widgets/pet_management/Vaccination_card.dart';
import 'package:pet_owner_mobile/widgets/pet_management/medical_report_card.dart';

class PetProfileScreen extends StatelessWidget {
  const PetProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Pet Info
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.mainColor.withOpacity(0.3),
                    AppColors.mainColor.withOpacity(0.1),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                  child: Column(
                    children: [
                      // Back button and edit button row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: sw * 0.05,
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to edit pet screen
                            },
                            child: Icon(
                              Icons.edit,
                              size: sw * 0.055,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sh * 0.02),

                      // Pet Avatar
                      Container(
                        width: sw * 0.28,
                        height: sw * 0.28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.mainColor,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.pets,
                          size: sw * 0.15,
                          color: AppColors.mainColor,
                        ),
                      ),

                      SizedBox(height: sh * 0.015),

                      // Pet Name
                      Text(
                        'Suddu Putha',
                        style: TextStyle(
                          fontSize: sw * 0.065,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      SizedBox(height: sh * 0.005),

                      // Health Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.04,
                          vertical: sh * 0.006,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(sw * 0.04),
                          border: Border.all(color: Colors.green, width: 1),
                        ),
                        child: Text(
                          'Healthy',
                          style: TextStyle(
                            fontSize: sw * 0.03,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.025),

                      // Pet Info Grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoItem(
                            sw,
                            sh,
                            'Animal',
                            'Dog',
                            AppColors.darkPink,
                          ),
                          _buildInfoItem(
                            sw,
                            sh,
                            'Breed',
                            'German Shepard',
                            Colors.blue,
                          ),
                          _buildInfoItem(sw, sh, 'Age', '1 Year', Colors.blue),
                        ],
                      ),

                      SizedBox(height: sh * 0.015),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInfoItem(
                            sw,
                            sh,
                            'Gender',
                            'Male',
                            AppColors.darkPink,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Sections
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.05,
                vertical: sh * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upcoming Appointments Section
                  _buildSectionHeader(sw, sh, 'Upcoming Appointments', () {
                    context.pushNamed('UpcomingAppointmentsScreen');
                  }),

                  SizedBox(height: sh * 0.015),

                  appointmentCard(
                    sw,
                    sh,
                    'Annual Checkup',
                    'Dr. Sarah Johnson',
                    '25/03/2025',
                    '10:30 AM',
                    Colors.blue,
                  ),

                  SizedBox(height: sh * 0.012),

                  appointmentCard(
                    sw,
                    sh,
                    'Dental Cleaning',
                    'Dr. Mike Smith',
                    '05/04/2025',
                    '02:00 PM',
                    Colors.orange,
                  ),

                  SizedBox(height: sh * 0.03),

                  // Vaccination History Section
                  _buildSectionHeader(sw, sh, 'Vaccination History', () {
                    context.pushNamed('VaccinationsScreen');
                  }),

                  SizedBox(height: sh * 0.015),

                  vaccinationCard(
                    sw,
                    sh,
                    'Rabies Vaccine',
                    '12/02/2025',
                    'Next Due: 12/02/2026',
                    true,
                  ),

                  SizedBox(height: sh * 0.012),

                  vaccinationCard(
                    sw,
                    sh,
                    'DHPP Vaccine',
                    '15/01/2025',
                    'Next Due: 15/01/2026',
                    true,
                  ),

                  SizedBox(height: sh * 0.012),

                  vaccinationCard(
                    sw,
                    sh,
                    'Bordetella Vaccine',
                    '20/12/2024',
                    'Overdue: 20/12/2025',
                    false,
                  ),

                  SizedBox(height: sh * 0.03),

                  // Medical Reports Section
                  _buildSectionHeader(sw, sh, 'Medical Reports', () {
                    context.pushNamed('MedicalReportsScreen');
                  }),

                  SizedBox(height: sh * 0.015),

                  medicalReportCard(
                    sw,
                    sh,
                    'Blood Test Results',
                    '08/02/2025',
                    'Dr. Sarah Johnson',
                    Icons.description,
                  ),

                  SizedBox(height: sh * 0.012),

                  medicalReportCard(
                    sw,
                    sh,
                    'X-Ray Report',
                    '22/01/2025',
                    'Dr. Mike Smith',
                    Icons.assessment,
                  ),

                  SizedBox(height: sh * 0.03),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('ChatScreen');
        },
        backgroundColor: AppColors.darkPink,
        child: const Icon(
          Icons.chat_bubble,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    double sw,
    double sh,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: sw * 0.03,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: sh * 0.005),
        Text(
          value,
          style: TextStyle(
            fontSize: sw * 0.035,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    double sw,
    double sh,
    String title,
    VoidCallback onViewAll,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: sw * 0.048,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            'View All',
            style: TextStyle(
              fontSize: sw * 0.035,
              color: AppColors.darkPink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}