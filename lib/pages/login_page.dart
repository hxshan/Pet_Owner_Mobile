import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/auth/login_request.dart';
import 'package:pet_owner_mobile/services/auth.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/theme/button_styles.dart';
import 'package:pet_owner_mobile/utils/secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<LoginPage> {
  final TextEditingController nicController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isTermsAccepted = false;

  // Password visibility toggles
  bool isPasswordVisible = false;

  // Error messages
  String? nicError;
  String? passwordError;

  bool isLoading = false;

  @override
  void dispose() {
    nicController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Submit form
  Future<void> validateAndSubmit() async {
    setState(() {
      // Reset all errors
      nicError = null;
      passwordError = null;

      // Validate email
      if (nicController.text.isEmpty) {
        nicError = 'NIC is required';
      }

      if (passwordController.text.isEmpty) {
        passwordError = 'Password is required';
      }
    });

    // // Check if all fields are valid
    // if (nicError == null && passwordError == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Signed In successfully!'),
    //       backgroundColor: Colors.green,
    //     ),
    //   );

    //   // context.goNamed('DashboardScreen');
    // }

    try {
      setState(() {
        isLoading = true;
      });

      final request = LoginRequest(
        nic: nicController.text,
        password: passwordController.text,
      );

      final response = await AuthService().login(request);

      await SecureStorage.saveToken(response.token);
      await SecureStorage.saveData('first_name', response.user.firstname);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
        ),
      );

      context.goNamed('DashboardScreen');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: sh * 0.06,
              horizontal: sw * 0.08,
            ),
            child: Column(
              children: [
                // Form Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: sh * 0.03),
                    // Account Info Header
                    Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: sw * 0.07,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: sh * 0.025),

                    // Email Field
                    _buildTextField(
                      context,
                      'NIC Number (National Id Number)',
                      sw,
                      sh,
                      nicController,
                      nicError,
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
                    SizedBox(height: sh * 0.01),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: sw * 0.038,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.03),

                    // Get Started Button
                    SizedBox(
                      width: sw,
                      child: ElevatedButton(
                        onPressed: !isLoading ? validateAndSubmit : null,
                        style: isLoading
                            ? AppButtonStyles.disableButton(context)
                            : AppButtonStyles.blackButton(context),
                        child: isLoading
                            ? CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text(
                                'Login',
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
              ],
            ),
          ),
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
