import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class OrderHistoryCard extends StatelessWidget {
  final String id;
  final String dateText;
  final String statusText;
  final Color statusColor;
  final String itemsText;
  final String totalText;
  final VoidCallback onViewDetails;

  const OrderHistoryCard({
    super.key,
    required this.id,
    required this.dateText,
    required this.statusText,
    required this.statusColor,
    required this.itemsText,
    required this.totalText,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.04),
      ),
      padding: EdgeInsets.all(sw * 0.045),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: sw * 0.038,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.03,
                  vertical: sh * 0.005,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(sw * 0.02),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: sw * 0.028,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.008),
          Text(
            dateText,
            style: TextStyle(color: Colors.black45, fontSize: sw * 0.03),
          ),
          Divider(height: sh * 0.025, color: Colors.black12),
          Text(
            itemsText,
            style: TextStyle(color: Colors.black54, fontSize: sw * 0.033),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: sh * 0.012),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: $totalText',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: sw * 0.038,
                  color: AppColors.darkPink,
                ),
              ),
              TextButton(
                onPressed: onViewDetails,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View Details →',
                  style: TextStyle(
                    color: AppColors.darkPink,
                    fontSize: sw * 0.03,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}