import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_owner_mobile/models/ecommerce/order_model.dart';
import 'package:pet_owner_mobile/services/ecommerce_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final _service = EcommerceService();
  late Future<Order> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMyOrderById(widget.orderId);
  }

  String _moneyLkr(int amount) {
    return "LKR ${amount.toStringAsFixed(2)}";
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case "DELIVERED":
      case "FULFILLED":
        return Colors.green;
      case "SHIPPED":
        return Colors.blue;
      case "PACKED":
      case "ACCEPTED":
      case "PARTIALLY_FULFILLED":
        return Colors.orange;
      case "CANCELLED":
        return Colors.red;
      default:
        return Colors.black54;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case "DELIVERED":
      case "FULFILLED":
        return Icons.check_circle_outline_rounded;
      case "SHIPPED":
        return Icons.local_shipping_outlined;
      case "PACKED":
        return Icons.inventory_2_outlined;
      case "ACCEPTED":
        return Icons.thumb_up_alt_outlined;
      case "PARTIALLY_FULFILLED":
        return Icons.splitscreen_outlined;
      case "CANCELLED":
        return Icons.cancel_outlined;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          'Order Details',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: sw * 0.045,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black38, height: 1),
        ),
      ),
      body: FutureBuilder<Order>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.darkPink,
                strokeWidth: 2.5,
              ),
            );
          }
          if (snap.hasError) {
            return _errorState(sw, sh, snap.error.toString());
          }
          final order = snap.data;
          if (order == null) {
            return _errorState(sw, sh, "Order not found");
          }

          final dateStr = DateFormat(
            "MMM dd, yyyy • hh:mm a",
          ).format(order.createdAt);
          final statusColor = _statusColor(order.status);

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.045,
              vertical: sh * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerCard(sw, sh, order, dateStr, statusColor),
                SizedBox(height: sh * 0.025),

                _sectionTitle(sw, "Items", Icons.shopping_bag_outlined),
                SizedBox(height: sh * 0.012),
                ...order.items.map((i) => _itemRow(sw, sh, i)).toList(),

                SizedBox(height: sh * 0.025),
                _sectionTitle(sw, "Delivery Address", Icons.location_on_outlined),
                SizedBox(height: sh * 0.012),
                _addressCard(sw, sh, order.shippingAddress),

                SizedBox(height: sh * 0.025),
                _sectionTitle(sw, "Store Orders", Icons.storefront_outlined),
                SizedBox(height: sh * 0.012),
                ...order.storeOrders
                    .map((s) => _storeOrderCard(sw, sh, s))
                    .toList(),

                SizedBox(height: sh * 0.025),
                _sectionTitle(sw, "Payment", Icons.payment_outlined),
                SizedBox(height: sh * 0.012),
                _paymentCard(sw, sh, order),

                SizedBox(height: sh * 0.025),
                _sectionTitle(sw, "Summary", Icons.receipt_long_outlined),
                SizedBox(height: sh * 0.012),
                _summaryCard(sw, sh, order),

                SizedBox(height: sh * 0.03),
              ],
            ),
          );
        },
      ),
    );
  }

  //  Header card ─

  Widget _headerCard(
    double sw,
    double sh,
    Order order,
    String dateStr,
    Color statusColor,
  ) {
    return Container(
      padding: EdgeInsets.all(sw * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(sw * 0.025),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _statusIcon(order.status),
                  color: statusColor,
                  size: sw * 0.055,
                ),
              ),
              SizedBox(width: sw * 0.035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.03,
                        vertical: sh * 0.004,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(sw * 0.02),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: sw * 0.03,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: sh * 0.005),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: sw * 0.03,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.018),
          Divider(height: 1, color: Colors.black38),
          SizedBox(height: sh * 0.015),
          Text(
            "Order ID",
            style: TextStyle(fontSize: sw * 0.028, color: Colors.black38),
          ),
          SizedBox(height: sh * 0.003),
          Text(
            order.id,
            style: TextStyle(
              fontSize: sw * 0.034,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  //  Item row 

  Widget _itemRow(double sw, double sh, OrderItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.01),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.035),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: sw * 0.14,
            height: sw * 0.14,
            decoration: BoxDecoration(
              color: AppColors.darkPink.withOpacity(0.08),
              borderRadius: BorderRadius.circular(sw * 0.03),
            ),
            child: Icon(
              Icons.pets_rounded,
              color: AppColors.darkPink.withOpacity(0.5),
              size: sw * 0.06,
            ),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: sw * 0.034,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: sh * 0.005),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.025,
                    vertical: sh * 0.003,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(sw * 0.015),
                  ),
                  child: Text(
                    "Qty: ${item.qty}",
                    style: TextStyle(
                      fontSize: sw * 0.028,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: sw * 0.02),
          Text(
            _moneyLkr(item.price * item.qty),
            style: TextStyle(
              fontSize: sw * 0.034,
              fontWeight: FontWeight.bold,
              color: AppColors.darkPink,
            ),
          ),
        ],
      ),
    );
  }

  //  Address card 

  Widget _addressCard(double sw, double sh, ShippingAddress a) {
    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.025),
            decoration: BoxDecoration(
              color: AppColors.darkPink.withOpacity(0.08),
              borderRadius: BorderRadius.circular(sw * 0.025),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: AppColors.darkPink,
              size: sw * 0.05,
            ),
          ),
          SizedBox(width: sw * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (a.label.isNotEmpty)
                  Text(
                    a.label,
                    style: TextStyle(
                      fontSize: sw * 0.034,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                SizedBox(height: sh * 0.005),
                Text(
                  "${a.name} • ${a.phone}",
                  style: TextStyle(
                    fontSize: sw * 0.031,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: sh * 0.007),
                Text(
                  "${a.addressLine1}${a.addressLine2.isNotEmpty ? ", ${a.addressLine2}" : ""}\n${a.city}, ${a.district}\n${a.province}, ${a.country}${a.postalCode.isNotEmpty ? " • ${a.postalCode}" : ""}",
                  style: TextStyle(
                    fontSize: sw * 0.031,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //  Store order card 

  Widget _storeOrderCard(double sw, double sh, StoreOrder s) {
    final c = _statusColor(s.status);
    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.01),
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: sw * 0.04,
                    color: Colors.black45,
                  ),
                  SizedBox(width: sw * 0.02),
                  Text(
                    s.store,
                    style: TextStyle(
                      fontSize: sw * 0.034,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.028,
                  vertical: sh * 0.004,
                ),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(sw * 0.02),
                ),
                child: Text(
                  s.status,
                  style: TextStyle(
                    color: c,
                    fontSize: sw * 0.028,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.012),
          Divider(height: 1, color: Colors.black38),
          SizedBox(height: sh * 0.012),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${s.items.length} item${s.items.length == 1 ? '' : 's'}",
                style: TextStyle(fontSize: sw * 0.031, color: Colors.black45),
              ),
              Text(
                _moneyLkr(s.subtotal),
                style: TextStyle(
                  fontSize: sw * 0.033,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //  Payment card 

  Widget _paymentCard(double sw, double sh, Order o) {
    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv(sw, sh, "Method", o.paymentMethod, Icons.credit_card_outlined),
          SizedBox(height: sh * 0.012),
          Divider(height: 1, color: Colors.black38),
          SizedBox(height: sh * 0.012),
          _kv(sw, sh, "Status", o.paymentStatus, Icons.verified_outlined),
          if (o.note.trim().isNotEmpty) ...[
            SizedBox(height: sh * 0.012),
            Divider(height: 1, color: Colors.black38),
            SizedBox(height: sh * 0.012),
            _kv(sw, sh, "Note", o.note, Icons.notes_rounded),
          ],
        ],
      ),
    );
  }

  //  Summary card 

  Widget _summaryCard(double sw, double sh, Order o) {
    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow(sw, "Subtotal", _moneyLkr(o.subtotal)),
          SizedBox(height: sh * 0.012),
          _summaryRow(sw, "Delivery Fee", _moneyLkr(o.deliveryFee)),
          SizedBox(height: sh * 0.014),
          Divider(height: 1, color: Colors.black12),
          SizedBox(height: sh * 0.014),
          _summaryRow(sw, "Total", _moneyLkr(o.total), isTotal: true),
        ],
      ),
    );
  }

  //  Helpers ─

  Widget _summaryRow(
    double sw,
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
            fontSize: isTotal ? sw * 0.037 : sw * 0.033,
            color: isTotal ? Colors.black87 : Colors.black54,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? sw * 0.038 : sw * 0.033,
            color: isTotal ? AppColors.darkPink : Colors.black87,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(double sw, String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: sw * 0.042, color: AppColors.darkPink),
        SizedBox(width: sw * 0.02),
        Text(
          text,
          style: TextStyle(
            fontSize: sw * 0.038,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _kv(double sw, double sh, String k, String v, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: sw * 0.04, color: Colors.black38),
        SizedBox(width: sw * 0.025),
        SizedBox(
          width: sw * 0.25,
          child: Text(
            k,
            style: TextStyle(fontSize: sw * 0.032, color: Colors.black45),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: TextStyle(
              fontSize: sw * 0.032,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorState(double sw, double sh, String msg) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(sw * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: sw * 0.18,
              color: Colors.black12,
            ),
            SizedBox(height: sh * 0.02),
            Text(
              "Something went wrong",
              style: TextStyle(
                fontSize: sw * 0.042,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: sh * 0.01),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: sw * 0.032, color: Colors.black45),
            ),
            SizedBox(height: sh * 0.025),
            ElevatedButton(
              onPressed: () => setState(
                () => _future = _service.getMyOrderById(widget.orderId),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPink,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.08,
                  vertical: sh * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sw * 0.03),
                ),
              ),
              child: Text(
                "Retry",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: sw * 0.035,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}