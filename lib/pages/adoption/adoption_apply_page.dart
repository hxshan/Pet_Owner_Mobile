import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_pet_model.dart';
import 'package:pet_owner_mobile/services/adoption_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class AdoptionApplyPage extends StatefulWidget {
  final AdoptionPet pet;

  const AdoptionApplyPage({Key? key, required this.pet}) : super(key: key);

  @override
  State<AdoptionApplyPage> createState() => _AdoptionApplyPageState();
}

class _AdoptionApplyPageState extends State<AdoptionApplyPage> {
  final _formKey = GlobalKey<FormState>();
  final AdoptionService _service = AdoptionService();
  bool _isSubmitting = false;

  // ── Form values ────────────────────────────────────────────────────────────
  String _livingType = 'House';
  bool _hasChildren = false;
  bool _hasOtherPets = false;
  String _activityLevel = 'Moderate';
  String _experienceLevel = 'First-time';
  String _workSchedule = 'Full-time';

  final TextEditingController _childrenAgesCtrl = TextEditingController();
  final TextEditingController _otherPetsDetailsCtrl = TextEditingController();
  final TextEditingController _reasonCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _childrenAgesCtrl.dispose();
    _otherPetsDetailsCtrl.dispose();
    _reasonCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Parse children ages if entered
      List<int>? childrenAges;
      if (_hasChildren && _childrenAgesCtrl.text.trim().isNotEmpty) {
        childrenAges = _childrenAgesCtrl.text
            .split(',')
            .map((s) => int.tryParse(s.trim()) ?? 0)
            .where((n) => n > 0)
            .toList();
      }

      await _service.submitApplication(
        petId: widget.pet.id,
        livingType: _livingType,
        hasChildren: _hasChildren,
        hasOtherPets: _hasOtherPets,
        activityLevel: _activityLevel,
        experienceLevel: _experienceLevel,
        workSchedule: _workSchedule,
        reasonForAdoption: _reasonCtrl.text.trim(),
        additionalNotes: _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim(),
        childrenAges: childrenAges,
        otherPetsDetails: (_hasOtherPets &&
                _otherPetsDetailsCtrl.text.trim().isNotEmpty)
            ? _otherPetsDetailsCtrl.text.trim()
            : null,
      );

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().contains('401') ||
              e.toString().toLowerCase().contains('unauthorized')
          ? 'Please log in to submit an adoption application.'
          : 'Failed to submit application. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 35.r,
              backgroundColor: AppColors.mainColor.withOpacity(0.2),
              child: Icon(Icons.check, size: 40.sp, color: AppColors.darkPink),
            ),
            SizedBox(height: 16.h),
            Text(
              'Application Submitted!',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Your application for ${widget.pet.name} has been sent to the adoption center. '
              'You can track its status in My Applications.',
              style: TextStyle(fontSize: 13.sp, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // close dialog
                Navigator.of(context).pop(); // back to pet details
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'Adoption Application',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Pet summary card ─────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.mainColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: pet.primaryImage.isNotEmpty
                          ? Image.network(
                              pet.primaryImage,
                              width: 60.w,
                              height: 60.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60.w,
                                height: 60.w,
                                color: AppColors.lightGray,
                                child: Icon(
                                  Icons.pets,
                                  color: AppColors.darkPink,
                                ),
                              ),
                            )
                          : Container(
                              width: 60.w,
                              height: 60.w,
                              color: AppColors.lightGray,
                              child: Icon(
                                Icons.pets,
                                color: AppColors.darkPink,
                              ),
                            ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            pet.breed.isNotEmpty ? pet.breed : pet.species,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      pet.adoptionFee > 0
                          ? '\$${pet.adoptionFee.toStringAsFixed(0)}'
                          : 'Free',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkPink,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // ═══════════════════════════════════════════════════════════
              //  SECTION 1 — About Your Home
              // ═══════════════════════════════════════════════════════════
              _sectionTitle('About Your Home'),
              SizedBox(height: 14.h),

              _dropdownField(
                label: 'Living Situation',
                value: _livingType,
                items: ['Apartment', 'House', 'Condo', 'Farm', 'Other'],
                onChanged: (v) => setState(() => _livingType = v!),
              ),
              SizedBox(height: 14.h),

              // Has Children toggle
              _yesNoToggle(
                label: 'Do you have children?',
                value: _hasChildren,
                onChanged: (v) => setState(() => _hasChildren = v),
              ),
              if (_hasChildren) ...[
                SizedBox(height: 10.h),
                _textField(
                  controller: _childrenAgesCtrl,
                  label: "Children's ages",
                  hint: 'e.g. 5, 8, 12  (comma separated)',
                ),
              ],
              SizedBox(height: 14.h),

              // Has Other Pets toggle
              _yesNoToggle(
                label: 'Do you have other pets?',
                value: _hasOtherPets,
                onChanged: (v) => setState(() => _hasOtherPets = v),
              ),
              if (_hasOtherPets) ...[
                SizedBox(height: 10.h),
                _textField(
                  controller: _otherPetsDetailsCtrl,
                  label: 'Other pets details',
                  hint: 'e.g. 1 dog, 2 cats',
                  maxLines: 2,
                ),
              ],
              SizedBox(height: 28.h),

              // ═══════════════════════════════════════════════════════════
              //  SECTION 2 — Your Lifestyle
              // ═══════════════════════════════════════════════════════════
              _sectionTitle('Your Lifestyle'),
              SizedBox(height: 14.h),

              _chipGroup(
                label: 'Activity Level',
                options: ['Low', 'Moderate', 'High', 'Very High'],
                selected: _activityLevel,
                onSelect: (v) => setState(() => _activityLevel = v),
              ),
              SizedBox(height: 14.h),

              _chipGroup(
                label: 'Experience with Pets',
                options: ['First-time', 'Experienced', 'Expert'],
                selected: _experienceLevel,
                onSelect: (v) => setState(() => _experienceLevel = v),
              ),
              SizedBox(height: 14.h),

              _dropdownField(
                label: 'Work Schedule',
                value: _workSchedule,
                items: [
                  'Full-time',
                  'Part-time',
                  'Remote',
                  'Retired',
                  'Student',
                ],
                onChanged: (v) => setState(() => _workSchedule = v!),
              ),
              SizedBox(height: 28.h),

              // ═══════════════════════════════════════════════════════════
              //  SECTION 3 — Your Message
              // ═══════════════════════════════════════════════════════════
              _sectionTitle('Your Message'),
              SizedBox(height: 14.h),

              _textField(
                controller: _reasonCtrl,
                label: 'Why do you want to adopt ${pet.name}?',
                hint: 'Share your reasons and how you plan to care for ${pet.name}...',
                maxLines: 5,
                maxLength: 2000,
                validator: (v) {
                  if (v == null || v.trim().length < 20) {
                    return 'Please write at least 20 characters.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 14.h),

              _textField(
                controller: _notesCtrl,
                label: 'Additional Notes (optional)',
                hint: 'Anything else the adoption center should know...',
                maxLines: 3,
                maxLength: 1000,
              ),
              SizedBox(height: 32.h),

              // ── Submit button ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPink,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.darkPink.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Submitting...',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ],
                        )
                      : Text(
                          'Submit Application',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reusable form widgets ────────────────────────────────────────────────
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.darkPink,
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: Colors.black54),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: onChanged,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.darkPink),
            ),
          ),
        ),
      ],
    );
  }

  Widget _yesNoToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
          ),
        ),
        Row(
          children: ['Yes', 'No'].map((opt) {
            final isSelected = (opt == 'Yes') == value;
            return GestureDetector(
              onTap: () => onChanged(opt == 'Yes'),
              child: Container(
                margin: EdgeInsets.only(left: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.darkPink : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _chipGroup({
    required String label,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: Colors.black54),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.darkPink : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isSelected ? Colors.white : Colors.black54,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: Colors.black54),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
            filled: true,
            fillColor: AppColors.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppColors.darkPink, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            contentPadding: EdgeInsets.all(12.w),
          ),
        ),
      ],
    );
  }
}
