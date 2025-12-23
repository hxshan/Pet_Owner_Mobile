// lib/pages/adoption/pet_details_page.dart

import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/models/adoption/pet_model.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class PetDetailsPage extends StatefulWidget {
  final Pet pet;

  const PetDetailsPage({Key? key, required this.pet}) : super(key: key);

  @override
  State<PetDetailsPage> createState() => _PetDetailsPageState();
}

class _PetDetailsPageState extends State<PetDetailsPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.pet.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Pet Image
          SliverAppBar(
            expandedHeight: sh * 0.4,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Container(
              margin: EdgeInsets.all(sw * 0.02),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black, size: sw * 0.06),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(sw * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.share, color: Colors.black, size: sw * 0.06),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'pet_${widget.pet.name}',
                child: Image.network(
                  widget.pet.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.lightGray,
                      child: Icon(Icons.pets, size: sw * 0.2, color: AppColors.mainColor),
                    );
                  },
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sw * 0.08),
                  topRight: Radius.circular(sw * 0.08),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(sw * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pet Name and Favorite
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.pet.name,
                                style: TextStyle(
                                  fontSize: sw * 0.07,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: sh * 0.005),
                              Text(
                                widget.pet.breed,
                                style: TextStyle(
                                  fontSize: sw * 0.04,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(sw * 0.03),
                            decoration: BoxDecoration(
                              color: isFavorite
                                  ? AppColors.darkPink
                                  : AppColors.lightGray,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.favorite,
                              color: isFavorite ? Colors.white : Colors.grey,
                              size: sw * 0.07,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sh * 0.025),

                    // Quick Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.cake_outlined,
                            label: 'Age',
                            value: '${widget.pet.age} months',
                            sw: sw,
                            sh: sh,
                          ),
                        ),
                        SizedBox(width: sw * 0.03),
                        Expanded(
                          child: _buildStatCard(
                            icon: widget.pet.gender.toLowerCase() == 'male' 
                                ? Icons.male 
                                : Icons.female,
                            label: 'Gender',
                            value: widget.pet.gender,
                            sw: sw,
                            sh: sh,
                          ),
                        ),
                        SizedBox(width: sw * 0.03),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.monitor_weight_outlined,
                            label: 'Size',
                            value: 'Small',
                            sw: sw,
                            sh: sh,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sh * 0.025),

                    // Location
                    Container(
                      padding: EdgeInsets.all(sw * 0.04),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(sw * 0.03),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.darkPink,
                            size: sw * 0.06,
                          ),
                          SizedBox(width: sw * 0.03),
                          Expanded(
                            child: Text(
                              widget.pet.location,
                              style: TextStyle(
                                fontSize: sw * 0.04,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: sh * 0.03),

                    // About Section
                    _buildSectionTitle('About ${widget.pet.name}', sw),
                    SizedBox(height: sh * 0.015),
                    _buildInfoRow('Color', 'Chestnut orange', sw),
                    _buildInfoRow('Type', 'Cat', sw),
                    _buildInfoRow('Adoption Fee', '\$50', sw),
                    _buildInfoRow('Home Visit', 'Yes', sw),
                    _buildInfoRow('Contact', '+94 123 456 789', sw),
                    SizedBox(height: sh * 0.03),

                    // Requirements Section
                    _buildSectionTitle('Requirements', sw),
                    SizedBox(height: sh * 0.015),
                    Text(
                      'This is a brief space about the requirements as specified. The adopter should have a safe environment, provide regular meals, and ensure proper veterinary care.',
                      style: TextStyle(
                        fontSize: sw * 0.04,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: sh * 0.03),

                    // Description Section
                    _buildSectionTitle('Description', sw),
                    SizedBox(height: sh * 0.015),
                    Text(
                      'This is a brief space where the description about the pet and more details is placed. ${widget.pet.name} is a friendly and playful companion looking for a loving home.',
                      style: TextStyle(
                        fontSize: sw * 0.04,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: sh * 0.03),

                    // Medical Details Section
                    _buildSectionTitle('Medical Details', sw),
                    SizedBox(height: sh * 0.015),
                    
                    // Medical Records Card
                    Container(
                      padding: EdgeInsets.all(sw * 0.04),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(sw * 0.04),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(sw * 0.03),
                                decoration: BoxDecoration(
                                  color: AppColors.mainColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(sw * 0.02),
                                ),
                                child: Icon(
                                  Icons.medical_services_outlined,
                                  size: sw * 0.06,
                                  color: AppColors.darkPink,
                                ),
                              ),
                              SizedBox(width: sw * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Medical Records',
                                      style: TextStyle(
                                        fontSize: sw * 0.04,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'All vaccinations up to date',
                                      style: TextStyle(
                                        fontSize: sw * 0.035,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                                size: sw * 0.06,
                              ),
                            ],
                          ),
                          SizedBox(height: sh * 0.015),
                          Divider(color: Colors.grey.shade300),
                          SizedBox(height: sh * 0.01),
                          _buildMedicalInfoRow('Medical Name', widget.pet.name, sw),
                          SizedBox(height: sh * 0.01),
                          _buildMedicalInfoRow('Last Checkup', '15 Dec 2024', sw),
                          SizedBox(height: sh * 0.01),
                          _buildMedicalInfoRow('Vaccination Status', 'Complete', sw),
                        ],
                      ),
                    ),
                    SizedBox(height: sh * 0.04),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: sh * 0.065,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Pet saved successfully!'),
                                    backgroundColor: AppColors.darkPink,
                                  ),
                                );
                              },
                              icon: Icon(Icons.bookmark_outline, size: sw * 0.05),
                              label: Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: sw * 0.04,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.darkPink,
                                side: BorderSide(color: AppColors.darkPink, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(sw * 0.03),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: sw * 0.03),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: sh * 0.065,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Contacting pet owner...'),
                                    backgroundColor: AppColors.darkPink,
                                  ),
                                );
                              },
                              icon: Icon(Icons.phone, size: sw * 0.05),
                              label: Text(
                                'Contact Owner',
                                style: TextStyle(
                                  fontSize: sw * 0.04,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkPink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(sw * 0.03),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sh * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required double sw,
    required double sh,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: sh * 0.02, horizontal: sw * 0.02),
      decoration: BoxDecoration(
        color: AppColors.mainColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(sw * 0.03),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.darkPink, size: sw * 0.06),
          SizedBox(height: sh * 0.008),
          Text(
            value,
            style: TextStyle(
              fontSize: sw * 0.038,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.03,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double sw) {
    return Text(
      title,
      style: TextStyle(
        fontSize: sw * 0.048,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, double sw) {
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.025),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.04,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: sw * 0.04,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoRow(String label, String value, double sw) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: sw * 0.035,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: sw * 0.035,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}