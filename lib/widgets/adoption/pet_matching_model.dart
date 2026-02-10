import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class AiPetMatchModal extends StatefulWidget {
  const AiPetMatchModal({Key? key}) : super(key: key);

  @override
  State<AiPetMatchModal> createState() => _AiPetMatchModalState();
}

class _AiPetMatchModalState extends State<AiPetMatchModal> {
  String? selectedSpecies;
  String? selectedGender;
  String? selectedSize;
  final TextEditingController lifestyleController = TextEditingController();

  @override
  void dispose() {
    lifestyleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24.w,
            16.h,
            24.w,
            MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              
              SizedBox(height: 20.h),

              // Title with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            "Let's find your perfect match! ",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkPink,
                            ),
                          ),
                        ),
                        Text(
                          '✨',
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Description
              Text(
                "Tell us what you're looking for and we'll use AI to find the best matches.",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),

              SizedBox(height: 24.h),

              // Species Section
              Text(
                'Species',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _buildOptionChip(
                    label: '🐕 Dog',
                    value: 'Dog',
                    groupValue: selectedSpecies,
                    onTap: () {
                      setState(() {
                        selectedSpecies = 'Dog';
                      });
                    },
                  ),
                  SizedBox(width: 12.w),
                  _buildOptionChip(
                    label: '🐈 Cat',
                    value: 'Cat',
                    groupValue: selectedSpecies,
                    onTap: () {
                      setState(() {
                        selectedSpecies = 'Cat';
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Gender Section
              Text(
                'Gender',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _buildOptionChip(
                    label: 'Male',
                    value: 'Male',
                    groupValue: selectedGender,
                    onTap: () {
                      setState(() {
                        selectedGender = 'Male';
                      });
                    },
                  ),
                  SizedBox(width: 12.w),
                  _buildOptionChip(
                    label: 'Female',
                    value: 'Female',
                    groupValue: selectedGender,
                    onTap: () {
                      setState(() {
                        selectedGender = 'Female';
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Size Section
              Text(
                'Size',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _buildOptionChip(
                    label: 'Small',
                    value: 'Small',
                    groupValue: selectedSize,
                    onTap: () {
                      setState(() {
                        selectedSize = 'Small';
                      });
                    },
                  ),
                  SizedBox(width: 12.w),
                  _buildOptionChip(
                    label: 'Medium',
                    value: 'Medium',
                    groupValue: selectedSize,
                    onTap: () {
                      setState(() {
                        selectedSize = 'Medium';
                      });
                    },
                  ),
                  SizedBox(width: 12.w),
                  _buildOptionChip(
                    label: 'Large',
                    value: 'Large',
                    groupValue: selectedSize,
                    onTap: () {
                      setState(() {
                        selectedSize = 'Large';
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Lifestyle Section
              Text(
                'Tell us about your lifestyle 💭',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: lifestyleController,
                  maxLines: 4,
                  style: TextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText:
                        "e.g., I live in a quiet apartment and work from home. I need a calm companion who enjoys cuddles...",
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13.sp,
                      height: 1.4,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.w),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Find My Match Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle AI matching logic
                    Navigator.pop(context);
                    // You can add navigation to results or show loading
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Find My Match',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Skip Button
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Skip & Browse All',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.darkPink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionChip({
    required String label,
    required String value,
    required String? groupValue,
    required VoidCallback onTap,
  }) {
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkPink : AppColors.lightGray,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.darkPink : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

// Helper function to show the modal
void showAiPetMatchModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AiPetMatchModal(),
  );
}