import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
          style: TextStyle(
            fontSize: sw * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
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
                    child: Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.darkPink,
                      size: sw * 0.08,
                    ),
                  ),
                  SizedBox(width: sw * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Privacy Matters',
                          style: TextStyle(
                            fontSize: sw * 0.042,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: sh * 0.005),
                        Text(
                          'Last updated: January 2025',
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

            SizedBox(height: sh * 0.025),

            // Quick highlights
            Text(
              'At a Glance',
              style: TextStyle(
                fontSize: sw * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: sh * 0.015),
            Row(
              children: [
                Expanded(
                  child: _HighlightCard(
                    icon: Icons.lock_outline_rounded,
                    label: 'Data Encrypted',
                    sw: sw,
                    sh: sh,
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: _HighlightCard(
                    icon: Icons.block_outlined,
                    label: 'Never Sold',
                    sw: sw,
                    sh: sh,
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: _HighlightCard(
                    icon: Icons.manage_accounts_outlined,
                    label: 'You\'re in Control',
                    sw: sw,
                    sh: sh,
                  ),
                ),
              ],
            ),

            SizedBox(height: sh * 0.03),

            Text(
              'Our Privacy Practices',
              style: TextStyle(
                fontSize: sw * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: sh * 0.015),

            _PolicySection(
              sw: sw,
              sh: sh,
              icon: Icons.person_outline_rounded,
              title: 'Information We Collect',
              body:
                  'We collect information you provide directly, such as your name, email address, and account preferences. We also collect pet-related data including species, breed, age, weight, and health details that you enter to use our features.',
            ),
            _PolicySection(
              sw: sw,
              sh: sh,
              icon: Icons.tune_outlined,
              title: 'How We Use Your Data',
              body:
                  'Your data is used to personalise your experience, generate AI nutrition plans, facilitate vet bookings, process orders from our shop, and improve the pet adoption matching process. We do not use your data for unrelated advertising.',
            ),
            _PolicySection(
              sw: sw,
              sh: sh,
              icon: Icons.share_outlined,
              title: 'Data Sharing',
              body:
                  'We do not sell your personal data to third parties. We may share necessary information with vetted service providers (e.g. vet clinics, delivery partners) solely to fulfil your requests. All third parties are contractually required to protect your data.',
            ),
            _PolicySection(
              sw: sw,
              sh: sh,
              icon: Icons.pets_outlined,
              title: 'Pet Data',
              body:
                  'Your pet profiles and health information are stored securely and used only to deliver app features such as nutrition plan generation and vet recommendations. This data is never shared without your explicit consent.',
            ),
            _PolicySection(
              sw: sw,
              sh: sh,
              icon: Icons.security_outlined,
              title: 'Data Security',
              body:
                  'We use industry-standard encryption to protect your data both in transit and at rest. Access to personal data is restricted to authorised personnel only, and we regularly review our security practices.',
            ),
            _PolicySection(
              sw: sw,
              sh: sh,
              icon: Icons.child_care_outlined,
              title: 'Children\'s Privacy',
              body:
                  'PetCare is not directed at children under the age of 13. We do not knowingly collect personal data from children. If you believe a child has provided us with personal information, please contact us immediately.',
            ),
            _PolicySection(
              sw: sw,
              sh: sh,
              icon: Icons.settings_outlined,
              title: 'Your Rights & Choices',
              body:
                  'You have the right to access, correct, or delete your personal data at any time via your account settings. You may also request a copy of your data or withdraw consent for specific data processing activities by contacting our support team.',
            ),
            _PolicySection(
              sw: sw,
              sh: sh,
              icon: Icons.update_outlined,
              title: 'Policy Updates',
              body:
                  'We may update this Privacy Policy from time to time. When we do, we will notify you through the app or via email. Continued use of PetCare after changes are posted means you accept the updated policy.',
            ),

            SizedBox(height: sh * 0.015),

            // Contact note
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(sw * 0.04),
              decoration: BoxDecoration(
                color: AppColors.mainColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(sw * 0.03),
                border: Border.all(color: AppColors.mainColor.withOpacity(0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    color: AppColors.darkPink,
                    size: sw * 0.05,
                  ),
                  SizedBox(width: sw * 0.03),
                  Expanded(
                    child: Text(
                      'For privacy-related enquiries or data requests, contact us at privacy@petcare.com',
                      style: TextStyle(
                        fontSize: sw * 0.034,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: sh * 0.04),
          ],
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double sw;
  final double sh;

  const _HighlightCard({
    required this.icon,
    required this.label,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: sh * 0.018,
        horizontal: sw * 0.02,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.03),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.025),
            decoration: BoxDecoration(
              color: AppColors.darkPink.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.darkPink, size: sw * 0.055),
          ),
          SizedBox(height: sh * 0.008),
          Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.029,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final double sw;
  final double sh;
  final IconData icon;
  final String title;
  final String body;

  const _PolicySection({
    required this.sw,
    required this.sh,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.015),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.03),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.025),
            decoration: BoxDecoration(
              color: AppColors.darkPink.withOpacity(0.12),
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Icon(icon, color: AppColors.darkPink, size: sw * 0.05),
          ),
          SizedBox(width: sw * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: sw * 0.038,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: sh * 0.007),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: sw * 0.033,
                    color: Colors.black54,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
