import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_pet_model.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class PetDetailsPage extends StatefulWidget {
  final AdoptionPet pet;

  const PetDetailsPage({Key? key, required this.pet}) : super(key: key);

  @override
  State<PetDetailsPage> createState() => _PetDetailsPageState();
}

class _PetDetailsPageState extends State<PetDetailsPage> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.pet.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final pet = widget.pet;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── Hero Image App Bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: sh * 0.4,
            pinned: true,
            backgroundColor: Colors.white,
            leading: CustomBackButton(
              backgroundColor: Colors.white,
              iconColor: AppColors.darkPink,
            ),
            actions: [
              // Share button
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
                  icon: Icon(
                    Icons.share,
                    color: Colors.black,
                    size: sw * 0.06,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Pet image
                  pet.primaryImage.isNotEmpty
                      ? Hero(
                          tag: 'pet_${pet.id}',
                          child: Image.network(
                            pet.primaryImage,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imageFallback(sw),
                          ),
                        )
                      : _imageFallback(sw),

                  // Match score badge (shown if came from AI recommendation)
                  if (pet.score != null && pet.score! > 0)
                    Positioned(
                      top: sw * 0.12,
                      right: sw * 0.04,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkPink,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 12.sp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${(pet.score! * 100).toStringAsFixed(0)}% Match',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
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
                    // ── Name + Favorite ────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pet.name,
                                style: TextStyle(
                                  fontSize: sw * 0.07,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: sh * 0.005),
                              Text(
                                pet.breed.isNotEmpty
                                    ? pet.breed
                                    : pet.species,
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
                            setState(() => _isFavorite = !_isFavorite);
                          },
                          child: Container(
                            padding: EdgeInsets.all(sw * 0.03),
                            decoration: BoxDecoration(
                              color: _isFavorite
                                  ? AppColors.darkPink
                                  : AppColors.lightGray,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.favorite,
                              color: _isFavorite ? Colors.white : Colors.grey,
                              size: sw * 0.07,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sh * 0.025),

                    // ── Stat Cards ─────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.cake_outlined,
                            label: 'Age',
                            value: pet.age != null
                                ? '${pet.age} yrs'
                                : 'Unknown',
                            sw: sw,
                            sh: sh,
                          ),
                        ),
                        SizedBox(width: sw * 0.03),
                        Expanded(
                          child: _buildStatCard(
                            icon: pet.gender.toLowerCase() == 'male'
                                ? Icons.male
                                : Icons.female,
                            label: 'Gender',
                            value: pet.gender,
                            sw: sw,
                            sh: sh,
                          ),
                        ),
                        SizedBox(width: sw * 0.03),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.monitor_weight_outlined,
                            label: 'Size',
                            value: pet.size.isNotEmpty ? pet.size : '—',
                            sw: sw,
                            sh: sh,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sh * 0.02),

                    // ── Trait badges ─────────────────────────────────────────
                    if (pet.goodWithKids == true ||
                        pet.goodWithPets == true ||
                        pet.energyLevel != null)
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 6.h,
                        children: [
                          if (pet.goodWithKids == true)
                            _buildBadge('Kids OK', Icons.child_care),
                          if (pet.goodWithPets == true)
                            _buildBadge('Pet-friendly', Icons.pets),
                          if (pet.energyLevel != null)
                            _buildBadge(
                              '${pet.energyLevel} Energy',
                              Icons.bolt,
                            ),
                        ],
                      ),

                    SizedBox(height: sh * 0.025),

                    // ── Location ───────────────────────────────────────────
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
                              pet.locationLabel,
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

                    // ── About Section ─────────────────────────────────────
                    _buildSectionTitle('About ${pet.name}', sw),
                    SizedBox(height: sh * 0.015),
                    _buildInfoRow('Species', pet.species, sw),
                    _buildInfoRow('Breed', pet.breed.isNotEmpty ? pet.breed : '—', sw),
                    _buildInfoRow(
                      'Adoption Fee',
                      pet.adoptionFee > 0
                          ? '\$${pet.adoptionFee.toStringAsFixed(0)}'
                          : 'Free',
                      sw,
                    ),

                    SizedBox(height: sh * 0.03),

                    // ── Description ───────────────────────────────────────
                    if (pet.description != null &&
                        pet.description!.isNotEmpty) ...[
                      _buildSectionTitle('Description', sw),
                      SizedBox(height: sh * 0.015),
                      Text(
                        pet.description!,
                        style: TextStyle(
                          fontSize: sw * 0.04,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: sh * 0.03),
                    ],

                    // ── Medical Details ───────────────────────────────────
                    _buildSectionTitle('Medical Details', sw),
                    SizedBox(height: sh * 0.015),
                    Container(
                      padding: EdgeInsets.all(sw * 0.04),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(sw * 0.04),
                        border: Border.all(color: Colors.grey.shade300),
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
                                  borderRadius:
                                      BorderRadius.circular(sw * 0.02),
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
                                      'Managed by adoption center',
                                      style: TextStyle(
                                        fontSize: sw * 0.035,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: sh * 0.04),

                    // ── Action Buttons ────────────────────────────────────
                    Row(
                      children: [
                        // Save button
                        Expanded(
                          child: SizedBox(
                            height: sh * 0.065,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() => _isFavorite = !_isFavorite);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _isFavorite
                                          ? 'Pet saved!'
                                          : 'Removed from saved',
                                    ),
                                    backgroundColor: AppColors.darkPink,
                                  ),
                                );
                              },
                              icon: Icon(
                                _isFavorite
                                    ? Icons.bookmark
                                    : Icons.bookmark_outline,
                                size: sw * 0.05,
                              ),
                              label: Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: sw * 0.04,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.darkPink,
                                side: BorderSide(
                                  color: AppColors.darkPink,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(sw * 0.03),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: sw * 0.03),

                        // Apply for Adoption button
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: sh * 0.065,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.pushNamed(
                                  'AdoptionApplyPage',
                                  extra: pet,
                                );
                              },
                              icon: Icon(Icons.favorite, size: sw * 0.05),
                              label: Text(
                                'Apply for Adoption',
                                style: TextStyle(
                                  fontSize: sw * 0.038,
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

  Widget _imageFallback(double sw) {
    return Container(
      color: AppColors.lightGray,
      child: Icon(Icons.pets, size: sw * 0.2, color: AppColors.mainColor),
    );
  }

  Widget _buildBadge(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.mainColor.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: AppColors.darkPink),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.darkPink,
              fontWeight: FontWeight.w500,
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
            style: TextStyle(fontSize: sw * 0.03, color: Colors.black54),
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
            style: TextStyle(fontSize: sw * 0.04, color: Colors.black54),
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
}
