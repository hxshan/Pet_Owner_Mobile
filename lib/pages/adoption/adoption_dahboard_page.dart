import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_pet_model.dart';
import 'package:pet_owner_mobile/services/adoption_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/adoption/adoption_pet_card.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

// ── Category data ─────────────────────────────────────────────────────────────
class _Category {
  final String label;
  final String? species;
  final String? iconAsset;
  final String? emoji;
  final IconData? icon;
  final Color color;

  const _Category({
    required this.label,
    this.species,
    this.iconAsset,
    this.emoji,
    this.icon,
    required this.color,
  });
}

const _categories = <_Category>[
  _Category(
    label: 'All',
    species: null,
    icon: Icons.pets,
    color: Color(0xFFE0E0E0),
  ),
  _Category(
    label: 'Dog',
    species: 'Dog',
    iconAsset: 'assets/icons/dog.png',
    color: Color(0xFFF0A8D0),
  ),
  _Category(
    label: 'Cat',
    species: 'Cat',
    iconAsset: 'assets/icons/cat.png',
    color: Color(0xFF5BBCFF),
  ),
  _Category(
    label: 'Bird',
    species: 'Bird',
    iconAsset: 'assets/icons/bird.png',
    color: Color(0xFFA8DF65),
  ),
  _Category(
    label: 'Rabbit',
    species: 'Rabbit',
    emoji: '🐇',
    color: Color(0xFFFFC764),
  ),
];

// ── Carousel slide data ────────────────────────────────────────────────────────
class _Slide {
  final String imagePath;
  final String text;
  const _Slide(this.imagePath, this.text);
}

const _slides = <_Slide>[
  _Slide('assets/banners/slide1.jpg', 'Puppies for adopt'),
  _Slide('assets/banners/slide2.jpg', 'Get a companion here'),
  _Slide('assets/banners/slide3.jpg', 'Cute pets'),
];

// ── Page ──────────────────────────────────────────────────────────────────────
class PetListingDashboard extends StatefulWidget {
  const PetListingDashboard({Key? key}) : super(key: key);

  @override
  State<PetListingDashboard> createState() => _PetListingDashboardState();
}

class _PetListingDashboardState extends State<PetListingDashboard> {
  final AdoptionService _service = AdoptionService();

  // Carousel
  late PageController _pageController;
  int _currentSlide = 0;
  Timer? _carouselTimer;

  // Search & filter
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  // Data
  List<AdoptionPet> _pets = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startCarouselTimer();
    _loadPets();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = (_currentSlide + 1) % _slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  Future<void> _loadPets({String? species}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final pets = await _service.fetchPets(species: species);
      setState(() => _pets = pets);
    } catch (_) {
      setState(() => _errorMessage = 'Failed to load pets. Pull to refresh.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectCategory(int index) {
    setState(() => _selectedCategoryIndex = index);
    _loadPets(species: _categories[index].species);
  }

  List<AdoptionPet> get _filteredPets {
    if (_searchQuery.isEmpty) return _pets;
    final q = _searchQuery.toLowerCase();
    return _pets.where((pet) {
      return pet.name.toLowerCase().contains(q) ||
          pet.breed.toLowerCase().contains(q) ||
          pet.species.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: const CustomBackButton(),
        title: Text(
          'PetConnect',
          style: TextStyle(
            color: AppColors.darkPink,
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.black,
              size: 24.sp,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.darkPink,
        onRefresh: () =>
            _loadPets(species: _categories[_selectedCategoryIndex].species),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppColors.darkPink),
              )
            : _errorMessage != null
            ? _buildErrorState()
            : ListView(
                children: [
                  _buildSearchBar(),
                  SizedBox(height: 20.h),
                  _buildCarousel(),
                  SizedBox(height: 12.h),
                  _buildAdoptionCenterButton(),
                  SizedBox(height: 20.h),
                  _buildCategories(),
                  SizedBox(height: 20.h),
                  _buildBestBuddies(),
                  SizedBox(height: 24.h),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('AdvancedSearchPage'),
        backgroundColor: AppColors.darkPink,
        icon: Icon(Icons.auto_awesome, color: Colors.white, size: 22.sp),
        label: Text(
          'AI Search',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.only(top: 12.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Search pet',
          hintStyle: TextStyle(
            color: const Color.fromARGB(255, 125, 125, 125),
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.sp),
          suffixIcon: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                VerticalDivider(
                  color: Colors.grey.withOpacity(0.3),
                  indent: 8.h,
                  endIndent: 8.h,
                  thickness: 2,
                ),
                GestureDetector(
                  onTap: () => context.pushNamed('AdvancedSearchPage'),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Icon(
                      Icons.tune,
                      color: Colors.grey,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15.w),
        ),
      ),
    );
  }

  // ── Carousel ───────────────────────────────────────────────────────────────
  Widget _buildCarousel() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentSlide = i),
                itemBuilder: (ctx, i) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        _slides[i].imagePath,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10.h,
                        left: 15.w,
                        child: Text(
                          _slides[i].text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (i) {
              final isActive = i == _currentSlide;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: isActive ? 12.w : 8.w,
                height: isActive ? 6.h : 4.h,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.darkPink
                      : const Color.fromARGB(255, 217, 211, 211),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Soft-themed adoption center button ────────────────────────────────────
  Widget _buildAdoptionCenterButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: () => context.pushNamed('AdoptionCenterHomeScreen'),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.darkPink.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppColors.darkPink.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 16.sp,
                  color: AppColors.darkPink,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Find Adoption Centers Near You',
                style: TextStyle(
                  color: AppColors.darkPink,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12.sp,
                color: AppColors.darkPink.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Categories (icon cards) ────────────────────────────────────────────────
  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Text(
            'Categories',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 15.h),
        SizedBox(
          height: 130.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 20.w, right: 16.w),
            separatorBuilder: (_, __) => SizedBox(width: 20.w),
            itemCount: _categories.length,
            itemBuilder: (ctx, i) {
              final cat = _categories[i];
              final isSelected = _selectedCategoryIndex == i;
              return GestureDetector(
                onTap: () => _selectCategory(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: 90.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cat.color.withOpacity(0.75)
                        : cat.color.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: _buildCategoryIcon(cat),
                        ),
                      ),
                      Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(_Category cat) {
    if (cat.iconAsset != null) {
      return Image.asset(cat.iconAsset!, fit: BoxFit.contain);
    }
    if (cat.emoji != null) {
      return Center(
        child: Text(cat.emoji!, style: TextStyle(fontSize: 28.sp)),
      );
    }
    return Icon(cat.icon ?? Icons.pets, color: Colors.grey[600], size: 28.sp);
  }

  // ── Best Buddies list ──────────────────────────────────────────────────────
  Widget _buildBestBuddies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Text(
            'Best Buddies',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 15.h),
        if (_filteredPets.isEmpty)
          SizedBox(
            height: 180.h,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 60.sp, color: AppColors.mainColor),
                  SizedBox(height: 12.h),
                  Text(
                    'No pets found',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _filteredPets.length,
            separatorBuilder: (_, __) => SizedBox(height: 20.h),
            itemBuilder: (ctx, i) {
              final pet = _filteredPets[i];
              return PetCard(
                pet: pet,
                onTap: () => context.pushNamed('PetDetailsPage', extra: pet),
                onFavoriteToggle: (_) {},
              );
            },
          ),
      ],
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 60.sp, color: Colors.grey[300]),
            SizedBox(height: 16.h),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: _loadPets,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}