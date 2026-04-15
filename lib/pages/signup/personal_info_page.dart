import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/auth/signup_draft.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/theme/button_styles.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<PersonalInfoPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController nicController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? firstNameError;
  String? lastNameError;
  String? nicError;
  String? phoneError;
  String? addressError;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    nicController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void validateAndSubmit() {
    setState(() {
      firstNameError = null;
      lastNameError = null;
      nicError = null;
      phoneError = null;
      addressError = null;

      if (firstNameController.text.isEmpty) {
        firstNameError = 'First name is required';
      }
      if (lastNameController.text.isEmpty) {
        lastNameError = 'Last name is required';
      }
      if (nicController.text.isEmpty) {
        nicError = 'NIC number is required';
      }
      if (phoneController.text.isEmpty) {
        phoneError = 'Phone number is required';
      }
      if (addressController.text.isEmpty) {
        addressError = 'Home address is required';
      }
    });

    if (firstNameError == null &&
        lastNameError == null &&
        nicError == null &&
        phoneError == null &&
        addressError == null) {
      final personalInfo = SignupDraft(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        nicNumber: nicController.text,
        phone: phoneController.text,
        address: addressController.text,
      );

      context.pushNamed(
        'AccountInfoPage',
        extra: personalInfo,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //  Header 
            Container(
              width: sw,
              decoration: const BoxDecoration(
                color: AppColors.mainColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.only(
                top: sh * 0.06,
                bottom: sh * 0.035,
              ),
              child: Column(
                children: [
                  // Dog Icon with soft shadow card
                  Container(
                    padding: EdgeInsets.all(sw * 0.035),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      width: sw * 0.18,
                      height: sw * 0.18,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.pets,
                        size: sw * 0.18,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  SizedBox(height: sh * 0.012),
                  Text(
                    'PawConnect',
                    style: TextStyle(
                      fontSize: sw * 0.062,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: sh * 0.004),
                  Text(
                    'Join a community of pet lovers!',
                    style: TextStyle(
                      fontSize: sw * 0.036,
                      color: Colors.black.withOpacity(0.55),
                      letterSpacing: 0.1,
                    ),
                  ),

                ],
              ),
            ),

            //  Form 
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.06,
                vertical: sh * 0.03,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: sw * 0.05,
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: sw * 0.025),
                      Text(
                        'Personal Info',
                        style: TextStyle(
                          fontSize: sw * 0.048,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),


                  SizedBox(height: sh * 0.03),

                  // Name row (First + Last side by side)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildLabeledField(
                          label: 'First Name',
                          hint: 'Kamal',
                          sw: sw,
                          sh: sh,
                          controller: firstNameController,
                          errorText: firstNameError,
                          icon: Icons.person_outline,
                        ),
                      ),
                      SizedBox(width: sw * 0.03),
                      Expanded(
                        child: _buildLabeledField(
                          label: 'Last Name',
                          hint: 'Perera',
                          sw: sw,
                          sh: sh,
                          controller: lastNameController,
                          errorText: lastNameError,
                          icon: Icons.person_outline,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: sh * 0.005),

                  _buildLabeledField(
                    label: 'NIC Number',
                    hint: '200012345678',
                    sw: sw,
                    sh: sh,
                    controller: nicController,
                    errorText: nicError,
                    icon: Icons.badge_outlined,
                  ),

                  SizedBox(height: sh * 0.005),

                  _buildLabeledField(
                    label: 'Phone Number',
                    hint: '07X XXX XXXX',
                    sw: sw,
                    sh: sh,
                    controller: phoneController,
                    errorText: phoneError,
                    icon: Icons.phone_outlined,
                    isNumber: true,
                  ),

                  SizedBox(height: sh * 0.005),

                  _buildLabeledField(
                    label: 'Home Address',
                    hint: 'No. 12, Main Street, Colombo',
                    sw: sw,
                    sh: sh,
                    controller: addressController,
                    errorText: addressError,
                    icon: Icons.home_outlined,
                  ),

                  SizedBox(height: sh * 0.045),

                  // Next button
                  SizedBox(
                    width: sw,
                    child: ElevatedButton(
                      onPressed: validateAndSubmit,
                      style: AppButtonStyles.blackButton(context),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: sh * 0.002),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Next',
                              style: TextStyle(
                                fontSize: sw * 0.048,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: sw * 0.02),
                            Icon(Icons.arrow_forward_rounded,
                                size: sw * 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: sh * 0.03),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required String hint,
    required double sw,
    required double sh,
    required TextEditingController controller,
    required String? errorText,
    required IconData icon,
    bool isNumber = false,
  }) {
    final hasError = errorText != null;

    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.018),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: EdgeInsets.only(bottom: sh * 0.006, left: sw * 0.005),
            child: Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.036,
                fontWeight: FontWeight.w600,
                color: hasError ? AppColors.errorMessage : Colors.black87,
                letterSpacing: 0.1,
              ),
            ),
          ),
          // Input
          TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: TextStyle(
              fontSize: sw * 0.038,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[350],
                fontSize: sw * 0.036,
              ),
              prefixIcon: Icon(
                icon,
                size: sw * 0.048,
                color: hasError
                    ? AppColors.errorMessage.withOpacity(0.7)
                    : Colors.grey[400],
              ),
              filled: true,
              fillColor: hasError
                  ? AppColors.errorMessage.withOpacity(0.04)
                  : Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: sh * 0.018,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? AppColors.errorMessage : Colors.grey[200]!,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? AppColors.errorMessage : Colors.grey[200]!,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? AppColors.errorMessage : Colors.blue[600]!,
                  width: 2,
                ),
              ),
            ),
          ),
          // Error message
          if (hasError)
            Padding(
              padding: EdgeInsets.only(top: sh * 0.005, left: sw * 0.02),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: sw * 0.033,
                    color: AppColors.errorMessage,
                  ),
                  SizedBox(width: sw * 0.01),
                  Text(
                    errorText,
                    style: TextStyle(
                      color: AppColors.errorMessage,
                      fontSize: sw * 0.03,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(height: sh * 0.005),
        ],
      ),
    );
  }
}