import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_center_model.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_pet_model.dart';
import 'package:pet_owner_mobile/services/adoption_center_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/adoption/adoption_pet_card.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class AdoptionCenterDetailScreen extends StatefulWidget {
  final AdoptionCenter center;

  const AdoptionCenterDetailScreen({super.key, required this.center});

  @override
  State<AdoptionCenterDetailScreen> createState() =>
      _AdoptionCenterDetailScreenState();
}

class _AdoptionCenterDetailScreenState
    extends State<AdoptionCenterDetailScreen> {
  bool _isLoading = true;
  List<AdoptionPet> _pets = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCenterDetails();
  }

  Future<void> _fetchCenterDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = AdoptionCenterService();
      final details = await service.getCenterDetails(widget.center.id);
      setState(() {
        _pets = details.pets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load center details. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: sh * 0.25,
            pinned: true,
            backgroundColor: AppColors.darkPink,
            leading: CustomBackButton(
              backgroundColor: Colors.white,
              iconColor: AppColors.darkPink,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.darkPink,
                      AppColors.darkPink.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: sw * 0.05,
                    right: sw * 0.05,
                    bottom: sh * 0.025,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(sw * 0.035),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                        child: Icon(
                          Icons.home_outlined,
                          color: AppColors.darkPink,
                          size: sw * 0.08,
                        ),
                      ),
                      SizedBox(height: sh * 0.015),
                      Text(
                        widget.center.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.056,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(sw * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
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
                        Text(
                          'Contact Information',
                          style: TextStyle(
                            fontSize: sw * 0.042,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF222222),
                          ),
                        ),
                        SizedBox(height: sh * 0.018),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          text: widget.center.formattedAddress,
                          sw: sw,
                        ),
                        if (widget.center.phone.isNotEmpty) ...[
                          SizedBox(height: sh * 0.012),
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            text: widget.center.phone,
                            sw: sw,
                          ),
                        ],
                        if (widget.center.email.isNotEmpty) ...[
                          SizedBox(height: sh * 0.012),
                          _InfoRow(
                            icon: Icons.email_outlined,
                            text: widget.center.email,
                            sw: sw,
                          ),
                        ],
                        if (widget.center.distance != null) ...[
                          SizedBox(height: sh * 0.012),
                          _InfoRow(
                            icon: Icons.directions_walk_outlined,
                            text: widget.center.formattedDistance,
                            sw: sw,
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (widget.center.description?.isNotEmpty == true) ...[
                    SizedBox(height: sh * 0.018),
                    Container(
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
                          Text(
                            'About',
                            style: TextStyle(
                              fontSize: sw * 0.042,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF222222),
                            ),
                          ),
                          SizedBox(height: sh * 0.012),
                          Text(
                            widget.center.description!,
                            style: TextStyle(
                              fontSize: sw * 0.036,
                              color: const Color(0xFF555555),
                              height: 1.65,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: sh * 0.025),

                  // Available Pets Section
                  Text(
                    'Available Pets (${_pets.length})',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: sh * 0.015),

                  // Pets List
                  _isLoading
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(sw * 0.1),
                            child: CircularProgressIndicator(
                              color: AppColors.darkPink,
                            ),
                          ),
                        )
                      : _error != null
                          ? _buildErrorState(sw, sh)
                          : _pets.isEmpty
                              ? _buildNoPetsState(sw, sh)
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _pets.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: 12.h),
                                  itemBuilder: (context, index) {
                                    final pet = _pets[index];
                                    return PetCard(
                                      pet: pet,
                                      onTap: () {
                                        context.pushNamed(
                                          'PetDetailsPage',
                                          extra: pet,
                                        );
                                      },
                                    );
                                  },
                                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(sw * 0.08),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: sw * 0.15,
            color: Colors.grey[400],
          ),
          SizedBox(height: sh * 0.02),
          Text(
            _error ?? 'Failed to load pets',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: sw * 0.038,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: sh * 0.02),
          ElevatedButton(
            onPressed: _fetchCenterDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkPink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPetsState(double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(sw * 0.08),
      child: Column(
        children: [
          Icon(
            Icons.pets_outlined,
            size: sw * 0.15,
            color: Colors.grey[400],
          ),
          SizedBox(height: sh * 0.02),
          Text(
            'No pets available at the moment',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: sw * 0.038,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final double sw;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.darkPink,
          size: sw * 0.042,
        ),
        SizedBox(width: sw * 0.02),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: sw * 0.036,
              color: const Color(0xFF444444),
            ),
          ),
        ),
      ],
    );
  }
}
