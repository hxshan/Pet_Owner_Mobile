import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_pet_model.dart';
import 'package:pet_owner_mobile/services/adoption_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/adoption/adoption_pet_card.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class PetListingDashboard extends StatefulWidget {
  const PetListingDashboard({Key? key}) : super(key: key);

  @override
  State<PetListingDashboard> createState() => _PetListingDashboardState();
}

class _PetListingDashboardState extends State<PetListingDashboard> {
  final AdoptionService _service = AdoptionService();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<AdoptionPet> _pets = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Maps category labels → species filter sent to backend
  static const Map<String, String?> _categorySpecies = {
    'All': null,
    'Dogs': 'Dog',
    'Cats': 'Cat',
    'Birds': 'Bird',
    'Others': null,
  };

  final List<String> categories = ['All', 'Dogs', 'Cats', 'Birds', 'Others'];

  @override
  void initState() {
    super.initState();
    _loadPets();
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
        leading: const CustomBackButton(),
        title: Text(
          'PetConnect',
          style: TextStyle(
            color: AppColors.darkPink,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
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
        onRefresh: () => _loadPets(
          species: _categorySpecies[_selectedCategory],
        ),
        child: Column(
          children: [
            // ── Search Bar ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  style: TextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Search Pet',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 20.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ),

            // ── Scrollable content ────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkPink,
                      ),
                    )
                  : _errorMessage != null
                  ? _buildErrorState()
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // ── Banner ──────────────────────────────────────
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            height: 140.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.mainColor,
                                  AppColors.darkPink.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 20.w,
                                  top: 20.h,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Find Your Best Buddy',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Adopt, don\'t shop 🐾',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 10.w,
                                  bottom: 10.h,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 25.r,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.pets,
                                          color: AppColors.darkPink,
                                          size: 24.sp,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      CircleAvatar(
                                        radius: 30.r,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.pets,
                                          color: AppColors.mainColor,
                                          size: 28.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Category Filter ──────────────────────────────
                          SizedBox(
                            height: 50.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                final isSelected = _selectedCategory == cat;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedCategory = cat);
                                    _loadPets(
                                      species: _categorySpecies[cat],
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 12.w),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.darkPink
                                          : AppColors.lightGray,
                                      borderRadius:
                                          BorderRadius.circular(20.r),
                                    ),
                                    child: Center(
                                      child: Text(
                                        cat,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black54,
                                          fontSize: 14.sp,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // ── List Header ──────────────────────────────────
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Best Buddies',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${_filteredPets.length} Pets',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Pet List ─────────────────────────────────────
                          if (_filteredPets.isEmpty)
                            SizedBox(
                              height: 200.h,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.pets,
                                      size: 64.sp,
                                      color: AppColors.mainColor,
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'No pets found',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              itemCount: _filteredPets.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12.h),
                                  child: PetCard(
                                    pet: _filteredPets[index],
                                    onTap: () => context.pushNamed(
                                      'PetDetailsPage',
                                      extra: _filteredPets[index],
                                    ),
                                    onFavoriteToggle: (_) {},
                                  ),
                                );
                              },
                            ),

                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
            ),
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
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

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
              style: TextStyle(fontSize: 15.sp, color: Colors.grey),
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
