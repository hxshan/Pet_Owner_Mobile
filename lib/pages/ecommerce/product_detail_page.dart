import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/models/ecommerce/product_model.dart';
import 'package:pet_owner_mobile/services/ecommerce_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailScreen> {
  late Future<Product> _productFuture;
  final _service = EcommerceService();

  int quantity = 1;
  bool isFavorite = false;
  int selectedImageIndex = 0;
  bool _addingToCart = false;

  @override
  void initState() {
    super.initState();
    _productFuture = _service.getProductById(widget.productId);
  }

  late String productName = 'Premium Dog Food';
  late String productPrice = '\$45.99';
  late double rating = 4.5;
  late IconData icon = Icons.pets;
  late Color color = Colors.amber;
  late List<Color> productImages = [
    Colors.amber,
    Colors.orange,
    Colors.amber,
    Colors.orange,
  ];

  Future<void> _handleAddToCart() async {
    setState(() => _addingToCart = true);
    try {
      await _service.addToCart(productId: widget.productId, qty: quantity);
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to cart')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Product>(
          future: _productFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading product: ${snapshot.error}'),
              );
            }

            final product = snapshot.data!;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageGallery(sw, sh, product),
                      SizedBox(height: sh * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProductHeader(sw, sh, product),
                            SizedBox(height: sh * 0.015),
                            _buildRatingSection(sw, sh, product),
                            SizedBox(height: sh * 0.02),
                            _buildPriceSection(sw, sh, product),
                            SizedBox(height: sh * 0.025),
                            _buildDescriptionSection(sw, sh, product),
                            // specs + reviews can stay static for now or map from backend later
                            SizedBox(height: sh * 0.025),
                            // _buildSpecificationsSection(sw, sh),
                            // SizedBox(height: sh * 0.025),
                            _buildReviewsSection(sw, sh),
                            SizedBox(height: sh * 0.02),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildHeader(sw, sh),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(sw, sh),
    );
  }

  Widget _buildHeader(double sw, double sh) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.05,
          vertical: sh * 0.01,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomBackButton(showPadding: false),
            Text(
              'Product Details',
              style: TextStyle(
                fontSize: sw * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => isFavorite = !isFavorite),
              child: Container(
                padding: EdgeInsets.all(sw * 0.02),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(sw * 0.03),
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: sw * 0.06,
                  color: isFavorite ? AppColors.darkPink : Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(double sw, double sh, Product product) {
    final images = product.images.isNotEmpty
        ? product.images
        : ['']; // fallback

    return Column(
      children: [
        SizedBox(height: sh * 0.065),
        Container(
          height: sh * 0.35,
          color: Colors.white,
          child: PageView.builder(
            onPageChanged: (index) =>
                setState(() => selectedImageIndex = index),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final url = images[index];

              return Container(
                margin: EdgeInsets.symmetric(horizontal: sw * 0.05),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(sw * 0.04),
                ),
                clipBehavior: Clip.antiAlias,
                child: url.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: sw * 0.2,
                          color: Colors.black26,
                        ),
                      )
                    : Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.broken_image,
                            size: sw * 0.2,
                            color: Colors.black26,
                          ),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
              );
            },
          ),
        ),
        SizedBox(height: sh * 0.015),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: sw * 0.015),
              width: selectedImageIndex == index ? sw * 0.04 : sw * 0.025,
              height: sw * 0.025,
              decoration: BoxDecoration(
                color: selectedImageIndex == index
                    ? AppColors.darkPink
                    : Colors.black12,
                borderRadius: BorderRadius.circular(sw * 0.025),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductHeader(double sw, double sh, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: TextStyle(
            fontSize: sw * 0.055,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: sh * 0.005),
        Text(
          product.category ?? 'Premium Quality Pet Product',
          style: TextStyle(fontSize: sw * 0.032, color: Colors.black54),
        ),
        if (product.storeName != null) ...[
          SizedBox(height: sh * 0.006),
          Text(
            'Sold by ${product.storeName}${product.storeLocation != null ? " • ${product.storeLocation}" : ""}',
            style: TextStyle(fontSize: sw * 0.03, color: Colors.black45),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingSection(double sw, double sh, Product product) {
    final rating = product.rating ?? 0.0;
    final reviewCount = product.reviewCount ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.03,
                vertical: sh * 0.006,
              ),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(sw * 0.02),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: sw * 0.04,
                    color: Colors.amber,
                  ),
                  SizedBox(width: sw * 0.01),
                  Text(
                    rating == 0 ? 'N/A' : rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: sw * 0.03,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: sw * 0.03),
            Text(
              reviewCount == 0 ? '(No reviews)' : '($reviewCount reviews)',
              style: TextStyle(fontSize: sw * 0.03, color: Colors.black54),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.03,
            vertical: sh * 0.006,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(sw * 0.02),
          ),
          child: Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: sw * 0.04,
                color: Colors.green,
              ),
              SizedBox(width: sw * 0.01),
              Text(
                'Free Shipping',
                style: TextStyle(
                  fontSize: sw * 0.028,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(double sw, double sh, Product product) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.03),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price',
                style: TextStyle(fontSize: sw * 0.03, color: Colors.black54),
              ),
              SizedBox(height: sh * 0.005),
              Text(
                'LKR ${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: sw * 0.055,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkPink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(double sw, double sh, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: sw * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: sh * 0.01),
        Text(
          product.description ?? 'No description available.',
          style: TextStyle(
            fontSize: sw * 0.032,
            color: Colors.black54,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecificationsSection(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: TextStyle(
            fontSize: sw * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: sh * 0.015),
        _buildSpecRow(sw, sh, 'Weight', '500g'),
        SizedBox(height: sh * 0.01),
        _buildSpecRow(sw, sh, 'Ingredients', 'Natural & Organic'),
        SizedBox(height: sh * 0.01),
        _buildSpecRow(sw, sh, 'Suitable For', 'Dogs & Puppies'),
        SizedBox(height: sh * 0.01),
        _buildSpecRow(sw, sh, 'Shelf Life', '24 months'),
      ],
    );
  }

  Widget _buildSpecRow(double sw, double sh, String label, String value) {
    return Container(
      padding: EdgeInsets.all(sw * 0.03),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.02),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.032,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: sw * 0.032,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Customer Reviews',
              style: TextStyle(
                fontSize: sw * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See all',
                style: TextStyle(
                  fontSize: sw * 0.03,
                  color: AppColors.darkPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.015),
        _buildReviewCard(
          sw,
          sh,
          'John Doe',
          'Amazing product! My dog loves it.',
          5.0,
        ),
        SizedBox(height: sh * 0.012),
        _buildReviewCard(
          sw,
          sh,
          'Sarah Smith',
          'Great quality and fast delivery.',
          4.5,
        ),
        SizedBox(height: sh * 0.012),
        _buildReviewCard(
          sw,
          sh,
          'Mike Johnson',
          'Excellent value for money!',
          4.8,
        ),
      ],
    );
  }

  Widget _buildReviewCard(
    double sw,
    double sh,
    String name,
    String review,
    double rating,
  ) {
    return Container(
      padding: EdgeInsets.all(sw * 0.03),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: sw * 0.032,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    size: sw * 0.03,
                    color: index < rating.toInt()
                        ? Colors.amber
                        : Colors.black12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.005),
          Text(
            review,
            style: TextStyle(
              fontSize: sw * 0.03,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(double sw, double sh) {
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
          // Quantity Selector
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sh * 0.008,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(sw * 0.025),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },
                  child: Container(
                    width: sw * 0.08,
                    height: sw * 0.08,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(sw * 0.02),
                    ),
                    child: Icon(
                      Icons.remove,
                      size: sw * 0.04,
                      color: AppColors.darkPink,
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.04),
                Text(
                  '$quantity',
                  style: TextStyle(
                    fontSize: sw * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: sw * 0.04),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      quantity++;
                    });
                  },
                  child: Container(
                    width: sw * 0.08,
                    height: sw * 0.08,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(sw * 0.02),
                    ),
                    child: Icon(
                      Icons.add,
                      size: sw * 0.04,
                      color: AppColors.darkPink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sh * 0.015),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _addingToCart ? null : _handleAddToCart,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.darkPink, width: 2),
                    padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.03),
                    ),
                  ),
                  child: _addingToCart
                      ? SizedBox(
                          height: sw * 0.045,
                          width: sw * 0.045,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: sw * 0.04,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkPink,
                          ),
                        ),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
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
                    'Buy Now',
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
        ],
      ),
    );
  }
}
