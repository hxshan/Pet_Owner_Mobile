import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/ecommerce/cart_model.dart';
import 'package:pet_owner_mobile/services/ecommerce_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _service = EcommerceService();
  late Future<_CheckoutData> _future;

  String? _selectedAddressId;
  String _paymentMethod = 'COD';
  final _noteCtrl = TextEditingController();
  bool _placing = false;

  static const double _deliveryFee = 450.0;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_CheckoutData> _load() async {
    final cart = await _service.getMyCart();
    final addresses = await _service.listMyAddresses();

    final defaultAddr = addresses.cast<Map<String, dynamic>>().firstWhere(
          (a) => a['isDefault'] == true,
          orElse: () =>
              addresses.isNotEmpty ? addresses.first : <String, dynamic>{},
        );
    if (_selectedAddressId == null && defaultAddr.isNotEmpty) {
      _selectedAddressId = (defaultAddr['_id'] ?? defaultAddr['id']).toString();
    }

    return _CheckoutData(cart: cart, addresses: addresses);
  }

  double _subtotal(Cart cart) =>
      cart.items.fold(0, (sum, i) => sum + (i.product.price * i.qty));
  double _total(double subtotal) => subtotal + _deliveryFee;

  Future<void> _placeOrder() async {
    if (_selectedAddressId == null || _selectedAddressId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an address')),
      );
      return;
    }

    setState(() => _placing = true);
    try {
      final order = await _service.createOrder(
        addressId: _selectedAddressId!,
        paymentMethod: _paymentMethod,
        note: _noteCtrl.text.trim(),
      );

      if (!mounted) return;

      final orderId = (order['_id'] ?? order['id']).toString();
      context.pushReplacementNamed('OrderSuccessScreen', extra: orderId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: const CustomBackButton(),
        title: Text(
          'Checkout',
          style: TextStyle(
            fontSize: sw * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<_CheckoutData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkPink),
            );
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final data = snap.data!;
          final cart = data.cart;

          if (cart.items.isEmpty) {
            return const Center(child: Text('Cart is empty.'));
          }

          final subtotal = _subtotal(cart);
          final total = _total(subtotal);

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.05,
                      vertical: sh * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Shipping Address ──────────────────────────────
                        _sectionTitle('Shipping Address', sw),
                        SizedBox(height: sh * 0.012),
                        _addressPicker(data.addresses, sw, sh),

                        SizedBox(height: sh * 0.03),

                        // ── Payment Method ────────────────────────────────
                        _sectionTitle('Payment Method', sw),
                        SizedBox(height: sh * 0.012),
                        _paymentPicker(sw),

                        SizedBox(height: sh * 0.03),

                        // ── Order Note ────────────────────────────────────
                        _sectionTitle('Order Note (optional)', sw),
                        SizedBox(height: sh * 0.012),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
                          child: TextField(
                            controller: _noteCtrl,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Any delivery notes?',
                              hintStyle: TextStyle(
                                color: Colors.black38,
                                fontSize: sw * 0.032,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(sw * 0.03),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.all(sw * 0.04),
                            ),
                          ),
                        ),

                        SizedBox(height: sh * 0.03),

                        // ── Order Summary ─────────────────────────────────
                        _sectionTitle('Order Summary', sw),
                        SizedBox(height: sh * 0.012),
                        _summaryCard(sw, sh, subtotal, total),

                        SizedBox(height: sh * 0.02),
                      ],
                    ),
                  ),
                ),

                // ── Bottom CTA — matches CartScreen's bottom bar ──────────
                Container(
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
                      // Mini total recap
                      _summaryRow(
                        'Total',
                        'LKR ${total.toStringAsFixed(2)}',
                        sw,
                        isTotal: true,
                      ),
                      SizedBox(height: sh * 0.015),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _placing ? null : _placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkPink,
                            disabledBackgroundColor:
                                AppColors.darkPink.withOpacity(0.6),
                            padding:
                                EdgeInsets.symmetric(vertical: sh * 0.018),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(sw * 0.03),
                            ),
                          ),
                          child: _placing
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _paymentMethod == 'CARD'
                                      ? 'Pay & Place Order'
                                      : 'Place Order',
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title, double sw) => Text(
        title,
        style: TextStyle(
          fontSize: sw * 0.045,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      );

  Widget _addressPicker(
    List<Map<String, dynamic>> addresses,
    double sw,
    double sh,
  ) {
    if (addresses.isEmpty) {
      return Container(
        padding: EdgeInsets.all(sw * 0.04),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(sw * 0.03),
        ),
        child: Text(
          'No addresses found. Please add an address first.',
          style: TextStyle(fontSize: sw * 0.032, color: Colors.black54),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.004),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.03),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAddressId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: addresses.map((a) {
            final id = (a['_id'] ?? a['id']).toString();
            final label = (a['label'] ?? 'ADDRESS').toString();
            final line1 = (a['addressLine1'] ?? '').toString();
            final city = (a['city'] ?? '').toString();
            final isDefault = a['isDefault'] == true;

            return DropdownMenuItem(
              value: id,
              child: Text(
                '${isDefault ? "⭐ " : ""}$label — $line1, $city',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: sw * 0.033, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedAddressId = v),
        ),
      ),
    );
  }

  Widget _paymentPicker(double sw) {
    Widget tile(String value, String title, String subtitle, IconData icon) {
      final selected = _paymentMethod == value;
      return GestureDetector(
        onTap: () => setState(() => _paymentMethod = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
            vertical: sw * 0.035,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.darkPink.withOpacity(0.08)
                : AppColors.lightGray,
            borderRadius: BorderRadius.circular(sw * 0.03),
            border: Border.all(
              color: selected ? AppColors.darkPink : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: sw * 0.1,
                height: sw * 0.1,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.darkPink.withOpacity(0.15)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(sw * 0.025),
                ),
                child: Icon(
                  icon,
                  color: selected ? AppColors.darkPink : Colors.black38,
                  size: sw * 0.055,
                ),
              ),
              SizedBox(width: sw * 0.035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: sw * 0.038,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: sw * 0.029,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: sw * 0.055,
                height: sw * 0.055,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.darkPink : Colors.black26,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: sw * 0.03,
                          height: sw * 0.03,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.darkPink,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        tile('COD', 'Cash on Delivery', 'Pay when you receive the order',
            Icons.payments_outlined),
        tile('CARD', 'Card Payment', 'Pay now securely',
            Icons.credit_card_outlined),
      ],
    );
  }

  Widget _summaryCard(
    double sw,
    double sh,
    double subtotal,
    double total,
  ) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', 'LKR ${subtotal.toStringAsFixed(2)}', sw),
          SizedBox(height: sh * 0.01),
          _summaryRow('Delivery Fee', 'LKR ${_deliveryFee.toStringAsFixed(2)}', sw),
          SizedBox(height: sh * 0.01),
          Divider(color: Colors.black.withOpacity(0.08)),
          SizedBox(height: sh * 0.01),
          _summaryRow(
            'Total',
            'LKR ${total.toStringAsFixed(2)}',
            sw,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    double sw, {
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

class _CheckoutData {
  final Cart cart;
  final List<Map<String, dynamic>> addresses;
  _CheckoutData({required this.cart, required this.addresses});
}