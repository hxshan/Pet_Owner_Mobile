import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_pet_model.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/adoption/adoption_pet_card.dart';
import 'package:pet_owner_mobile/widgets/adoption/pet_matching_model.dart';

class PetListingDashboard extends StatefulWidget {
  const PetListingDashboard({Key? key}) : super(key: key);

  @override
  State<PetListingDashboard> createState() => _PetListingDashboardState();
}

class _PetListingDashboardState extends State<PetListingDashboard> {
  String searchQuery = '';
  String selectedCategory = 'All';

  final List<String> categories = ['All', 'Dogs', 'Cats', 'Birds', 'Others'];

  // Sample pet data
  final List<AdoptionPet> pets = [
    AdoptionPet(
      name: 'Princess',
      image: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee',
      age: 3,
      gender: 'Female',
      location: 'Kurunegala, Adoption center',
      breed: 'Persian Cat',
      isFavorite: true,
    ),
    AdoptionPet(
      name: 'Max',
      image: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb',
      age: 5,
      gender: 'Male',
      location: 'Colombo, Pet Shelter',
      breed: 'Golden Retriever',
    ),
    AdoptionPet(
      name: 'Luna',
      image: 'https://images.unsplash.com/photo-1574158622682-e40e69881006',
      age: 2,
      gender: 'Female',
      location: 'Kandy, Adoption center',
      breed: 'Tabby Cat',
    ),
    AdoptionPet(
      name: 'Charlie',
      image: 'https://images.unsplash.com/photo-1561037404-61cd46aa615b',
      age: 4,
      gender: 'Male',
      location: 'Galle, Pet Rescue',
      breed: 'Beagle',
    ),
    AdoptionPet(
      name: 'Bella',
      image: 'https://images.unsplash.com/photo-1573865526739-10c1d3a1f0cc',
      age: 1,
      gender: 'Female',
      location: 'Negombo, Animal Shelter',
      breed: 'Siamese Cat',
    ),
  ];

  List<AdoptionPet> get filteredPets {
    return pets.where((pet) {
      final matchesSearch =
          pet.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          pet.breed.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == 'All' ||
          pet.breed.toLowerCase().contains(selectedCategory.toLowerCase());
      return matchesSearch && matchesCategory;
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
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

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top Searched Banner
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Top Searched',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Charming adoption',
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

                  // Category Filter
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
                        final isSelected =
                            selectedCategory == categories[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = categories[index];
                            });
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
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Center(
                              child: Text(
                                categories[index],
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

                  // Best Buddies Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          '${filteredPets.length} Pets',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Pet List
                  filteredPets.isEmpty
                      ? SizedBox(
                          height: 200.h,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          itemCount: filteredPets.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: PetCard(
                                pet: filteredPets[index],
                                onTap: () {
                                  // Navigate to pet details page with Pet object
                                  context.pushNamed(
                                    'PetDetailsPage',
                                    extra:
                                        filteredPets[index], // Pass the Pet object
                                  );
                                },
                                onFavoriteToggle: (isFavorite) {
                                  print(
                                    '${filteredPets[index].name} favorite: $isFavorite',
                                  );
                                },
                              ),
                            );
                          },
                        ),

                  // Bottom padding to prevent content being hidden by bottom nav
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAiPetMatchModal(context);
        },
        backgroundColor: AppColors.darkPink,
        child: Icon(Icons.auto_awesome, color: Colors.white, size: 28.sp),
      ),
    );
  }
}
