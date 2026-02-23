import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
          child: Column(
            children: [
              const Spacer(),

              // ── Animated check icon ──────────────────────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer soft ring
                    Container(
                      width: sw * 0.38,
                      height: sw * 0.38,
                      decoration: BoxDecoration(
                        color: AppColors.darkPink.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Inner filled circle
                    Container(
                      width: sw * 0.28,
                      height: sw * 0.28,
                      decoration: const BoxDecoration(
                        color: AppColors.darkPink,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: sw * 0.13,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: sh * 0.04),

              // ── Text content (fades + slides in) ────────────────────────
              AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) => Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: child,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Order Placed!',
                      style: TextStyle(
                        fontSize: sw * 0.065,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: sh * 0.01),
                    Text(
                      'Thank you for your purchase 🎉',
                      style: TextStyle(
                        fontSize: sw * 0.035,
                        color: Colors.black45,
                      ),
                    ),
                    SizedBox(height: sh * 0.025),

                    // Order ID pill
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.05,
                        vertical: sh * 0.012,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(sw * 0.03),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: sw * 0.04,
                            color: Colors.black45,
                          ),
                          SizedBox(width: sw * 0.02),
                          Text(
                            'Order ID: ${widget.orderId}',
                            style: TextStyle(
                              fontSize: sw * 0.032,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Bottom buttons (same style as CartScreen / CheckoutScreen) ─
              AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) => Opacity(
                  opacity: _fadeAnim.value,
                  child: child,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            context.pushReplacementNamed('EcommerceDashboardScreen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPink,
                          padding:
                              EdgeInsets.symmetric(vertical: sh * 0.018),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
                        ),
                        child: Text(
                          'Continue Shopping',
                          style: TextStyle(
                            fontSize: sw * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: sh * 0.015),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            context.pushNamed('OrderHistoryScreen'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.darkPink, width: 1.5),
                          padding:
                              EdgeInsets.symmetric(vertical: sh * 0.018),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
                        ),
                        child: Text(
                          'View My Orders',
                          style: TextStyle(
                            fontSize: sw * 0.04,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkPink,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: sh * 0.04),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}