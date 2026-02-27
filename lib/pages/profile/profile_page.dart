import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/user_model.dart';
import 'package:pet_owner_mobile/services/auth.dart';
import 'package:pet_owner_mobile/services/profile_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  bool _isLoggingOut = false;
  String userName = 'User';
  String userEmail = 'user@email.com';
  int _activePets = 0;
  int _totalAppointments = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final User user = await _profileService.getPetOwnerProfile();

      setState(() {
        userName = "${user.firstname} ${user.lastname}";
        userEmail = user.email ?? 'user@email.com';
        _activePets = user.numberOfActivePets ?? 0;
        _totalAppointments = user.numberOfAppointments ?? 0;
      });
    } catch (e) {
      if (mounted) {
        _showSnack('Failed to load profile: $e');
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.darkPink),
    );
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
            // Header Section with Profile Info
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.mainColor.withOpacity(0.3),
                    AppColors.mainColor.withOpacity(0.1),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.05,
                    vertical: sh * 0.01,
                  ),
                  child: Column(
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: sw * 0.05,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      SizedBox(height: sh * 0.02),

                      // Profile Avatar
                      Stack(
                        children: [
                          Container(
                            width: sw * 0.28,
                            height: sw * 0.28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.mainColor,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person,
                              size: sw * 0.15,
                              color: AppColors.mainColor,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                // Change profile picture
                              },
                              child: Container(
                                padding: EdgeInsets.all(sw * 0.02),
                                decoration: BoxDecoration(
                                  color: AppColors.darkPink,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: sw * 0.04,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: sh * 0.015),

                      // User Name
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: sw * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      SizedBox(height: sh * 0.005),

                      // Email
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: sw * 0.035,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      SizedBox(height: sh * 0.02),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(sw, sh, _activePets.toString(), 'Pets'),
                          _buildDivider(sh),
                          _buildStatItem(sw, sh, _totalAppointments.toString(), 'Appointments'),
                          _buildDivider(sh),
                          _buildStatItem(sw, sh, '28', 'Records'),
                        ],
                      ),

                      SizedBox(height: sh * 0.02),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: sh * 0.02),

            // Menu Items
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
              child: Column(
                children: [
                  // Account Section
                  _buildSectionHeader(sw, 'Account'),

                  _buildMenuItem(
                    sw,
                    sh,
                    Icons.person_outline,
                    'Edit Profile',
                    'Update your personal information',
                    () {
                      context.pushNamed('EditProfileScreen');
                    },
                  ),

                  _buildMenuItem(
                    sw,
                    sh,
                    Icons.lock_outline,
                    'Change Password',
                    'Update your password',
                    () {
                      context.pushNamed('ChangePasswordScreen');
                    },
                  ),

                  SizedBox(height: sh * 0.02),

                  // Support Section
                  _buildSectionHeader(sw, 'Support'),

                  _buildMenuItem(
                    sw,
                    sh,
                    Icons.help_outline,
                    'Help & Support',
                    'Get help and contact us',
                    () {
                      context.pushNamed('HelpSupportScreen');
                    },
                  ),

                  _buildMenuItem(
                    sw,
                    sh,
                    Icons.description_outlined,
                    'Terms & Conditions',
                    'Read our terms of service',
                    () {
                      context.pushNamed('TermsConditionsScreen');
                    },
                  ),

                  _buildMenuItem(
                    sw,
                    sh,
                    Icons.privacy_tip_outlined,
                    'Privacy Policy',
                    'Read our privacy policy',
                    () {
                      context.pushNamed('PrivacyPolicyScreen');
                    },
                  ),

                  _buildMenuItem(
                    sw,
                    sh,
                    Icons.info_outline,
                    'About',
                    'App version 1.0.0',
                    () {
                      // Navigate to about
                    },
                  ),

                  SizedBox(height: sh * 0.03),

                  // Logout Button
                  GestureDetector(
                    onTap: () {
                      _showLogoutDialog(context, sw, sh);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                      decoration: BoxDecoration(
                        color: AppColors.errorMessage.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(sw * 0.03),
                        border: Border.all(
                          color: AppColors.errorMessage,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            color: AppColors.errorMessage,
                            size: sw * 0.05,
                          ),
                          SizedBox(width: sw * 0.02),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: sw * 0.04,
                              fontWeight: FontWeight.w600,
                              color: AppColors.errorMessage,
                            ),
                          ),
                        ],
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

  Widget _buildStatItem(double sw, double sh, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: sw * 0.055,
            fontWeight: FontWeight.bold,
            color: AppColors.darkPink,
          ),
        ),
        SizedBox(height: sh * 0.005),
        Text(
          label,
          style: TextStyle(fontSize: sw * 0.032, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDivider(double sh) {
    return Container(
      height: sh * 0.04,
      width: 1.5,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildSectionHeader(double sw, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.03),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: sw * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    double sw,
    double sh,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: sh * 0.015),
        padding: EdgeInsets.all(sw * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.03),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(sw * 0.025),
              decoration: BoxDecoration(
                color: AppColors.mainColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(sw * 0.02),
              ),
              child: Icon(icon, color: AppColors.darkPink, size: sw * 0.055),
            ),
            SizedBox(width: sw * 0.035),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: sw * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: sh * 0.003),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: sw * 0.03,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: sw * 0.04,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, double sw, double sh) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sw * 0.05),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(sw * 0.06),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(sw * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.logout, color: Colors.red, size: sw * 0.08),
                ),

                SizedBox(height: sh * 0.02),

                // Title
                Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: sw * 0.055,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: sh * 0.012),

                // Message
                Text(
                  "Are you sure you want to logout?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: sw * 0.038,
                    color: Colors.grey.shade700,
                  ),
                ),

                SizedBox(height: sh * 0.03),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: sh * 0.016),
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.02),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: sw * 0.038,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: sh * 0.016),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.02),
                          ),
                        ),
                        onPressed: _isLoggingOut
                            ? null
                            : () async {
                                setState(() => _isLoggingOut = true);

                                try {
                                  final authService = AuthService();
                                  await authService.logout();
                                  Navigator.pop(context);
                                  context.goNamed('LoginPage');
                                } catch (e) {
                                  setState(() => _isLoggingOut = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Logout failed: $e'),
                                    ),
                                  );
                                }
                              },
                        child: _isLoggingOut
                            ? SizedBox(
                                height: sw * 0.05,
                                width: sw * 0.05,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: sw * 0.038,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}