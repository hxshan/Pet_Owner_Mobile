import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/services/profile_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordScreen> {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _saving = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await _profileService.changePassword(
        currentPassword: _currentCtrl.text,
        newPassword: _newCtrl.text,
      );

      if (mounted) {
        _showSnack('Password changed successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Failed: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.darkPink),
    );
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, bool show, VoidCallback onToggle) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 13.5),
      prefixIcon: const Icon(Icons.lock_outline_rounded,
          color: AppColors.darkPink, size: 20),
      suffixIcon: IconButton(
        icon: Icon(
          show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.black38,
          size: 20,
        ),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: AppColors.lightGray,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPink, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorMessage, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorMessage, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
        title: Text(
          'Change Password',
          style: TextStyle(
            fontSize: sw * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: sh * 0.02),

                    // Header Banner
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(sw * 0.05),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.mainColor.withOpacity(0.5),
                            AppColors.darkPink.withOpacity(0.35),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(sw * 0.04),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(sw * 0.03),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(sw * 0.03),
                            ),
                            child: Icon(Icons.lock_outline_rounded,
                                color: AppColors.darkPink, size: sw * 0.08),
                          ),
                          SizedBox(width: sw * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Update Password',
                                  style: TextStyle(
                                    fontSize: sw * 0.042,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: sh * 0.005),
                                Text(
                                  'Choose a strong password to keep your account safe',
                                  style: TextStyle(
                                      fontSize: sw * 0.032,
                                      color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: sh * 0.03),

                    // Current Password
                    Text(
                      'CURRENT PASSWORD',
                      style: TextStyle(
                        fontSize: sw * 0.03,
                        fontWeight: FontWeight.w700,
                        color: Colors.black45,
                        letterSpacing: 0.6,
                      ),
                    ),
                    SizedBox(height: sh * 0.012),
                    TextFormField(
                      controller: _currentCtrl,
                      obscureText: !_showCurrent,
                      decoration: _inputDecoration(
                        'Current Password',
                        _showCurrent,
                        () => setState(() => _showCurrent = !_showCurrent),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),

                    SizedBox(height: sh * 0.025),

                    // New Password
                    Text(
                      'NEW PASSWORD',
                      style: TextStyle(
                        fontSize: sw * 0.03,
                        fontWeight: FontWeight.w700,
                        color: Colors.black45,
                        letterSpacing: 0.6,
                      ),
                    ),
                    SizedBox(height: sh * 0.012),
                    TextFormField(
                      controller: _newCtrl,
                      obscureText: !_showNew,
                      decoration: _inputDecoration(
                        'New Password',
                        _showNew,
                        () => setState(() => _showNew = !_showNew),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 8) return 'Minimum 8 characters';
                        return null;
                      },
                    ),
                    SizedBox(height: sh * 0.012),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: !_showConfirm,
                      decoration: _inputDecoration(
                        'Confirm New Password',
                        _showConfirm,
                        () => setState(() => _showConfirm = !_showConfirm),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v != _newCtrl.text) return 'Passwords do not match';
                        return null;
                      },
                    ),

                    SizedBox(height: sh * 0.02),

                    // Password tip
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(sw * 0.04),
                      decoration: BoxDecoration(
                        color: AppColors.mainColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(sw * 0.03),
                        border: Border.all(
                            color: AppColors.mainColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.tips_and_updates_outlined,
                              color: AppColors.darkPink, size: sw * 0.045),
                          SizedBox(width: sw * 0.03),
                          Expanded(
                            child: Text(
                              'Use at least 8 characters with a mix of letters, numbers, and symbols for a stronger password.',
                              style: TextStyle(
                                fontSize: sw * 0.033,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: sh * 0.02),
                  ],
                ),
              ),
            ),
          ),

          // Update Button
          Container(
            padding: EdgeInsets.all(sw * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPink,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: Size(double.infinity, sh * 0.062),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sw * 0.03),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_rounded, size: 20),
                        SizedBox(width: sw * 0.02),
                        Text(
                          'Update Password',
                          style: TextStyle(
                            fontSize: sw * 0.042,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}