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
          // Product Image
          Container(
            width: sw * 0.22,
            height: sw * 0.22,
            decoration: BoxDecoration(
              color: (product['color'] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Icon(
              product['image'] as IconData,
              size: sw * 0.1,
              color: product['color'] as Color,
            ),
          ),
          SizedBox(width: sw * 0.03),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] as String,
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
                  '\$${(product['price'] as double).toStringAsFixed(2)}',
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
                          if ((product['quantity'] as int) > 1) {
                            onQuantityChanged((product['quantity'] as int) - 1);
                          }
                        },
                        child: Icon(
                          Icons.remove,
                          size: sw * 0.04,
                          color: AppColors.darkPink,
                        ),
                      ),
                      SizedBox(width: sw * 0.02),
                      Text(
                        '${product['quantity']}',
                        style: TextStyle(
                          fontSize: sw * 0.03,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: sw * 0.02),
                      GestureDetector(
                        onTap: () =>
                            onQuantityChanged((product['quantity'] as int) + 1),
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
