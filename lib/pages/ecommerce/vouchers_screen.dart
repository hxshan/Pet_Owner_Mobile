import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class VouchersScreen extends StatelessWidget {
  const VouchersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    final vouchers = [
      {
        'code': 'SUMMER50',
        'description': '50% off on all food items',
        'expiry': 'Expires Mar 31, 2025',
        'used': false,
      },
      {
        'code': 'NEWPET20',
        'description': '20% off your first order',
        'expiry': 'Expires Apr 15, 2025',
        'used': false,
      },
      {
        'code': 'GROOMING10',
        'description': '\$10 off grooming products',
        'expiry': 'Expired Jan 01, 2025',
        'used': true,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          'My Vouchers',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: sw * 0.045,
          ),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(sw * 0.05),
        itemCount: vouchers.length,
        separatorBuilder: (_, __) => SizedBox(height: sh * 0.015),
        itemBuilder: (context, index) => _buildVoucherCard(vouchers[index], sw, sh, context),
      ),
    );
  }

  Widget _buildVoucherCard(Map<String, dynamic> voucher, double sw, double sh, BuildContext context) {
    final isExpired = voucher['used'] as bool;

    return Opacity(
      opacity: isExpired ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: isExpired ? Colors.grey.shade100 : AppColors.lightGray,
          borderRadius: BorderRadius.circular(sw * 0.04),
          border: isExpired
              ? null
              : Border.all(color: AppColors.darkPink.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            // Left colored strip
            Container(
              width: sw * 0.015,
              height: sh * 0.13,
              decoration: BoxDecoration(
                color: isExpired ? Colors.grey : AppColors.darkPink,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sw * 0.04),
                  bottomLeft: Radius.circular(sw * 0.04),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(sw * 0.045),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.discount_outlined,
                            color: isExpired ? Colors.grey : AppColors.darkPink,
                            size: sw * 0.045),
                        SizedBox(width: sw * 0.02),
                        Text(
                          voucher['code'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: sw * 0.042,
                            color: isExpired ? Colors.grey : AppColors.darkPink,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        if (!isExpired)
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: voucher['code'] as String));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Code copied!'),
                                  backgroundColor: AppColors.darkPink,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.025, vertical: sh * 0.004),
                              decoration: BoxDecoration(
                                color: AppColors.darkPink.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(sw * 0.015),
                              ),
                              child: Text(
                                'Copy',
                                style: TextStyle(
                                  color: AppColors.darkPink,
                                  fontSize: sw * 0.028,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: sh * 0.008),
                    Text(
                      voucher['description'] as String,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: sw * 0.033,
                      ),
                    ),
                    SizedBox(height: sh * 0.006),
                    Text(
                      voucher['expiry'] as String,
                      style: TextStyle(
                        color: isExpired ? Colors.red.shade300 : Colors.black38,
                        fontSize: sw * 0.028,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}