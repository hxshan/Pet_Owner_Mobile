import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/models/ecommerce/cart_item_model.dart';
import 'package:pet_owner_mobile/models/ecommerce/cart_model.dart';
import 'package:pet_owner_mobile/services/ecommerce_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/ecommerce/cart_product_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _service = EcommerceService();
  late Future<Cart> _cartFuture;

  // local state for optimistic updates
  Cart? _localCart;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _cartFuture = _service.getMyCart().then((cart) {
      if (mounted) {
        setState(() {
          _localCart = cart;
          _initialLoading = false;
        });
      }
      return cart;
    });
  }

  // Kept intact
  void _refresh() {
    setState(() {
      _cartFuture = _service.getMyCart().then((cart) {
        if (mounted) setState(() => _localCart = cart);
        return cart;
      });
    });
  }

  double _subtotal(Cart cart) {
    return cart.items.fold(
      0,
      (sum, item) => sum + (item.product.price * item.qty),
    );
  }

  double _delivery(double subtotal) => 450;
  double _total(double subtotal) => subtotal + _delivery(subtotal);

  // optimistic remove
  Future<void> _removeItem(Cart cart, int index) async {
    final itemId = cart.items[index].id;

    // 1. Update UI immediately
    if (_localCart != null) {
      final updatedItems = List.of(_localCart!.items)..removeAt(index);
      setState(
        () => _localCart = Cart(id: _localCart!.id, items: updatedItems),
      );
    }

    // 2. Sync with backend (original call unchanged)
    await _service.removeCartItem(itemId: itemId);
    _refresh();
  }

  // ── optimistic quantity update ───────────────────────────────────────────────
  Future<void> _updateQuantity(Cart cart, int index, int newQuantity) async {
    if (newQuantity < 1) return;
    final itemId = cart.items[index].id;

    // 1. Update UI immediately without any loading flicker
    if (_localCart != null) {
      final updatedItems = List.of(_localCart!.items);
      final oldItem = updatedItems[index];
      updatedItems[index] = CartItem(
        id: oldItem.id,
        product: oldItem.product,
        qty: newQuantity,
      );
      setState(
        () => _localCart = Cart(id: _localCart!.id, items: updatedItems),
      );
    }

    // 2. Sync with backend (original call unchanged)
    await _service.updateCartItemQty(itemId: itemId, qty: newQuantity);
    _refresh();
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
        leading: CustomBackButton(),
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
      body: _initialLoading
          // Show spinner only on the very first load
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(sw, sh),
    );
  }

  // ── main body built from _localCart (no FutureBuilder flicker) ──────────────
  Widget _buildBody(double sw, double sh) {
    final cart = _localCart;

    if (cart == null || cart.items.isEmpty) {
      return _buildEmptyCart(sw, sh);
    }

    final items = cart.items;
    final sub = _subtotal(cart);
    final delivery = _delivery(sub);
    final tot = _total(sub);

    return SafeArea(
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
                      '${items.length} items in cart',
                      style: TextStyle(
                        fontSize: sw * 0.035,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: sh * 0.02),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final p = item.product;

                        final mapped = <String, dynamic>{
                          'id': item.id,
                          'name': p.name,
                          'price': p.price,
                          'quantity': item.qty,
                          'imageUrl': (p.images.isNotEmpty
                              ? p.images.first
                              : null),
                          'image': Icons.shopping_bag_outlined,
                          'color': AppColors.darkPink,
                        };

                        return CartProductItem(
                          product: mapped,
                          sw: sw,
                          sh: sh,
                          onRemove: () => _removeItem(cart, index),
                          onQuantityChanged: (q) =>
                              _updateQuantity(cart, index, q),
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
          _buildOrderSummaryFromValues(sw, sh, sub, delivery, tot),
        ],
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

  Widget _buildOrderSummaryFromValues(
    double sw,
    double sh,
    double subtotal,
    double delivery,
    double total,
  ) {
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
            'LKR ${subtotal.toStringAsFixed(2)}',
          ),
          SizedBox(height: sh * 0.01),
          _buildSummaryRow(sw, sh, 'Delivery', 'LKR 450'),
          SizedBox(height: sh * 0.01),
          _buildSummaryRow(
            sw,
            sh,
            'Total',
            'LKR ${total.toStringAsFixed(2)}',
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
