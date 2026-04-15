import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/auth/login_request.dart';
import 'package:pet_owner_mobile/services/auth.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/theme/button_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController nicController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  String? nicError;
  String? passwordError;

  bool isLoading = false;

  @override
  void dispose() {
    nicController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> validateAndSubmit() async {
    setState(() {
      nicError = null;
      passwordError = null;

      if (nicController.text.isEmpty) {
        nicError = 'NIC is required';
      }
      if (passwordController.text.isEmpty) {
        passwordError = 'Password is required';
      }
    });

    if (nicError != null || passwordError != null) return;

    try {
      setState(() => isLoading = true);

      final request = LoginRequest(
        nic: nicController.text,
        password: passwordController.text,
      );

      final response = await AuthService().login(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );

      context.goNamed('DashboardScreen');
    } catch (e) {
      final message = e is DioException
          ? e.error.toString()
          : 'Something went wrong';

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
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
            // 🔵 HEADER (same as register)
            Container(
              width: sw,
              decoration: const BoxDecoration(
                color: AppColors.mainColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.only(top: sh * 0.06, bottom: sh * 0.035),
              child: Column(
                children: [
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
                    ),
                  ),
                  SizedBox(height: sh * 0.004),
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: sw * 0.036,
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),

            // 🧾 FORM
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.06,
                vertical: sh * 0.03,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
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
                        'Login Info',
                        style: TextStyle(
                          fontSize: sw * 0.048,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: sh * 0.03),

                  // NIC
                  _buildLabeledField(
                    label: 'NIC Number',
                    hint: '200012345678',
                    sw: sw,
                    sh: sh,
                    controller: nicController,
                    errorText: nicError,
                    icon: Icons.badge_outlined,
                  ),

                  // Password
                  _buildPasswordField(
                    sw: sw,
                    sh: sh,
                    controller: passwordController,
                    errorText: passwordError,
                  ),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: sw * 0.034,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: sh * 0.03),

                  // Login button
                  SizedBox(
                    width: sw,
                    child: ElevatedButton(
                      onPressed: !isLoading ? validateAndSubmit : null,
                      style: isLoading
                          ? AppButtonStyles.disableButton(context)
                          : AppButtonStyles.blackButton(context),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: sh * 0.002,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sign in',
                                    style: TextStyle(
                                      fontSize: sw * 0.048,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: sw * 0.02),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: sw * 0.05,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: sh * 0.02),

                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          fontSize: sw * 0.035,
                          color: Colors.grey[600],
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.pushNamed('PersonalInfoPage');
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required double sw,
    required double sh,
    required TextEditingController controller,
    required String? errorText,
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
              'Password',
              style: TextStyle(
                fontSize: sw * 0.036,
                fontWeight: FontWeight.w600,
                color: hasError ? AppColors.errorMessage : Colors.black87,
              ),
            ),
          ),
          TextField(
            controller: controller,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: hasError ? AppColors.errorMessage : Colors.grey[400],
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
              filled: true,
              fillColor: hasError
                  ? AppColors.errorMessage.withOpacity(0.04)
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          if (hasError)
            Padding(
              padding: EdgeInsets.only(top: sh * 0.005),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: sw * 0.033,
                    color: AppColors.errorMessage,
                  ),
                  SizedBox(width: sw * 0.01),
                  Text(
                    errorText!,
                    style: TextStyle(
                      color: AppColors.errorMessage,
                      fontSize: sw * 0.03,
                    ),
                  ),
                ],
              ),
            ),
        ],
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
              ),
            ),
          ),

          // Input
          TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: TextStyle(fontSize: sw * 0.038, color: Colors.black87),
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
                    errorText!,
                    style: TextStyle(
                      color: AppColors.errorMessage,
                      fontSize: sw * 0.03,
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
