import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/ecommerce/product_model.dart';
import 'package:pet_owner_mobile/services/ecommerce_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/ecommerce/product_card.dart';

class EcommerceDashboardScreen extends StatefulWidget {
  const EcommerceDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EcommerceDashboardScreen> createState() =>
      _EcommerceDashboardScreenState();
}

class _EcommerceDashboardScreenState extends State<EcommerceDashboardScreen> {
  String selectedCategory = 'All';
  final List<String> categories = [
    'All',
    'Food',
    'Toys',
    'Accessories',
    'Health',
  ];

  final _service = EcommerceService();
  late Future<List<Product>> _productsFuture;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    final data = await _service.listProducts(
      search: _searchCtrl.text,
      category: selectedCategory,
      page: 1,
      limit: 20,
    );

    final list = (data['products'] as List? ?? []);
    return list
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: sh * 0.02),
                _buildTopBar(sw, sh),
                SizedBox(height: sh * 0.02),
                _buildSearchBar(sw, sh),
                SizedBox(height: sh * 0.025),
                _buildPromoBanner(sw, sh),
                SizedBox(height: sh * 0.025),
                _buildAccountQuickLinks(sw, sh),
                SizedBox(height: sh * 0.025),
                _buildCategoryFilter(sw, sh),
                SizedBox(height: sh * 0.025),
                _buildSectionTitle('Featured Products', sw),
                SizedBox(height: sh * 0.015),
                _buildProductGrid(sw, sh),
                SizedBox(height: sh * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(double sw, double sh) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pet Shop',
              style: TextStyle(
                fontSize: sw * 0.055,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Everything your pet needs',
              style: TextStyle(fontSize: sw * 0.032, color: Colors.black45),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => context.pushNamed('CartScreen'),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: sw * 0.065,
                    color: Colors.black87,
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: sw * 0.042,
                      height: sw * 0.042,
                      decoration: const BoxDecoration(
                        color: AppColors.darkPink,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sw * 0.022,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(double sw, double sh) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.03),
      ),
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.black54, size: sw * 0.06),
          SizedBox(width: sw * 0.02),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _refreshProducts(),
              decoration: InputDecoration(
                hintText: 'Search products...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: sw * 0.035,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(double sw, double sh) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkPink, AppColors.mainColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(sw * 0.03),
      ),
      padding: EdgeInsets.all(sw * 0.05),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Summer Sale',
                  style: TextStyle(
                    fontSize: sw * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: sh * 0.01),
                Text(
                  'Up to 50% OFF',
                  style: TextStyle(
                    fontSize: sw * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: sh * 0.012),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.darkPink,
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.05,
                      vertical: sh * 0.008,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.02),
                    ),
                  ),
                  child: Text(
                    'Shop Now',
                    style: TextStyle(
                      fontSize: sw * 0.03,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.shopping_bag,
            size: sw * 0.15,
            color: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountQuickLinks(double sw, double sh) {
    final links = [
      {
        'label': 'Orders',
        'icon': Icons.receipt_long_outlined,
        'route': 'OrderHistoryScreen',
        'color': AppColors.darkPink,
      },
      {
        'label': 'Addresses',
        'icon': Icons.location_on_outlined,
        'route': 'AddressesScreen',
        'color': Colors.teal,
      },
      {
        'label': 'Wishlist',
        'icon': Icons.favorite_outline,
        'route': 'WishlistScreen',
        'color': Colors.orange,
      },
      {
        'label': 'Vouchers',
        'icon': Icons.discount_outlined,
        'route': 'VouchersScreen',
        'color': Colors.purple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('My Account', sw),
        SizedBox(height: sh * 0.015),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: links.map((link) {
            return GestureDetector(
              onTap: () => context.pushNamed(link['route'] as String),
              child: Column(
                children: [
                  Container(
                    width: sw * 0.155,
                    height: sw * 0.155,
                    decoration: BoxDecoration(
                      color: (link['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(sw * 0.04),
                    ),
                    child: Icon(
                      link['icon'] as IconData,
                      color: link['color'] as Color,
                      size: sw * 0.065,
                    ),
                  ),
                  SizedBox(height: sh * 0.008),
                  Text(
                    link['label'] as String,
                    style: TextStyle(
                      fontSize: sw * 0.028,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, double sw) {
    return Text(
      title,
      style: TextStyle(
        fontSize: sw * 0.045,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCategoryFilter(double sw, double sh) {
    return SizedBox(
      height: sh * 0.05,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return Padding(
            padding: EdgeInsets.only(right: sw * 0.02),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                  _productsFuture = _fetchProducts();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.05,
                  vertical: sh * 0.008,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.darkPink : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(sw * 0.025),
                  border: isSelected ? null : Border.all(color: Colors.black12),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: sw * 0.03,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(double sw, double sh) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Error loading products: ${snapshot.error}'),
          );
        }

        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No products found.'),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: sw * 0.04,
            mainAxisSpacing: sh * 0.02,
            childAspectRatio: 0.75,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];

            return GestureDetector(
              onTap: () {
                context.pushNamed(
                  'ProductDetailScreen',
                  pathParameters: {'productId': p.id},
                );
              },
              child: ProductCard(
                name: p.name,
                price: 'LKR ${p.price.toStringAsFixed(2)}',
                rating: p.rating ?? 4.5,
                imageUrl: p.images[0],
                color: AppColors.darkPink.withOpacity(0.15),
                sw: sw,
                sh: sh,
              ),
            );
          },
        );
      },
    );
  }
}
