import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/models/ecommerce/product_review_model.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar + name
              Row(
                children: [
                  CircleAvatar(
                    radius: sw * 0.04,
                    backgroundColor: AppColors.darkPink.withOpacity(0.15),
                    child: Text(
                      _initials(review.user?.displayName ?? 'A'),
                      style: TextStyle(
                        fontSize: sw * 0.03,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkPink,
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.025),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.user?.displayName ?? 'Anonymous',
                        style: TextStyle(
                          fontSize: sw * 0.034,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (review.createdAt != null)
                        Text(
                          _formatDate(review.createdAt!),
                          style: TextStyle(
                            fontSize: sw * 0.027,
                            color: Colors.black38,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              // Star rating
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: sw * 0.035,
                    color: index < review.rating
                        ? Colors.amber
                        : Colors.black12,
                  );
                }),
              ),
            ],
          ),
          if (review.comment.trim().isNotEmpty) ...[
            SizedBox(height: sh * 0.008),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: sw * 0.032,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],

          // Seller reply — only shown when reply text is non-empty
          if (review.reply != null && review.reply!.hasContent) ...[
            SizedBox(height: sh * 0.012),
            Container(
              padding: EdgeInsets.all(sw * 0.035),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(sw * 0.025),
                border: Border.all(
                  color: AppColors.darkPink.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accent bar
                  Container(
                    width: 3,
                    height: sw * 0.08,
                    decoration: BoxDecoration(
                      color: AppColors.darkPink,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: sw * 0.025),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              size: sw * 0.033,
                              color: AppColors.darkPink,
                            ),
                            SizedBox(width: sw * 0.015),
                            Text(
                              'Seller Reply',
                              style: TextStyle(
                                fontSize: sw * 0.03,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkPink,
                              ),
                            ),
                            if (review.reply!.repliedAt != null) ...[
                              SizedBox(width: sw * 0.02),
                              Text(
                                '• ${_formatDate(review.reply!.repliedAt!)}',
                                style: TextStyle(
                                  fontSize: sw * 0.026,
                                  color: Colors.black38,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: sh * 0.006),
                        Text(
                          review.reply!.text,
                          style: TextStyle(
                            fontSize: sw * 0.031,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'A';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
