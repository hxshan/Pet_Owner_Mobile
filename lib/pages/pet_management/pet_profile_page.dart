import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pet_owner_mobile/models/pet_management/vaccination_model.dart';
import 'package:pet_owner_mobile/models/vet/appointment_model.dart';
import 'package:pet_owner_mobile/services/vaccination_service.dart';
import 'package:pet_owner_mobile/services/vet_service.dart';
import 'package:pet_owner_mobile/store/pet_scope.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/pet_management/Appointment_card.dart';
import 'package:pet_owner_mobile/widgets/pet_management/Vaccination_card.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class PetProfileScreen extends StatefulWidget {
  final String petId;

  const PetProfileScreen({Key? key, required this.petId}) : super(key: key);

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  late Future<Map<String, dynamic>> _petFuture;
  bool _didInit = false;

  List<AppointmentModel> _appointments = [];
  List<VaccinationModel> _vaccinations = [];
  bool _appointmentsLoading = true;
  bool _vaccinationsLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      _petFuture = PetScope.of(context).getPetDetail(widget.petId);
      _loadAppointments();
      _loadVaccinations();
    }
  }

  Future<void> _loadAppointments() async {
    try {
      final all = await VetService().fetchUpcomingAppointments();
      final filtered = all
          .where((a) => a.pet.id == widget.petId)
          .take(3)
          .toList();
      if (mounted) {
        setState(() {
          _appointments = filtered;
          _appointmentsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _appointmentsLoading = false);
    }
  }

  Future<void> _loadVaccinations() async {
    try {
      final all = await VaccinationService().fetchPetVaccinations(widget.petId);
      final top3 = all.take(3).toList();
      if (mounted) {
        setState(() {
          _vaccinations = top3;
          _vaccinationsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _vaccinationsLoading = false);
    }
  }

  void _showQrPopup(String token, Map<String, dynamic> pet) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.03),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pet['name'] ?? 'Pet',
                  style: TextStyle(fontSize: sw * 0.05, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: sh * 0.02),
                QrImageView(
                  data: token,
                  version: QrVersions.auto,
                  size: sw * 0.5,
                  gapless: false,
                ),
                SizedBox(height: sh * 0.02),
                // Text(
                //   token,
                //   style: TextStyle(fontSize: sw * 0.034, color: Colors.black54),
                //   textAlign: TextAlign.center,
                // ),
                SizedBox(height: sh * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Close', style: TextStyle(color: Colors.black87)),
                    ),
                    SizedBox(width: sw * 0.04),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await Share.share(token, subject: 'Pet Token - ${pet['name'] ?? ''}');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to share token')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Share', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String ageFromDob(String dob) {
    final birth = DateTime.parse(dob);
    final now = DateTime.now();
    return '${now.year - birth.year} Years';
  }

  Future<void> deletePet() async {
    try {
      await PetScope.of(context).deletePet(widget.petId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pet deleted successfully')));
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
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
                                    onTap: () async {
                                      final updated = await context.push(
                                        '/my-pets/editpet/${widget.petId}',
                                      );
                                      if (updated == true && mounted) {
                                        final store = PetScope.of(context);
                                        store.invalidatePetDetail(widget.petId);
                                        setState(() {
                                          _petFuture = store.getPetDetail(widget.petId);
                                        });
                                      }
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      size: sw * 0.06,
                                      color: Colors.black87,
                                    ),
                                  ),

                                  SizedBox(width: sw * 0.1),

                                  // QR Button: shows pet UUID token as QR
                                  GestureDetector(
                                    onTap: () {
                                      final token = pet['uuidToken'] ?? pet['token'] ?? pet['id']?.toString();
                                      if (token == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('No token available for this pet')),
                                        );
                                        return;
                                      }
                                      _showQrPopup(token, pet);
                                    },
                                    child: Icon(
                                      Icons.qr_code,
                                      size: sw * 0.065,
                                      color: AppColors.darkPink,
                                    ),
                                  ),

                                  SizedBox(width: sw * 0.06),

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

                      if (_appointmentsLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_appointments.isEmpty)
                        _buildEmptyState(sw, sh, 'No upcoming appointments')
                      else
                        ..._appointments.asMap().entries.map((entry) {
                          final i = entry.key;
                          final a = entry.value;
                          final dateStr = DateFormat('dd/MM/yyyy').format(a.startTime.toLocal());
                          final timeStr = DateFormat('hh:mm a').format(a.startTime.toLocal());
                          return Column(
                            children: [
                              appointmentCard(
                                sw,
                                sh,
                                a.veterinarian.specialization.isNotEmpty
                                    ? a.veterinarian.specialization
                                    : 'Vet Appointment',
                                'Dr. ${a.veterinarian.fullName}',
                                dateStr,
                                timeStr,
                                AppColors.darkPink,
                                status: a.status,
                                confirmationStatus: a.confirmationStatus,
                                petName: a.pet.name,
                                clinicName: a.veterinarian.clinic.name,
                              ),
                              if (i < _appointments.length - 1)
                                SizedBox(height: sh * 0.012),
                            ],
                          );
                        }),

                      SizedBox(height: sh * 0.03),

                      // Vaccination History Section
                      _buildSectionHeader(sw, sh, 'Vaccination History', () {
                        context.pushNamed('VaccinationsScreen');
                      }),

                      SizedBox(height: sh * 0.015),

                      if (_vaccinationsLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_vaccinations.isEmpty)
                        _buildEmptyState(sw, sh, 'No vaccinations recorded')
                      else
                        ..._vaccinations.asMap().entries.map((entry) {
                          final i = entry.key;
                          final v = entry.value;
                          return Column(
                            children: [
                              VaccinationCard(vaccination: v),
                              if (i < _vaccinations.length - 1)
                                SizedBox(height: sh * 0.012),
                            ],
                          );
                        }),

                      SizedBox(height: sh * 0.03),

                      // // Medical Reports Section
                      // _buildSectionHeader(sw, sh, 'Medical Reports', () {
                      //   context.pushNamed('MedicalReportsScreen');
                      // }),

                      // SizedBox(height: sh * 0.015),

                      // medicalReportCard(
                      //   sw,
                      //   sh,
                      //   'Blood Test Results',
                      //   '08/02/2025',
                      //   'Dr. Sarah Johnson',
                      //   Icons.description,
                      // ),

                      // SizedBox(height: sh * 0.012),

                      // medicalReportCard(
                      //   sw,
                      //   sh,
                      //   'X-Ray Report',
                      //   '22/01/2025',
                      //   'Dr. Mike Smith',
                      //   Icons.assessment,
                      // ),

                      // SizedBox(height: sh * 0.03),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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

  Widget _buildEmptyState(double sw, double sh, String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sh * 0.015),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: sw * 0.035,
            color: Colors.black45,
          ),
        ),
      ),
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
