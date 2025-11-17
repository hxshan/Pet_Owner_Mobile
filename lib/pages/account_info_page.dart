import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/theme/button_styles.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<AccountInfoPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isTermsAccepted = false;

  // Password visibility toggles
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  // Error messages
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Email validation
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Password validation
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  // Submit form
  void validateAndSubmit() {
    setState(() {
      // Reset all errors
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;

      // Validate email
      if (emailController.text.isEmpty) {
        emailError = 'Email is required';
      } else if (!isValidEmail(emailController.text.trim())) {
        emailError = 'Please enter a valid email address';
      }

      // Validate password
      passwordError = validatePassword(passwordController.text);

      // Validate confirm password
      if (confirmPasswordController.text.isEmpty) {
        confirmPasswordError = 'Please confirm your password';
      } else if (passwordController.text != confirmPasswordController.text) {
        confirmPasswordError = 'Passwords do not match';
      }
    });

    // Check if all fields are valid
    if (emailError == null &&
        passwordError == null &&
        confirmPasswordError == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      context.pushNamed('AnimalInfoPage');
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
                  // Account Info Header
                  Container(
                    padding: EdgeInsets.only(bottom: sh * 0.0001),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    child: Text(
                      'Account Info',
                      style: TextStyle(
                        fontSize: sw * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: sh * 0.025),

                  // Email Field
                  _buildTextField(
                    context,
                    'Email',
                    sw,
                    sh,
                    emailController,
                    emailError,
                  ),
                  SizedBox(height: sh * 0.02),

                  // Password Field
                  _buildPasswordField(
                    context,
                    'Password',
                    sw,
                    sh,
                    passwordController,
                    passwordError,
                    isPasswordVisible,
                    () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                  SizedBox(height: sh * 0.02),

                  // Confirm Password Field
                  _buildPasswordField(
                    context,
                    'Confirm Password',
                    sw,
                    sh,
                    confirmPasswordController,
                    confirmPasswordError,
                    isConfirmPasswordVisible,
                    () {
                      setState(() {
                        isConfirmPasswordVisible = !isConfirmPasswordVisible;
                      });
                    },
                  ),
                  SizedBox(height: sh * 0.001),

                  // Terms & Conditions Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: isTermsAccepted,
                        activeColor: AppColors.mainColor,
                        onChanged: (value) {
                          setState(() {
                            isTermsAccepted = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: "I agree to the ",
                            style: TextStyle(
                              fontSize: sw * 0.039,
                              color: Color.fromRGBO(0, 0, 0, 1),
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: "Terms and Conditions",
                                style: TextStyle(
                                  fontSize: sw * 0.039,
                                  color: Color.fromRGBO(19, 65, 249, 1),
                                  fontWeight: FontWeight.w500,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sh * 0.04),

                  // Get Started Button
                  SizedBox(
                    width: sw,
                    child: ElevatedButton(
                      onPressed: isTermsAccepted ? validateAndSubmit : null,
                      style: AppButtonStyles.blackButton(context),
                      child: Text(
                        'Get Started',
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
    String? errorText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
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

  Widget _buildPasswordField(
    BuildContext context,
    String hint,
    double sw,
    double sh,
    TextEditingController controller,
    String? errorText,
    bool isVisible,
    VoidCallback onToggleVisibility,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: !isVisible,
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
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
                size: sw * 0.055,
              ),
              onPressed: onToggleVisibility,
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
