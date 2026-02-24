import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/models/ecommerce/product_model.dart';
import 'package:pet_owner_mobile/services/ecommerce_service.dart';
import 'package:pet_owner_mobile/store/wishlist_scope.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _service = EcommerceService(); // only for addToCart here

  bool _addingToCart = false;

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _addToCart(Product product) async {
    if (_addingToCart) return;
    setState(() => _addingToCart = true);

    try {
      await _service.addToCart(productId: product.id, qty: 1);
      _toast('Added to cart');
    } catch (e) {
      _toast('Failed to add to cart');
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    final store = WishlistScope.of(context);

    // load once (safe to call repeatedly)
    store.loadOnce();

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        // If your store currently only caches ids, you need products too.
        // So: we’ll extend the store (below) OR fallback to server fetch.
        //
        // ✅ Recommended: update store to also keep List<Product>.
        final products = store.products; // <-- after store update

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
          body: store.isLoading && !store.isLoaded
              ? const Center(child: CircularProgressIndicator())
              : products.isEmpty
                  ? _buildEmptyState(sw, sh)
                  : RefreshIndicator(
                      onRefresh: store.refresh, // <-- after store update
                      child: ListView.separated(
                        padding: EdgeInsets.all(sw * 0.05),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => SizedBox(height: sh * 0.015),
                        itemBuilder: (context, index) => _buildWishlistItem(
                          products[index],
                          index,
                          sw,
                          sh,
                          store,
                        ),
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildWishlistItem(
    Product product,
    int index,
    double sw,
    double sh,
    dynamic store, // WishlistStore
  ) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;

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
              color: AppColors.darkPink.withOpacity(0.12),
              borderRadius: BorderRadius.circular(sw * 0.03),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.favorite,
                      color: AppColors.darkPink,
                      size: sw * 0.07,
                    ),
                  )
                : Icon(
                    Icons.favorite,
                    color: AppColors.darkPink,
                    size: sw * 0.07,
                  ),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: sw * 0.038,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: sh * 0.005),
                Text(
                  'LKR ${product.price.toStringAsFixed(2)}',
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
                onTap: () async {
                  try {
                    await store.toggle(product.id); // removes from wishlist
                  } catch (_) {
                    _toast('Failed to remove from wishlist');
                  }
                },
                child: Icon(
                  Icons.favorite,
                  color: AppColors.darkPink,
                  size: sw * 0.055,
                ),
              ),
              SizedBox(height: sh * 0.01),
              GestureDetector(
                onTap: () => _addToCart(product),
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