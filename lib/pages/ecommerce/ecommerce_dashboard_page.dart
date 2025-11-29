import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/ecommerce/product_card.dart';

class EcommerceDashboardScreen extends StatefulWidget {
  const EcommerceDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EcommerceDashboardScreen> createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<EcommerceDashboardScreen> {
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Food', 'Toys', 'Accessories', 'Health'];

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
                _buildSearchBar(sw, sh),
                SizedBox(height: sh * 0.025),
                _buildPromoBanner(sw, sh),
                SizedBox(height: sh * 0.03),
                _buildCategoryFilter(sw, sh),
                SizedBox(height: sh * 0.025),
                _buildProductGrid(sw, sh),
                SizedBox(height: sh * 0.02),
              ],
            ),
          ),
        ),
      ),
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
              decoration: InputDecoration(
                hintText: 'Search products...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black38, fontSize: sw * 0.035),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(double sw, double sh) {
    return Container(
      // height: sh * 0.18,
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
                    style: TextStyle(fontSize: sw * 0.03, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.shopping_bag, size: sw * 0.15, color: Colors.white.withOpacity(0.3)),
        ],
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
    final products = [
      {'name': 'Premium Dog Food', 'price': '\$45.99', 'rating': 4.5, 'image': Icons.pets, 'color': Colors.amber},
      {'name': 'Cat Toy Set', 'price': '\$12.99', 'rating': 4.8, 'image': Icons.sports_soccer, 'color': Colors.purple},
      {'name': 'Dog Leash', 'price': '\$18.50', 'rating': 4.3, 'image': Icons.link, 'color': Colors.brown},
      {'name': 'Pet Bed', 'price': '\$65.00', 'rating': 4.6, 'image': Icons.bed, 'color': Colors.teal},
      {'name': 'Grooming Kit', 'price': '\$34.99', 'rating': 4.7, 'image': Icons.content_cut, 'color': Colors.pink},
      {'name': 'Water Bowl', 'price': '\$22.00', 'rating': 4.4, 'image': Icons.local_drink, 'color': Colors.blue},
    ];

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
        final product = products[index];
        return ProductCard(
          name: product['name'] as String,
          price: product['price'] as String,
          rating: product['rating'] as double,
          icon: product['image'] as IconData,
          color: product['color'] as Color,
          sw: sw,
          sh: sh,
        );
      },
    );
  }
}

