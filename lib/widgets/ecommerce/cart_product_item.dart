import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class CartProductItem extends StatelessWidget {
  final Map<String, dynamic> product;
  final double sw;
  final double sh;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const CartProductItem({
    Key? key,
    required this.product,
    required this.sw,
    required this.sh,
    required this.onRemove,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color color = (product['color'] as Color?) ?? AppColors.darkPink;
    final IconData fallbackIcon =
        (product['image'] as IconData?) ?? Icons.shopping_bag_outlined;

    final String name = (product['name'] ?? '').toString();
    final double price = (product['price'] is num)
        ? (product['price'] as num).toDouble()
        : 0.0;

    final int qty = (product['quantity'] is num)
        ? (product['quantity'] as num).toInt()
        : 1;

    final String? imageUrl = product['imageUrl']?.toString();

    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.02),
      padding: EdgeInsets.all(sw * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          // Product Image (Network if available, otherwise Icon)
          Container(
            width: sw * 0.22,
            height: sw * 0.22,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            clipBehavior: Clip.antiAlias,
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: sw * 0.08,
                        color: Colors.black26,
                      ),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                : Center(
                    child: Icon(
                      fallbackIcon,
                      size: sw * 0.1,
                      color: color,
                    ),
                  ),
          ),

          SizedBox(width: sw * 0.03),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: sw * 0.034,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: sh * 0.008),
                Text(
                  'LKR ${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: sw * 0.032,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkPink,
                  ),
                ),
                SizedBox(height: sh * 0.01),

                // Quantity Selector
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.02,
                    vertical: sh * 0.003,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(sw * 0.015),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (qty > 1) onQuantityChanged(qty - 1);
                        },
                        child: Icon(
                          Icons.remove,
                          size: sw * 0.04,
                          color: AppColors.darkPink,
                        ),
                      ),
                      SizedBox(width: sw * 0.02),
                      Text(
                        '$qty',
                        style: TextStyle(
                          fontSize: sw * 0.03,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: sw * 0.02),
                      GestureDetector(
                        onTap: () => onQuantityChanged(qty + 1),
                        child: Icon(
                          Icons.add,
                          size: sw * 0.04,
                          color: AppColors.darkPink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: sw * 0.02),

          // Delete Button
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.delete_outline,
              size: sw * 0.055,
              color: Colors.red[400],
            ),
          ),
        ],
      ),
    );
  }
}