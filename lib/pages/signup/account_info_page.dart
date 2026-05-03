import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/auth/signup_draft.dart';
import 'package:pet_owner_mobile/services/auth.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/theme/button_styles.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<AccountInfoPage> {
  late SignupDraft personalInfo;
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isTermsAccepted = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  bool isLoading = false;
  String? apiError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    personalInfo = GoRouterState.of(context).extra as SignupDraft;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must include at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must include at least one number';
    }
    return null;
  }

  Future<void> validateAndSubmit() async {
    setState(() {
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;
      apiError = null;

      if (emailController.text.isEmpty) {
        emailError = 'Email is required';
      } else if (!isValidEmail(emailController.text.trim())) {
        emailError = 'Please enter a valid email address';
      }

      passwordError = validatePassword(passwordController.text);

      if (confirmPasswordController.text.isEmpty) {
        confirmPasswordError = 'Please confirm your password';
      } else if (passwordController.text != confirmPasswordController.text) {
        confirmPasswordError = 'Passwords do not match';
      }
    });

    if (emailError == null &&
        passwordError == null &&
        confirmPasswordError == null) {
      personalInfo.email = emailController.text.trim();
      personalInfo.password = passwordController.text;

      setState(() => isLoading = true);

      try {
        final response = await _authService.signupPetOwner(
          firstname: personalInfo.firstName,
          lastname: personalInfo.lastName,
          email: personalInfo.email!,
          password: personalInfo.password!,
          phone: personalInfo.phone,
          nicNumber: personalInfo.nicNumber,
          address: personalInfo.address,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );

        context.pushNamed('LoginPage');
      } catch (e) {
        if (!mounted) return;

        final message = e is DioException
            ? (e.response?.data?['message']?.toString() ??
               e.message ??
               'Registration failed. Please try again.')
            : 'Something went wrong. Please try again.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => isLoading = false);
      }
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
              child: Stack(
                children: [
                  // Back button top-left
                  Positioned(
                    top: 0,
                    left: sw * 0.04,
                    child: const CustomBackButton(
                      backgroundColor: Colors.white,
                      iconColor: Colors.black87,
                      showPadding: false,
                    ),
                  ),
                  // Centered content
                  SizedBox(
                    width: sw,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: sw * 0.02),
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
                        'Account Info',
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

                  _buildLabeledField(
                    label: 'Email',
                    hint: 'kamal@example.com',
                    sw: sw,
                    sh: sh,
                    controller: emailController,
                    errorText: emailError,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  _buildLabeledPasswordField(
                    label: 'Password',
                    hint: 'Min. 8 characters',
                    sw: sw,
                    sh: sh,
                    controller: passwordController,
                    errorText: passwordError,
                    isVisible: isPasswordVisible,
                    onToggle: () => setState(
                        () => isPasswordVisible = !isPasswordVisible),
                  ),

                  _buildLabeledPasswordField(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    sw: sw,
                    sh: sh,
                    controller: confirmPasswordController,
                    errorText: confirmPasswordError,
                    isVisible: isConfirmPasswordVisible,
                    onToggle: () => setState(() =>
                        isConfirmPasswordVisible = !isConfirmPasswordVisible),
                  ),

                  SizedBox(height: sh * 0.005),

                  // Terms & Conditions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: sw * 0.07,
                        height: sw * 0.07,
                        child: Checkbox(
                          value: isTermsAccepted,
                          activeColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (value) {
                            setState(() {
                              isTermsAccepted = value ?? false;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: sw * 0.02),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to the ',
                            style: TextStyle(
                              fontSize: sw * 0.036,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: TextStyle(
                                  fontSize: sw * 0.036,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
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

                  // Get Started button
                  SizedBox(
                    width: sw,
                    child: ElevatedButton(
                      onPressed: !isLoading && isTermsAccepted
                          ? validateAndSubmit
                          : null,
                      style: isLoading
                          ? AppButtonStyles.disableButton(context)
                          : AppButtonStyles.blackButton(context),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: sh * 0.002),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get Started',
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    final hasError = errorText != null;

    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.018),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: sw * 0.038, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[350], fontSize: sw * 0.036),
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
          if (hasError)
            Padding(
              padding: EdgeInsets.only(top: sh * 0.005, left: sw * 0.02),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: sw * 0.033, color: AppColors.errorMessage),
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

  Widget _buildLabeledPasswordField({
    required String label,
    required String hint,
    required double sw,
    required double sh,
    required TextEditingController controller,
    required String? errorText,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    final hasError = errorText != null;

    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.018),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          TextField(
            controller: controller,
            obscureText: !isVisible,
            style: TextStyle(fontSize: sw * 0.038, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[350], fontSize: sw * 0.036),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                size: sw * 0.048,
                color: hasError
                    ? AppColors.errorMessage.withOpacity(0.7)
                    : Colors.grey[400],
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: sw * 0.048,
                  color: Colors.grey[500],
                ),
                onPressed: onToggle,
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
          if (hasError)
            Padding(
              padding: EdgeInsets.only(top: sh * 0.005, left: sw * 0.02),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: sw * 0.033, color: AppColors.errorMessage),
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