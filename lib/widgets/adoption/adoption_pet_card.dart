// lib/widgets/adoption/adoption_pet_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_pet_model.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class PetCard extends StatefulWidget {
  final AdoptionPet pet;
  final VoidCallback? onTap;
  final Function(bool)? onFavoriteToggle;

  const PetCard({
    Key? key,
    required this.pet,
    this.onTap,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.pet.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 115.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              offset: Offset(0, 5.h),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Pet Image — with margin and inner border radius (old-style)
            Container(
              width: 100.w,
              height: 130.h,
              margin: EdgeInsets.only(
                right: 10.w,
                top: 5.h,
                bottom: 5.h,
                left: 5.w,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.r),
                child: widget.pet.primaryImage.isNotEmpty
                    ? Image.network(
                        widget.pet.primaryImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.lightGray,
                            child: Icon(
                              Icons.pets,
                              size: 40.sp,
                              color: AppColors.mainColor,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.lightGray,
                        child: Icon(
                          Icons.pets,
                          size: 40.sp,
                          color: AppColors.mainColor,
                        ),
                      ),
              ),
            ),

            // Pet Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pet Name — 18sp, w500 (old style)
                  Text(
                    widget.pet.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Age
                  if (widget.pet.age != null)
                    Text(
                      '${widget.pet.age} yrs old',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),

                  // Breed
                  Text(
                    widget.pet.breed,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 8.h),

                  // Location — pink color (old style)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.sp,
                        color: AppColors.darkPink,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          widget.pet.locationLabel,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.darkPink,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right side: adoption fee + favorite button
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Favorite button (top-right)
                Padding(
                  padding: EdgeInsets.only(right: 8.w, top: 8.h),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isFavorite = !_isFavorite);
                      widget.onFavoriteToggle?.call(_isFavorite);
                    },
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? AppColors.darkPink : Colors.grey,
                      size: 20.sp,
                    ),
                  ),
                ),

                // Adoption fee (bottom-right) — pink, old-style
                Padding(
                  padding: EdgeInsets.only(right: 8.w, bottom: 8.h),
                  child: Text(
                    widget.pet.adoptionFee == 0
                        ? 'Free'
                        : '\$${widget.pet.adoptionFee.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkPink,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
