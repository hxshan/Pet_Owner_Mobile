import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    final orders = [
      {
        'id': '#ORD-10042',
        'date': 'Feb 15, 2025',
        'status': 'Delivered',
        'statusColor': Colors.green,
        'items': 'Premium Dog Food, Water Bowl',
        'total': '\$67.99',
      },
      {
        'id': '#ORD-10038',
        'date': 'Feb 08, 2025',
        'status': 'Shipped',
        'statusColor': Colors.blue,
        'items': 'Cat Toy Set',
        'total': '\$12.99',
      },
      {
        'id': '#ORD-10031',
        'date': 'Jan 28, 2025',
        'status': 'Cancelled',
        'statusColor': Colors.red,
        'items': 'Grooming Kit',
        'total': '\$34.99',
      },
      {
        'id': '#ORD-10025',
        'date': 'Jan 10, 2025',
        'status': 'Delivered',
        'statusColor': Colors.green,
        'items': 'Pet Bed, Dog Leash',
        'total': '\$83.50',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          'Order History',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: sw * 0.045,
          ),
        ),
      ),
      body: orders.isEmpty
          ? _buildEmptyState(sw, sh)
          : ListView.separated(
              padding: EdgeInsets.all(sw * 0.05),
              itemCount: orders.length,
              separatorBuilder: (_, __) => SizedBox(height: sh * 0.015),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order, sw, sh, context);
              },
            ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, double sw, double sh, BuildContext context) {
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
                order['id'] as String,
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
                  color: (order['statusColor'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(sw * 0.02),
                ),
                child: Text(
                  order['status'] as String,
                  style: TextStyle(
                    color: order['statusColor'] as Color,
                    fontSize: sw * 0.028,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.008),
          Text(
            order['date'] as String,
            style: TextStyle(color: Colors.black45, fontSize: sw * 0.03),
          ),
          Divider(height: sh * 0.025, color: Colors.black12),
          Text(
            order['items'] as String,
            style: TextStyle(color: Colors.black54, fontSize: sw * 0.033),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: sh * 0.012),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${order['total']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: sw * 0.038,
                  color: AppColors.darkPink,
                ),
              ),
              TextButton(
                onPressed: () {
                  // navigate to order detail
                },
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

  Widget _buildEmptyState(double sw, double sh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: sw * 0.2, color: Colors.black12),
          SizedBox(height: sh * 0.02),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: sw * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
            ),
          ),
          SizedBox(height: sh * 0.01),
          Text(
            'Your order history will appear here',
            style: TextStyle(color: Colors.black38, fontSize: sw * 0.033),
          ),
        ],
      ),
    );
  }
}