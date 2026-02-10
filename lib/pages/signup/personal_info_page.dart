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

  // Error messages
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

  // Submit form
  void validateAndSubmit() {
    setState(() {
      // Reset all errors
      firstNameError = null;
      lastNameError = null;
      nicError = null;
      phoneError = null;
      addressError = null;

      // Validate each field
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

    // Check if all fields are valid
    if (firstNameError == null &&
        lastNameError == null &&
        nicError == null &&
        phoneError == null &&
        addressError == null) {
      // For now, just print values
      print('First Name: ${firstNameController.text}');
      print('Last Name: ${lastNameController.text}');
      print('NIC: ${nicController.text}');
      print('Phone: ${phoneController.text}');
      print('Address: ${addressController.text}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All fields are valid!'),
          backgroundColor: Colors.green,
        ),
      );

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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Pink Background
            Container(
              width: sw,
              decoration: const BoxDecoration(color: AppColors.mainColor),
              padding: EdgeInsets.only(top: sh * 0.02),
              child: Column(
                children: [
                  SizedBox(height: sh * 0.04),
                  // Dog Icon
                  Image.asset(
                    'assets/dog_img.png',
                    width: sw * 0.25,
                    height: sw * 0.25,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.pets,
                        size: sw * 0.25,
                        color: Colors.blue[800],
                      );
                    },
                  ),
                  SizedBox(height: sh * 0.015),
                  // Title
                  Text(
                    'PetCareHub',
                    style: TextStyle(
                      fontSize: sw * 0.065,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: sh * 0.005),
                  // Subtitle
                  Text(
                    'Join a community of pet lovers!',
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: sh * 0.02),
                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: sw * 0.01),
                        width: sw * 0.022,
                        height: sw * 0.022,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 0 ? Colors.blue[700] : Colors.white,
                          border: Border.all(
                            color: index == 0
                                ? Colors.blue[700]!
                                : Colors.black26,
                            width: 1,
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: sh * 0.03),
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: sh * 0.03),
                  // Personal Info Header
                  Container(
                    padding: EdgeInsets.only(bottom: sh * 0.0001),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    child: Text(
                      'Personal Info',
                      style: TextStyle(
                        fontSize: sw * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  SizedBox(height: sh * 0.025),

                  // First Name Field
                  _buildTextField(
                    context,
                    'First Name',
                    sw,
                    sh,
                    firstNameController,
                    firstNameError,
                  ),
                  SizedBox(height: sh * 0.02),

                  // Last Name Field
                  _buildTextField(
                    context,
                    'Last Name',
                    sw,
                    sh,
                    lastNameController,
                    lastNameError,
                  ),
                  SizedBox(height: sh * 0.02),

                  // NIC Number Field
                  _buildTextField(
                    context,
                    'NIC Number (National Id Number)',
                    sw,
                    sh,
                    nicController,
                    nicError,
                  ),
                  SizedBox(height: sh * 0.02),

                  // Phone Number Field
                  _buildTextField(
                    context,
                    'Phone Number',
                    sw,
                    sh,
                    phoneController,
                    phoneError,
                    isNumber: true,
                  ),
                  SizedBox(height: sh * 0.02),

                  // Home Address Field
                  _buildTextField(
                    context,
                    'Home Address',
                    sw,
                    sh,
                    addressController,
                    addressError,
                  ),
                  SizedBox(height: sh * 0.04),

                  // Get Started Button
                  SizedBox(
                    width: sw,
                    child: ElevatedButton(
                      onPressed: validateAndSubmit,
                      style: AppButtonStyles.blackButton(context),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontSize: sw * 0.06,
                          fontWeight: FontWeight.w600,
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

  Widget _buildTextField(
    BuildContext context,
    String hint,
    double sw,
    double sh,
    TextEditingController controller,
    String? errorText, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: TextStyle(fontSize: sw * 0.04),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: sw * 0.04),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sh * 0.018,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null
                    ? AppColors.errorMessage
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null
                    ? AppColors.errorMessage
                    : Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null
                    ? AppColors.errorMessage
                    : AppColors.mainColor,
                width: 1.5,
              ),
            ),
          ),
        ),
        // Error message
        SizedBox(
          height: sh * 0.025,
          child: errorText != null
              ? Padding(
                  padding: EdgeInsets.only(top: sh * 0.005, left: sw * 0.01),
                  child: Text(
                    errorText,
                    style: TextStyle(
                      color: AppColors.errorMessage,
                      fontSize: sw * 0.032,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
