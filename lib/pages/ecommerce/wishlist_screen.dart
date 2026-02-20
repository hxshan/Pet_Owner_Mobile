import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final List<Map<String, dynamic>> items = [
    {
      'name': 'Pet Bed',
      'price': '\$65.00',
      'icon': Icons.bed,
      'color': Colors.teal,
    },
    {
      'name': 'Grooming Kit',
      'price': '\$34.99',
      'icon': Icons.content_cut,
      'color': Colors.pink,
    },
    {
      'name': 'Water Bowl',
      'price': '\$22.00',
      'icon': Icons.local_drink,
      'color': Colors.blue,
    },
  ];

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
          'Wishlist',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: sw * 0.045,
          ),
        ),
      ),
      body: items.isEmpty
          ? _buildEmptyState(sw, sh)
          : ListView.separated(
              padding: EdgeInsets.all(sw * 0.05),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: sh * 0.015),
              itemBuilder: (context, index) =>
                  _buildWishlistItem(items[index], index, sw, sh),
            ),
    );
  }

  Widget _buildWishlistItem(
    Map<String, dynamic> item,
    int index,
    double sw,
    double sh,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.04),
      ),
      padding: EdgeInsets.all(sw * 0.04),
      child: Row(
        children: [
          Container(
            width: sw * 0.15,
            height: sw * 0.15,
            decoration: BoxDecoration(
              color: (item['color'] as Color).withOpacity(0.15),
              borderRadius: BorderRadius.circular(sw * 0.03),
            ),
            child: Icon(
              item['icon'] as IconData,
              color: item['color'] as Color,
              size: sw * 0.07,
            ),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: sw * 0.038,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: sh * 0.005),
                Text(
                  item['price'] as String,
                  style: TextStyle(
                    color: AppColors.darkPink,
                    fontWeight: FontWeight.w600,
                    fontSize: sw * 0.035,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () => setState(() => items.removeAt(index)),
                child: Icon(
                  Icons.favorite,
                  color: AppColors.darkPink,
                  size: sw * 0.055,
                ),
              ),
              SizedBox(height: sh * 0.01),
              GestureDetector(
                onTap: () {
                  // add to cart
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.03,
                    vertical: sh * 0.006,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkPink,
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: sw * 0.028,
                      fontWeight: FontWeight.bold,
                    ),
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
          Icon(Icons.favorite_outline, size: sw * 0.2, color: Colors.black12),
          SizedBox(height: sh * 0.02),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: sw * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
