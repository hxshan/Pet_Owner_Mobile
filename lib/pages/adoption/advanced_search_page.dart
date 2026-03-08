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

class _AdvancedSearchPageState extends State<AdvancedSearchPage>
    with SingleTickerProviderStateMixin {
  final AdoptionService _service = AdoptionService();

  // ── Tab ─────────────────────────────────────────────────────────────────
  bool _isAiTab = false;
  late AnimationController _tabAnimController;
  late Animation<double> _tabScaleAnim;

  // ── Filter tab state ─────────────────────────────────────────────────────
  String? _selectedSpecies;
  String? _selectedGender;
  String? _selectedSize;
  String? _selectedEnergy;
  String? _selectedColor;
  bool _goodWithKids = false;
  bool _goodWithPets = false;
  final TextEditingController _filterDescController = TextEditingController();

  // ── AI Search tab state ───────────────────────────────────────────────────
  final TextEditingController _descController = TextEditingController();
  String? _aiError;

  // ── Shared results ────────────────────────────────────────────────────────
  List<AdoptionPet> _results = [];
  List<String> _detectedFilters = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  ExtractedFilters? _lastExtractedFilters;

  @override
  void initState() {
    super.initState();
    _tabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _tabScaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _tabAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _filterDescController.dispose();
    _tabAnimController.dispose();
    super.dispose();
  }

  // ── Filter tab: call ML recommendation endpoint ───────────────────────────
  Future<void> _showFilterResults() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
      _detectedFilters = [];
    });
    try {
      final result = await _service.getRecommendations(
        description: _filterDescController.text.trim(),
        preferredSpecies: _selectedSpecies,
        preferredGender: _selectedGender,
        preferredSize: _selectedSize,
        livingType: 'House',
        hasChildren: _goodWithKids,
        hasOtherPets: _goodWithPets,
        activityLevel: _selectedEnergy ?? 'Moderate',
        color: _selectedColor,
      );
      setState(() {
        _results = result.pets;
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
      _aiError = null;
      _detectedFilters = [];
    });

    try {
      ExtractedFilters extracted = ExtractedFilters.empty();
      try {
        extracted = await _service.extractFiltersFromText(desc);
      } catch (_) {}

      final isGibberish = extracted.species == null &&
          extracted.gender == null &&
          extracted.size == null &&
          extracted.energyLevel == null &&
          extracted.goodWithKids == null &&
          extracted.goodWithPets == null &&
          extracted.color == null &&
          extracted.detectedKeywords.isEmpty;

      if (isGibberish) {
        setState(() {
          _aiError =
              'Please describe what you\'re looking for more clearly, '
              'e.g. "calm golden dog, good with kids, apartment-friendly"';
          _isLoading = false;
          _hasSearched = false;
        });
        return;
      }

      _lastExtractedFilters = extracted;

      if (extracted.chipLabels.isNotEmpty) {
        setState(() => _detectedFilters = extracted.chipLabels);
      }

      final result = await _service.getRecommendations(
        description: desc,
        preferredSpecies: extracted.species,
        preferredGender: extracted.gender,
        preferredSize: extracted.size,
        livingType: extracted.livingType ?? 'House',
        hasChildren: extracted.goodWithKids ?? false,
        hasOtherPets: extracted.goodWithPets ?? false,
        activityLevel: extracted.energyLevel ?? 'Moderate',
        color: extracted.color,
      );

      setState(() {
        _results = result.pets;
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
          // ── Tab Toggle — card style matching dashboard categories ─────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
            child: Row(
              children: [
                _buildTabCard(
                  label: 'Filters',
                  subtitle: 'Manual pick',
                  icon: Icons.tune_rounded,
                  cardColor: const Color(0xFFF0A8D0),
                  isSelected: !_isAiTab,
                  onTap: () => setState(() => _isAiTab = false),
                ),
                SizedBox(width: 12.w),
                _buildTabCard(
                  label: 'AI Search',
                  subtitle: 'Smart match',
                  icon: Icons.auto_awesome_rounded,
                  cardColor: const Color(0xFF5BBCFF),
                  isSelected: _isAiTab,
                  onTap: () => setState(() => _isAiTab = true),
                ),
              ],
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
                  _isAiTab ? _buildAiSearchContent() : _buildFiltersContent(),
                  SizedBox(height: 20.h),
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

  // ── Tab Card (matches dashboard category card style) ─────────────────────
  Widget _buildTabCard({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color cardColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          height: 80.h,
          decoration: BoxDecoration(
            color: isSelected
                ? cardColor.withOpacity(0.55)
                : cardColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: cardColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon bubble — mirrors the white circle in category cards
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white70,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: isSelected ? AppColors.darkPink : Colors.black38,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.black87 : Colors.black45,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isSelected
                          ? Colors.black54
                          : Colors.black26,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        _buildFilterSection(
          title: 'Color',
          options: ['Black', 'Brown', 'Golden', 'Yellow', 'Cream', 'Gray', 'White'],
          selected: _selectedColor,
          onSelect: (v) => setState(
            () => _selectedColor = _selectedColor == v ? null : v,
          ),
        ),
        SizedBox(height: 20.h),
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
        SizedBox(height: 20.h),
        Text(
          'Describe what you\'re looking for (optional)',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _filterDescController,
            maxLines: 2,
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'e.g. calm dog good with kids, apartment-friendly...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 13.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12.w),
            ),
          ),
        ),
        SizedBox(height: 20.h),
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
            border: Border.all(
              color: _aiError != null
                  ? Colors.red.shade300
                  : Colors.grey.shade300,
            ),
          ),
          child: TextField(
            controller: _descController,
            maxLines: 5,
            style: TextStyle(fontSize: 14.sp),
            onChanged: (_) {
              if (_aiError != null) setState(() => _aiError = null);
            },
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
        if (_aiError != null) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 16.sp, color: Colors.red.shade600),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _aiError!,
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 16.h),
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
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
              Text('No pets found',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
              SizedBox(height: 6.h),
              Text('Try adjusting your filters',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[400])),
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
                  color: Colors.black87),
            ),
            SizedBox(width: 8.w),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: AppColors.darkPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome,
                      size: 12.sp, color: AppColors.darkPink),
                  SizedBox(width: 4.w),
                  Text('ML Ranked',
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.darkPink,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _results.length,
          itemBuilder: (context, index) {
            final pet = _results[index];
            final hasScore = pet.score != null && pet.score! > 0;
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
                  if (hasScore || _isAiTab)
                    Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 0),
                      child: Row(
                        children: [
                          if (hasScore) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                    color: Colors.green.shade200),
                              ),
                              child: Text(
                                '${(pet.score! * 100).toStringAsFixed(0)}% match',
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700),
                              ),
                            ),
                            SizedBox(width: 6.w),
                          ],
                          if (_isAiTab) ...[
                            Icon(Icons.auto_awesome,
                                size: 12.sp, color: AppColors.darkPink),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                _buildAttributeMatchReason(pet),
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.darkPink,
                                    fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 8.h,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.darkPink
                      : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color:
                        isSelected ? Colors.white : Colors.black54,
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
              color: isSelected ? AppColors.darkPink : Colors.transparent),
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
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildAttributeMatchReason(AdoptionPet pet) {
    final f = _lastExtractedFilters;
    if (f == null || f.isEmpty) return 'Matched from your description';

    final matches = <String>[];
    if (f.species != null &&
        f.species!.toLowerCase() == pet.species.toLowerCase()) {
      matches.add(pet.species);
    }
    if (f.size != null && f.size == pet.size) matches.add('${pet.size} size');
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
    if (f.color != null &&
        pet.color != null &&
        f.color!.toLowerCase() == pet.color!.toLowerCase()) {
      matches.add(f.color!);
    }

    if (matches.isNotEmpty) return 'Matches: ${matches.join(', ')}';
    return 'Matched from your description';
  }

  String _formatRelaxedFilter(String filter) {
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