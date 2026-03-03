import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_pet_model.dart';
import 'package:pet_owner_mobile/consts/api_consts.dart';
import 'package:pet_owner_mobile/services/adoption_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/adoption/adoption_pet_card.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class AdvancedSearchPage extends StatefulWidget {
  const AdvancedSearchPage({Key? key}) : super(key: key);

  @override
  State<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  final AdoptionService _service = AdoptionService();

  // ── Tab ─────────────────────────────────────────────────────────────────
  bool _isAiTab = false;

  // ── Filter tab state ─────────────────────────────────────────────────────
  String? _selectedSpecies;
  String? _selectedGender;
  String? _selectedSize;
  String? _selectedEnergy;
  bool _goodWithKids = false;
  bool _goodWithPets = false;

  // ── AI Search tab state ───────────────────────────────────────────────────
  final TextEditingController _descController = TextEditingController();

  // ── Shared results ────────────────────────────────────────────────────────
  List<AdoptionPet> _results = [];
  List<String> _detectedFilters = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  // Stores the last LLM-extracted filters so we can generate per-pet reasons
  ExtractedFilters? _lastExtractedFilters;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  // ── Filter tab: call browse endpoint ──────────────────────────────────────
  Future<void> _showFilterResults() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
    });
    try {
      final pets = await _service.fetchPets(
        species: _selectedSpecies,
        gender: _selectedGender,
        size: _selectedSize,
        energyLevel: _selectedEnergy,
        goodWithKids: _goodWithKids ? true : null,
        goodWithPets: _goodWithPets ? true : null,
      );
      setState(() {
        _results = pets;
        _detectedFilters = [];
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load pets. Please try again.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── AI tab: LLM extract → recommendation endpoint ────────────────────────
  Future<void> _generateFilters() async {
    final desc = _descController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your ideal pet first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
      _detectedFilters = [];
    });

    try {
      // Step 1 — Ask LLM to extract structured filters from the text
      ExtractedFilters extracted = ExtractedFilters.empty();
      try {
        extracted = await _service.extractFiltersFromText(desc);
      } catch (_) {
        // LLM failed or key not set — continue without extracted filters
      }

      // Save for per-pet match reason generation
      _lastExtractedFilters = extracted;

      // Step 2 — Show detected filter chips immediately
      if (extracted.chipLabels.isNotEmpty) {
        setState(() => _detectedFilters = extracted.chipLabels);
      }

      // Step 3 — Call recommendation endpoint with both description + extracted prefs
      final result = await _service.getRecommendations(
        description: desc,
        preferredSpecies: extracted.species,
        preferredGender: extracted.gender,
        preferredSize: extracted.size,
        livingType: extracted.livingType ?? 'House',
        hasChildren: extracted.goodWithKids ?? false,
        hasOtherPets: extracted.goodWithPets ?? false,
        activityLevel: extracted.activityLevel ?? 'Moderate',
      );

      setState(() {
        _results = result.pets;
        // Merge: show LLM chips if available, else show backend relaxedFilters
        if (_detectedFilters.isEmpty) {
          _detectedFilters = result.relaxedFilters
              .map(_formatRelaxedFilter)
              .toList();
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not get recommendations. Please try again.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
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
          'Advanced Search',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Tab Toggle ───────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Row(
                children: [
                  _buildTabButton(
                    label: 'Filters',
                    icon: Icons.tune,
                    isSelected: !_isAiTab,
                    onTap: () => setState(() => _isAiTab = false),
                  ),
                  _buildTabButton(
                    label: 'AI Search',
                    icon: Icons.auto_awesome,
                    isSelected: _isAiTab,
                    onTap: () => setState(() => _isAiTab = true),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),

                  // Show either Filters or AI Search inputs
                  _isAiTab ? _buildAiSearchContent() : _buildFiltersContent(),

                  SizedBox(height: 20.h),

                  // ── Results area ──────────────────────────────────────────
                  if (_isLoading)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: CircularProgressIndicator(
                          color: AppColors.darkPink,
                        ),
                      ),
                    )
                  else if (_errorMessage != null)
                    _buildErrorState()
                  else if (_hasSearched)
                    _buildResultsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filters Tab ──────────────────────────────────────────────────────────
  Widget _buildFiltersContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterSection(
          title: 'Species',
          options: ['Dog', 'Cat'],
          selected: _selectedSpecies,
          onSelect: (v) => setState(
            () => _selectedSpecies = _selectedSpecies == v ? null : v,
          ),
        ),
        SizedBox(height: 20.h),
        _buildFilterSection(
          title: 'Gender',
          options: ['Male', 'Female'],
          selected: _selectedGender,
          onSelect: (v) => setState(
            () => _selectedGender = _selectedGender == v ? null : v,
          ),
        ),
        SizedBox(height: 20.h),
        _buildFilterSection(
          title: 'Size',
          options: ['Small', 'Medium', 'Large'],
          selected: _selectedSize,
          onSelect: (v) => setState(
            () => _selectedSize = _selectedSize == v ? null : v,
          ),
        ),
        SizedBox(height: 20.h),
        _buildFilterSection(
          title: 'Energy Level',
          options: ['Low', 'Moderate', 'High'],
          selected: _selectedEnergy,
          onSelect: (v) => setState(
            () => _selectedEnergy = _selectedEnergy == v ? null : v,
          ),
        ),
        SizedBox(height: 20.h),

        // Lifestyle toggles
        Text(
          'Lifestyle',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 10.w,
          children: [
            _buildToggleChip(
              label: 'Good With Kids',
              isSelected: _goodWithKids,
              onTap: () => setState(() => _goodWithKids = !_goodWithKids),
            ),
            _buildToggleChip(
              label: 'Good With Pets',
              isSelected: _goodWithPets,
              onTap: () => setState(() => _goodWithPets = !_goodWithPets),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        // Show Results button
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: _showFilterResults,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkPink,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Show Results',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ── AI Search Tab ─────────────────────────────────────────────────────────
  Widget _buildAiSearchContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Describe your ideal pet',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _descController,
            maxLines: 5,
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText:
                  'e.g. I live in a quiet apartment and want a calm, '
                  'low-energy pet that is good with kids...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 13.sp,
                height: 1.5,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14.w),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // LLM status note
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.mainColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                openRouterApiKey == 'YOUR_OPENROUTER_KEY_HERE'
                    ? Icons.info_outline
                    : Icons.auto_awesome,
                size: 16.sp,
                color: AppColors.darkPink,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  openRouterApiKey == 'YOUR_OPENROUTER_KEY_HERE'
                      ? 'AI filter extraction not connected. Results use similarity search only.'
                      : 'AI will extract filters from your description, then rank matches.',
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),

        // Generate Filters button
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton.icon(
            onPressed: _generateFilters,
            icon: Icon(Icons.auto_awesome, size: 18.sp),
            label: Text(
              'Generate Filters',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkPink,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),

        // Detected filters chips (from backend relaxedFilters)
        if (_detectedFilters.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Text(
            'Detected Filters:',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: _detectedFilters.map((f) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.mainColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  _formatRelaxedFilter(f),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.darkPink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ── Results Section ───────────────────────────────────────────────────────
  Widget _buildResultsSection() {
    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            children: [
              Icon(Icons.pets, size: 60.sp, color: AppColors.mainColor),
              SizedBox(height: 12.h),
              Text(
                'No pets found',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),
              SizedBox(height: 6.h),
              Text(
                'Try adjusting your filters',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Results (${_results.length})',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (_isAiTab) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.darkPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 12.sp,
                      color: AppColors.darkPink,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'AI Ranked',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.darkPink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 12.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final pet = _results[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PetCard(
                    pet: pet,
                    onTap: () =>
                        context.pushNamed('PetDetailsPage', extra: pet),
                    onFavoriteToggle: (_) {},
                  ),
                  // Match reason — shown only in AI Search tab
                  if (_isAiTab)
                    Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 12.sp,
                            color: AppColors.darkPink,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              _buildMatchReason(pet),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.darkPink,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 50.sp, color: Colors.redAccent),
            SizedBox(height: 12.h),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkPink : Colors.transparent,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? Colors.white : Colors.black54,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 8.h,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 18.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.darkPink : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkPink : AppColors.lightGray,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.darkPink : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check, size: 14.sp, color: Colors.white),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Match reason builder (AI Search tab only) ──────────────────────────────
  String _buildMatchReason(AdoptionPet pet) {
    final f = _lastExtractedFilters;

    // Build a score string if ML assigned a score
    final hasScore = pet.score != null && pet.score! > 0;
    final scoreStr = hasScore
        ? '${(pet.score! * 100).toStringAsFixed(0)}% match'
        : null;

    if (f == null || f.isEmpty) {
      // No LLM filters available — show score only or generic reason
      return scoreStr ?? 'Matched from your description';
    }

    // Compare extracted filters to pet attributes
    final matches = <String>[];
    if (f.species != null &&
        f.species!.toLowerCase() == pet.species.toLowerCase()) {
      matches.add(pet.species);
    }
    if (f.size != null && f.size == pet.size) {
      matches.add('${pet.size} size');
    }
    if (f.energyLevel != null && f.energyLevel == pet.energyLevel) {
      matches.add('${pet.energyLevel} energy');
    }
    if (f.goodWithKids == true && pet.goodWithKids == true) {
      matches.add('good with kids');
    }
    if (f.goodWithPets == true && pet.goodWithPets == true) {
      matches.add('pet-friendly');
    }
    if (f.gender != null &&
        f.gender!.toLowerCase() == pet.gender.toLowerCase()) {
      matches.add(pet.gender);
    }

    // Combine score + attribute matches
    if (scoreStr != null && matches.isNotEmpty) {
      return '$scoreStr · ${matches.join(', ')}';
    }
    if (scoreStr != null) return scoreStr;
    if (matches.isNotEmpty) return 'Matches: ${matches.join(', ')}';
    return 'Matched from your description';
  }

  String _formatRelaxedFilter(String filter) {
    // Convert camelCase backend filter names to readable labels
    switch (filter) {
      case 'color':
        return 'Color Relaxed';
      case 'breed':
        return 'Breed Relaxed';
      case 'energyLevel':
        return 'Energy Relaxed';
      case 'size':
        return 'Size Relaxed';
      default:
        return filter;
    }
  }
}
