import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_pet_model.dart';
import 'package:pet_owner_mobile/services/pet_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/pet_management/Appointment_card.dart';
import 'package:pet_owner_mobile/widgets/pet_management/Vaccination_card.dart';
import 'package:pet_owner_mobile/widgets/pet_management/medical_report_card.dart';

class PetProfileScreen extends StatefulWidget {
  final String petId;

  const PetProfileScreen({Key? key, required this.petId}) : super(key: key);

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  late Future<Map<String, dynamic>> _petFuture;

  @override
  void initState() {
    super.initState();
    _petFuture = PetService().getPetById(widget.petId);
  }

  String ageFromDob(String dob) {
    final birth = DateTime.parse(dob);
    final now = DateTime.now();
    return '${now.year - birth.year} Years';
  }

  Future<void> deletePet() async {
    try {
      await PetService().deletePet(widget.petId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pet deleted successfully')));
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while deleting pet')),
      );
    }
  }
    

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _petFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading pet'));
          }

          final pet = snapshot.data!;

          return SingleChildScrollView(
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
                              CustomBackButton(showPadding: false,),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Navigate to edit pet screen
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      size: sw * 0.06,
                                      color: Colors.black87,
                                    ),
                                  ),

                                  SizedBox(width: sw * 0.1),

                                  GestureDetector(
                                    onTap: () {
                                      deletePet();
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      size: sw * 0.07,
                                      color: const Color.fromARGB(
                                        221,
                                        206,
                                        27,
                                        27,
                                      ),
                                    ),
                                  ),
                                ],
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
                            pet['name'] ?? 'Unnamed Pet',
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
                              pet['healthStatus'] ?? 'Unknown',
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
                                pet['species'] ?? 'Unknown',
                                AppColors.darkPink,
                              ),
                              _buildInfoItem(
                                sw,
                                sh,
                                'Breed',
                                pet['breed'] ?? 'Unknown',
                                Colors.blue,
                              ),
                              _buildInfoItem(
                                sw,
                                sh,
                                'Age',
                                ageFromDob(pet['dob']),
                                Colors.blue,
                              ),
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
                                pet['gender'] ?? 'Unknown',
                                AppColors.darkPink,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Symptom Checker CTA
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sh * 0.015),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to symptom checker and pass petId
                        context.push('/my-pets/symptom-checker/${widget.petId}');
                      },
                      icon: const Icon(Icons.medical_information, color: Colors.white),
                      label: const Text('Run Symptom Checker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPink,
                        padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('ChatScreen');
        },
        backgroundColor: AppColors.darkPink,
        child: const Icon(Icons.chat_bubble, color: Colors.white),
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
