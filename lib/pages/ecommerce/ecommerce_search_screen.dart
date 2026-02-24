import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/ecommerce/product_model.dart';
import 'package:pet_owner_mobile/services/ecommerce_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/ecommerce/ecommerce_search_bar.dart';
import 'package:pet_owner_mobile/widgets/ecommerce/product_card.dart';

class EcommerceSearchScreen extends StatefulWidget {
  final String initialQuery;
  final String initialCategory;

  const EcommerceSearchScreen({
    Key? key,
    required this.initialQuery,
    required this.initialCategory,
  }) : super(key: key);

  @override
  State<EcommerceSearchScreen> createState() => _EcommerceSearchScreenState();
}

class _EcommerceSearchScreenState extends State<EcommerceSearchScreen> {
  final _service = EcommerceService();
  late TextEditingController _searchCtrl;

  String selectedCategory = 'All';
  final List<String> categories = [
    'All',
    'Food',
    'Toys',
    'Accessories',
    'Health',
  ];

  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
    selectedCategory = widget.initialCategory.isEmpty
        ? 'All'
        : widget.initialCategory;
    _productsFuture = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    final data = await _service.listProducts(
      search: _searchCtrl.text,
      category: selectedCategory,
      page: 1,
      limit: 50,
    );

    final list = (data['products'] as List? ?? []);
    return list
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  void _refresh() {
    setState(() => _productsFuture = _fetchProducts());
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          'Search Results',
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: sh * 0.015),
              EcommerceSearchBar(
                controller: _searchCtrl,
                onSubmitted: (_) => _refresh(),
              ),
              SizedBox(height: sh * 0.015),
              _buildCategoryFilter(sw, sh),
              SizedBox(height: sh * 0.015),
              Expanded(child: _buildProductGrid(sw, sh)),
            ],
          ),
        ),
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
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.darkPink,
              strokeWidth: 2.5,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: sw * 0.12,
                  color: Colors.black26,
                ),
                SizedBox(height: sh * 0.015),
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: sw * 0.038,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: sh * 0.008),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(
                    fontSize: sw * 0.03,
                    color: Colors.black38,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: sw * 0.15,
                  color: Colors.black12,
                ),
                SizedBox(height: sh * 0.02),
                Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: sw * 0.042,
                    fontWeight: FontWeight.bold,
                    color: Colors.black45,
                  ),
                ),
                SizedBox(height: sh * 0.008),
                Text(
                  'Try a different keyword or category',
                  style: TextStyle(
                    fontSize: sw * 0.032,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
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
                productId: p.id,
                name: p.name,
                price: 'LKR ${p.price.toStringAsFixed(2)}',
                rating: p.rating ?? 4.5,
                imageUrl: p.images.isNotEmpty ? p.images[0] : '',
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