import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/ecommerce/ecommerce_search_bar.dart';

class EcommerceSearchViewScreen extends StatefulWidget {
  final String initialQuery;
  final String initialCategory;

  const EcommerceSearchViewScreen({
    Key? key,
    required this.initialQuery,
    required this.initialCategory,
  }) : super(key: key);

  @override
  State<EcommerceSearchViewScreen> createState() =>
      _EcommerceSearchViewScreenState();
}

class _EcommerceSearchViewScreenState extends State<EcommerceSearchViewScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _ctrl;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  final List<String> _recentSearches = [
    'Dog food',
    'Cat toys',
    'Pet collar',
    'Grooming kit',
  ];

  final List<Map<String, dynamic>> _trending = [
    {'label': 'Royal Canin', 'icon': Icons.trending_up_rounded},
    {'label': 'Chew Toys', 'icon': Icons.trending_up_rounded},
    {'label': 'Flea Collar', 'icon': Icons.trending_up_rounded},
    {'label': 'Cat Litter', 'icon': Icons.trending_up_rounded},
    {'label': 'Harness', 'icon': Icons.trending_up_rounded},
    {'label': 'Vitamins', 'icon': Icons.trending_up_rounded},
  ];

  final List<String> _categories = [
    'All',
    'Food',
    'Toys',
    'Accessories',
    'Health',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _goResults(String q) {
    final query = q.trim();
    if (query.isEmpty) return;

    context.pushNamed(
      'EcommerceSearchResultsScreen',
      queryParameters: {'q': query, 'category': widget.initialCategory},
    );
  }

  void _clearRecent(int index) {
    setState(() => _recentSearches.removeAt(index));
  }

  void _clearAllRecent() {
    setState(() => _recentSearches.clear());
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        titleSpacing: 0,
        leading: CustomBackButton(),

        title: EcommerceSearchBar(
          controller: _ctrl,
          autoFocus: true,
          onSubmitted: _goResults,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black38, height: 1),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.05,
            vertical: sh * 0.025,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Category chips ──────────────────────────────────────
              _buildSectionLabel('Browse by Category', sw),
              SizedBox(height: sh * 0.012),
              _buildCategoryChips(sw, sh),
              SizedBox(height: sh * 0.03),

              // ── Recent searches ──────────────────────────────────────
              if (_recentSearches.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionLabel('Recent Searches', sw),
                    GestureDetector(
                      onTap: _clearAllRecent,
                      child: Text(
                        'Clear all',
                        style: TextStyle(
                          fontSize: sw * 0.031,
                          color: AppColors.darkPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh * 0.012),
                _buildRecentList(sw, sh),
                SizedBox(height: sh * 0.03),
              ],

              // ── Trending ─────────────────────────────────────────────
              _buildSectionLabel('Trending Now', sw),
              SizedBox(height: sh * 0.012),
              _buildTrendingGrid(sw, sh),
              SizedBox(height: sh * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String text, double sw) {
    return Text(
      text,
      style: TextStyle(
        fontSize: sw * 0.038,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCategoryChips(double sw, double sh) {
    const icons = <String, IconData>{
      'All': Icons.apps_rounded,
      'Food': Icons.restaurant_rounded,
      'Toys': Icons.toys_rounded,
      'Accessories': Icons.star_outline_rounded,
      'Health': Icons.favorite_outline_rounded,
    };

    return Wrap(
      spacing: sw * 0.025,
      runSpacing: sw * 0.025,
      children: _categories.map((cat) {
        return GestureDetector(
          onTap: () => _goResults(cat == 'All' ? '' : cat),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sh * 0.009,
            ),
            decoration: BoxDecoration(
              color: AppColors.darkPink.withOpacity(0.08),
              borderRadius: BorderRadius.circular(sw * 0.03),
              border: Border.all(
                color: AppColors.darkPink.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icons[cat] ?? Icons.label_outline,
                  size: sw * 0.038,
                  color: AppColors.darkPink,
                ),
                SizedBox(width: sw * 0.015),
                Text(
                  cat,
                  style: TextStyle(
                    fontSize: sw * 0.032,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkPink,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentList(double sw, double sh) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(sw * 0.04),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentSearches.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, indent: sw * 0.12, color: Colors.black38),
        itemBuilder: (context, i) {
          final term = _recentSearches[i];
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: 0,
            ),
            leading: Icon(
              Icons.history_rounded,
              size: sw * 0.045,
              color: Colors.black38,
            ),
            title: Text(
              term,
              style: TextStyle(fontSize: sw * 0.035, color: Colors.black87),
            ),
            trailing: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.close_rounded,
                size: sw * 0.04,
                color: Colors.black38,
              ),
              onPressed: () => _clearRecent(i),
            ),
            onTap: () {
              _ctrl.text = term;
              _goResults(term);
            },
          );
        },
      ),
    );
  }

  Widget _buildTrendingGrid(double sw, double sh) {
    return Wrap(
      spacing: sw * 0.025,
      runSpacing: sw * 0.025,
      children: _trending.map((item) {
        return GestureDetector(
          onTap: () {
            _ctrl.text = item['label'] as String;
            _goResults(item['label'] as String);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sh * 0.009,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(sw * 0.03),
              border: Border.all(color: Colors.black12, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: sw * 0.036,
                  color: Colors.orange,
                ),
                SizedBox(width: sw * 0.015),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: sw * 0.032,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
