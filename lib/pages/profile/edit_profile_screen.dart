import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/models/user_model.dart';
import 'package:pet_owner_mobile/services/profile_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfileScreen> {
  final ProfileService _profileService = ProfileService();

  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  String? _nicNumber;
  bool? _isNicVerified;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final User user = await _profileService.getPetOwnerProfile();

      _firstNameCtrl.text = user.firstname;
      _lastNameCtrl.text = user.lastname;
      _emailCtrl.text = user.email ?? '';
      _phoneCtrl.text = user.phone ?? '';
      _addressCtrl.text = user.address ?? '';

      _nicNumber = user.nicNumber;
      _isNicVerified = user.isNicVerified;
    } catch (e) {
      if (mounted) {
        _showSnack('Failed to load profile: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await _profileService.updatePetOwnerProfile(
        firstname: _firstNameCtrl.text.trim(),
        lastname: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );

      if (mounted) {
        _showSnack('Profile updated successfully');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Update failed: $e');
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
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 13.5),
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.darkPink, size: 20)
          : null,
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
          'Edit Profile',
          style: TextStyle(
            fontSize: sw * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.darkPink),
            )
          : Column(
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
                                    borderRadius: BorderRadius.circular(
                                      sw * 0.03,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person_outline_rounded,
                                    color: AppColors.darkPink,
                                    size: sw * 0.08,
                                  ),
                                ),
                                SizedBox(width: sw * 0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your Information',
                                        style: TextStyle(
                                          fontSize: sw * 0.042,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: sh * 0.005),
                                      Text(
                                        'Update your personal details below',
                                        style: TextStyle(
                                          fontSize: sw * 0.032,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: sh * 0.03),

                          // NIC section (read-only)
                          if (_nicNumber != null && _nicNumber!.isNotEmpty) ...[
                            Text(
                              'IDENTITY',
                              style: TextStyle(
                                fontSize: sw * 0.03,
                                fontWeight: FontWeight.w700,
                                color: Colors.black45,
                                letterSpacing: 0.6,
                              ),
                            ),
                            SizedBox(height: sh * 0.012),
                            Container(
                              padding: EdgeInsets.all(sw * 0.04),
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(sw * 0.03),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(sw * 0.025),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkPink.withOpacity(
                                        0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        sw * 0.02,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.badge_outlined,
                                      color: AppColors.darkPink,
                                      size: sw * 0.05,
                                    ),
                                  ),
                                  SizedBox(width: sw * 0.035),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'NIC Number',
                                          style: TextStyle(
                                            fontSize: sw * 0.031,
                                            color: Colors.black45,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: sh * 0.003),
                                        Text(
                                          _nicNumber!,
                                          style: TextStyle(
                                            fontSize: sw * 0.038,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Container(
                                  //   padding: EdgeInsets.symmetric(
                                  //     horizontal: sw * 0.025,
                                  //     vertical: sw * 0.012,
                                  //   ),
                                  //   decoration: BoxDecoration(
                                  //     color: (_isNicVerified ?? false)
                                  //         ? Colors.green.withOpacity(0.12)
                                  //         : Colors.orange.withOpacity(0.12),
                                  //     borderRadius:
                                  //         BorderRadius.circular(sw * 0.02),
                                  //   ),
                                  //   child: Row(
                                  //     mainAxisSize: MainAxisSize.min,
                                  //     children: [
                                  //       Icon(
                                  //         (_isNicVerified ?? false)
                                  //             ? Icons.verified_rounded
                                  //             : Icons.pending_outlined,
                                  //         size: sw * 0.035,
                                  //         color: (_isNicVerified ?? false)
                                  //             ? Colors.green
                                  //             : Colors.orange,
                                  //       ),
                                  //       SizedBox(width: sw * 0.01),
                                  //       Text(
                                  //         (_isNicVerified ?? false)
                                  //             ? 'Verified'
                                  //             : 'Pending',
                                  //         style: TextStyle(
                                  //           fontSize: sw * 0.028,
                                  //           fontWeight: FontWeight.w600,
                                  //           color: (_isNicVerified ?? false)
                                  //               ? Colors.green
                                  //               : Colors.orange,
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                            SizedBox(height: sh * 0.025),
                          ],

                          // Personal Info section
                          Text(
                            'PERSONAL INFO',
                            style: TextStyle(
                              fontSize: sw * 0.03,
                              fontWeight: FontWeight.w700,
                              color: Colors.black45,
                              letterSpacing: 0.6,
                            ),
                          ),
                          SizedBox(height: sh * 0.012),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameCtrl,
                                  decoration: _inputDecoration(
                                    'First Name',
                                    icon: Icons.person_outline,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              SizedBox(width: sw * 0.03),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameCtrl,
                                  decoration: _inputDecoration(
                                    'Last Name',
                                    icon: Icons.person_outline,
                                  ),
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: sh * 0.025),

                          // Contact section
                          Text(
                            'CONTACT',
                            style: TextStyle(
                              fontSize: sw * 0.03,
                              fontWeight: FontWeight.w700,
                              color: Colors.black45,
                              letterSpacing: 0.6,
                            ),
                          ),
                          SizedBox(height: sh * 0.012),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              'Email Address',
                              icon: Icons.email_outlined,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              if (!v.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: sh * 0.012),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                              'Phone Number',
                              icon: Icons.phone_outlined,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          SizedBox(height: sh * 0.012),
                          TextFormField(
                            controller: _addressCtrl,
                            maxLines: 2,
                            decoration: _inputDecoration(
                              'Address',
                              icon: Icons.location_on_outlined,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),

                          SizedBox(height: sh * 0.02),
                        ],
                      ),
                    ),
                  ),
                ),

                // Save Button
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
                    onPressed: _saving ? null : _save,
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
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_rounded, size: 20),
                              SizedBox(width: sw * 0.02),
                              Text(
                                'Save Changes',
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
