import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_center_model.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class AdoptionCenterCard extends StatelessWidget {
  final AdoptionCenter center;
  final VoidCallback? onTap;

  const AdoptionCenterCard({
    super.key,
    required this.center,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: EdgeInsets.all(sw * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon
                      Container(
                        padding: EdgeInsets.all(sw * 0.028),
                        decoration: BoxDecoration(
                          color: AppColors.darkPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(sw * 0.025),
                        ),
                        child: Icon(
                          Icons.home_outlined,
                          color: AppColors.darkPink,
                          size: sw * 0.052,
                        ),
                      ),
                      SizedBox(width: sw * 0.03),
                      // Name and available pets count
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              center.name,
                              style: TextStyle(
                                fontSize: sw * 0.042,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF222222),
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: sh * 0.004),
                            Row(
                              children: [
                                Icon(
                                  Icons.pets,
                                  size: sw * 0.032,
                                  color: AppColors.darkPink,
                                ),
                                SizedBox(width: sw * 0.01),
                                Text(
                                  '${center.availablePets} ${center.availablePets == 1 ? 'pet' : 'pets'} available',
                                  style: TextStyle(
                                    fontSize: sw * 0.032,
                                    color: AppColors.darkPink,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            Divider(
              height: 1,
              thickness: 1,
              color: const Color(0xFFF0F0F0),
              indent: sw * 0.04,
              endIndent: sw * 0.04,
            ),

            // Info Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: sh * 0.014,
              ),
              child: Column(
                children: [
                  // Address
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: const Color(0xFF666666),
                        size: sw * 0.038,
                      ),
                      SizedBox(width: sw * 0.015),
                      Expanded(
                        child: Text(
                          center.formattedAddress,
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: const Color(0xFF666666),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (center.phone.isNotEmpty) ...[
                    SizedBox(height: sh * 0.008),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          color: const Color(0xFF666666),
                          size: sw * 0.038,
                        ),
                        SizedBox(width: sw * 0.015),
                        Text(
                          center.phone,
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (center.distance != null) ...[
                    SizedBox(height: sh * 0.008),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_walk_outlined,
                          color: const Color(0xFF666666),
                          size: sw * 0.038,
                        ),
                        SizedBox(width: sw * 0.015),
                        Text(
                          center.formattedDistance,
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Action Button
            Padding(
              padding: EdgeInsets.only(
                left: sw * 0.04,
                right: sw * 0.04,
                bottom: sw * 0.04,
              ),
              child: SizedBox(
                width: double.infinity,
                height: sh * 0.057,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.026),
                    ),
                  ),
                  child: Text(
                    'View Pets',
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
