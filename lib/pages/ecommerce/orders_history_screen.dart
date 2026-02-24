import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pet_owner_mobile/models/ecommerce/order_model.dart';
import 'package:pet_owner_mobile/services/ecommerce_service.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/ecommerce/order_history_card.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  final _service = EcommerceService();

  int _page = 1;
  final int _limit = 20;

  bool _loading = true;
  bool _loadingMore = false;

  int _total = 0;
  final List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchInitial();
  }

  Future<void> _fetchInitial() async {
    setState(() {
      _loading = true;
      _page = 1;
      _orders.clear();
      _total = 0;
    });

    try {
      final res = await _service.listMyOrders(page: _page, limit: _limit);

      final total = (res['total'] as int?) ?? 0;
      final list = (res['orders'] as List?) ?? [];

      final parsed = list
          .whereType<Map>()
          .map((e) => Order.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (!mounted) return;
      setState(() {
        _total = total;
        _orders.addAll(parsed);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(e.toString());
    }
  }

  Future<void> _fetchMore() async {
    if (_loadingMore) return;
    if (_orders.length >= _total) return;

    setState(() => _loadingMore = true);
    try {
      final nextPage = _page + 1;
      final res = await _service.listMyOrders(page: nextPage, limit: _limit);

      final list = (res['orders'] as List?) ?? [];
      final parsed = list
          .whereType<Map>()
          .map((e) => Order.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (!mounted) return;
      setState(() {
        _page = nextPage;
        _orders.addAll(parsed);
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

  String _moneyLkr(int amount) {
    return "LKR ${amount.toStringAsFixed(2)}";
  }

  String _itemsPreview(Order o) {
    if (o.items.isEmpty) return "No items";
    final names = o.items
        .map((i) => i.name)
        .where((n) => n.trim().isNotEmpty)
        .toList();
    if (names.isEmpty) return "Items";
    return names.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? _buildEmptyState(sw, sh)
          : RefreshIndicator(
              onRefresh: _fetchInitial,
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                    _fetchMore();
                  }
                  return false;
                },
                child: ListView.separated(
                  padding: EdgeInsets.all(sw * 0.05),
                  itemCount: _orders.length + (_loadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => SizedBox(height: sh * 0.015),
                  itemBuilder: (context, index) {
                    if (_loadingMore && index == _orders.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final o = _orders[index];
                    final dateText = DateFormat(
                      "MMM dd, yyyy",
                    ).format(o.createdAt);

                    return OrderHistoryCard(
                      id: o.id,
                      dateText: dateText,
                      statusText: o.status,
                      statusColor: _statusColor(o.status),
                      itemsText: _itemsPreview(o),
                      totalText: _moneyLkr(o.total),
                      onViewDetails: () {
                        context.pushNamed(
                          'OrderDetailsScreen',
                          pathParameters: {'id': o.id},
                        );
                      },
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState(double sw, double sh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: sw * 0.2,
            color: Colors.black12,
          ),
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
