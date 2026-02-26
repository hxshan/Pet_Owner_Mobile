import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
          'Help & Support',
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
                      Icons.support_agent_rounded,
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
                          'We\'re here to help!',
                          style: TextStyle(
                            fontSize: sw * 0.042,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: sh * 0.005),
                        Text(
                          'Find answers or reach out to our team',
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

            // Contact Cards
            Text(
              'Contact Us',
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
                  child: _ContactCard(
                    icon: Icons.email_outlined,
                    title: 'Email Us',
                    subtitle: 'support@petcare.com',
                    sw: sw,
                    sh: sh,
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Live Chat',
                    subtitle: 'Available 9am – 6pm',
                    sw: sw,
                    sh: sh,
                  ),
                ),
              ],
            ),

            SizedBox(height: sh * 0.03),

            // FAQ
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: sw * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: sh * 0.015),

            const _FaqItem(
              question: 'How do I add a new pet?',
              answer:
                  'Go to the Pets tab and tap the "+" button. Fill in your pet\'s name, species, breed, age, and gender, then save.',
            ),
            const _FaqItem(
              question: 'How are AI nutrition plans generated?',
              answer:
                  'Our AI analyses your pet\'s species, breed, age, weight, activity level, and any health conditions to create a personalised daily meal plan.',
            ),
            const _FaqItem(
              question: 'How do I book a vet appointment?',
              answer:
                  'Navigate to the Vet Bookings section, choose a vet near you, pick an available slot, and confirm your booking.',
            ),
            const _FaqItem(
              question: 'Can I browse and buy pet products?',
              answer:
                  'Yes! Visit the Shop tab to browse our curated pet product catalogue. Add items to your cart and checkout securely.',
            ),
            const _FaqItem(
              question: 'How does pet adoption work?',
              answer:
                  'Browse available pets in the Adoption section. Submit an interest form for a pet you love and our team will guide you through the process.',
            ),
            const _FaqItem(
              question: 'How do I update my account details?',
              answer:
                  'Go to Profile → Edit Profile to update your name, email, or password at any time.',
            ),

            SizedBox(height: sh * 0.04),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double sw;
  final double sh;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.035),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.025),
            decoration: BoxDecoration(
              color: AppColors.darkPink.withOpacity(0.12),
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Icon(icon, color: AppColors.darkPink, size: sw * 0.055),
          ),
          SizedBox(height: sh * 0.01),
          Text(
            title,
            style: TextStyle(
              fontSize: sw * 0.038,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: sh * 0.004),
          Text(
            subtitle,
            style: TextStyle(fontSize: sw * 0.03, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: sh * 0.012),
        decoration: BoxDecoration(
          color: _expanded
              ? AppColors.darkPink.withOpacity(0.05)
              : AppColors.lightGray,
          borderRadius: BorderRadius.circular(sw * 0.03),
          border: Border.all(
            color: _expanded
                ? AppColors.darkPink.withOpacity(0.35)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(sw * 0.04),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontSize: sw * 0.037,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.02),
                  Icon(
                    _expanded ? Icons.remove : Icons.add,
                    color: AppColors.darkPink,
                    size: sw * 0.045,
                  ),
                ],
              ),
            ),
            if (_expanded)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  sw * 0.04,
                  0,
                  sw * 0.04,
                  sw * 0.04,
                ),
                child: Text(
                  widget.answer,
                  style: TextStyle(
                    fontSize: sw * 0.034,
                    color: Colors.black54,
                    height: 1.6,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
