import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/ecommerce/cart_product_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Placeholder cart items - will be replaced with actual data
  List<Map<String, dynamic>> cartItems = [
    {
      'id': '1',
      'name': 'Premium Dog Food',
      'price': 45.99,
      'quantity': 2,
      'image': Icons.pets,
      'color': Colors.amber,
    },
    {
      'id': '2',
      'name': 'Cat Toy Set',
      'price': 12.99,
      'quantity': 1,
      'image': Icons.sports_soccer,
      'color': Colors.purple,
    },
    {
      'id': '3',
      'name': 'Dog Leash',
      'price': 18.50,
      'quantity': 3,
      'image': Icons.link,
      'color': Colors.brown,
    },
  ];

  double get subtotal {
    return cartItems.fold(
      0,
      (sum, item) =>
          sum + (item['price'] as double) * (item['quantity'] as int),
    );
  }

  double get tax {
    return subtotal * 0.1; // 10% tax
  }

  double get total {
    return subtotal + tax;
  }

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      setState(() {
        cartItems[index]['quantity'] = newQuantity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(sw * 0.02),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(sw * 0.03),
            ),
            child: Icon(Icons.arrow_back, size: sw * 0.06),
          ),
        ),
        title: Text(
          'Shopping Cart',
          style: TextStyle(
            fontSize: sw * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(sw, sh)
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: sh * 0.02),
                            Text(
                              '${cartItems.length} items in cart',
                              style: TextStyle(
                                fontSize: sw * 0.035,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: sh * 0.02),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                return CartProductItem(
                                  product: cartItems[index],
                                  sw: sw,
                                  sh: sh,
                                  onRemove: () => _removeItem(index),
                                  onQuantityChanged: (quantity) =>
                                      _updateQuantity(index, quantity),
                                );
                              },
                            ),
                            SizedBox(height: sh * 0.03),
                            _buildPromoCode(sw, sh),
                            SizedBox(height: sh * 0.03),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildOrderSummary(sw, sh),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyCart(double sw, double sh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: sw * 0.3,
            height: sw * 0.3,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(sw * 0.05),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: sw * 0.15,
              color: Colors.black38,
            ),
          ),
          SizedBox(height: sh * 0.03),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: sw * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: sh * 0.01),
          Text(
            'Add items to your cart to get started',
            style: TextStyle(fontSize: sw * 0.032, color: Colors.black54),
          ),
          SizedBox(height: sh * 0.04),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkPink,
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.08,
                vertical: sh * 0.015,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(sw * 0.03),
              ),
            ),
            child: Text(
              'Continue Shopping',
              style: TextStyle(
                fontSize: sw * 0.035,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCode(double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.03),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter promo code',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: sw * 0.032,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.05,
              vertical: sh * 0.008,
            ),
            decoration: BoxDecoration(
              color: AppColors.darkPink,
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Text(
              'Apply',
              style: TextStyle(
                fontSize: sw * 0.032,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(sw * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow(
            sw,
            sh,
            'Subtotal',
            '\$${subtotal.toStringAsFixed(2)}',
          ),
          SizedBox(height: sh * 0.01),
          _buildSummaryRow(sw, sh, 'Tax (10%)', '\$${tax.toStringAsFixed(2)}'),
          SizedBox(height: sh * 0.01),
          _buildSummaryRow(
            sw,
            sh,
            'Total',
            '\$${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          SizedBox(height: sh * 0.02),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPink,
                padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sw * 0.03),
                ),
              ),
              child: Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: sw * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    double sw,
    double sh,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: sw * 0.034,
            color: isTotal ? Colors.black87 : Colors.black54,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: sw * 0.034,
            color: isTotal ? AppColors.darkPink : Colors.black87,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
