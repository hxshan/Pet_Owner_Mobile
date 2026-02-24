import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/vet/vet_model.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/vet/vet_search_card.dart';

class VetSearchResultsScreen extends StatefulWidget {
  final String location;

  const VetSearchResultsScreen({super.key, required this.location});

  @override
  State<VetSearchResultsScreen> createState() => _VetSearchResultsScreenState();
}

class _VetSearchResultsScreenState extends State<VetSearchResultsScreen> {
  bool _isLoading = true;
  List<VetModel> _results = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchVets();
  }

  Future<void> _fetchVets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // TODO: Replace with your real API call:
      // final results = await VetService.searchByLocation(widget.location);
      await Future.delayed(const Duration(milliseconds: 1200));
      setState(() {
        _results = _mockVets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load vets. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            color: AppColors.darkPink,
            padding: EdgeInsets.only(
              top: topPadding + sh * 0.015,
              left: sw * 0.04,
              right: sw * 0.04,
              bottom: sh * 0.022,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: sw * 0.09,
                    height: sw * 0.09,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(sw * 0.025),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: sw * 0.042,
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.034),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vets near you',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.048,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: sh * 0.003),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.white70,
                            size: sw * 0.034,
                          ),
                          SizedBox(width: sw * 0.01),
                          Flexible(
                            child: Text(
                              widget.location,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: sw * 0.033,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Results count bar ────────────────────────────────────────
          if (!_isLoading && _error == null)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: sh * 0.012,
              ),
              child: Text(
                '${_results.length} veterinarians found',
                style: TextStyle(
                  fontSize: sw * 0.034,
                  color: const Color(0xFF666666),
                ),
              ),
            ),

          // ── Body ──────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? _LoadingState(sw: sw, sh: sh)
                : _error != null
                ? _ErrorState(
                    message: _error!,
                    onRetry: _fetchVets,
                    sw: sw,
                    sh: sh,
                  )
                : _results.isEmpty
                ? _EmptyState(sw: sw, sh: sh)
                : RefreshIndicator(
                    color: AppColors.darkPink,
                    onRefresh: _fetchVets,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.04,
                        vertical: sh * 0.02,
                      ),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => SizedBox(height: sh * 0.016),
                      itemBuilder: (context, index) {
                        final vet = _results[index];
                        return VetSearchCard(
                          vet: vet,
                          onCardTap: () =>
                              context.pushNamed('VetDetailsScreen', extra: vet),

                          onBookTap: () =>
                              context.pushNamed('VetDetailsScreen', extra: vet),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  final double sw, sh;
  const _LoadingState({required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.02),
      itemCount: 4,
      separatorBuilder: (_, __) => SizedBox(height: sh * 0.016),
      itemBuilder: (_, __) => _SkeletonCard(sw: sw, sh: sh),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double sw, sh;
  const _SkeletonCard({required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Shimmer(width: sw * 0.18, height: sw * 0.18, radius: sw * 0.03),
              SizedBox(width: sw * 0.036),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Shimmer(width: sw * 0.4, height: sh * 0.022),
                    SizedBox(height: sh * 0.008),
                    _Shimmer(width: sw * 0.28, height: sh * 0.016),
                    SizedBox(height: sh * 0.008),
                    _Shimmer(width: sw * 0.22, height: sh * 0.016),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.016),
          _Shimmer(width: double.infinity, height: sh * 0.055),
        ],
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  final double width, height, radius;
  const _Shimmer({required this.width, required this.height, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final double sw, sh;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: const Color(0xFFCCCCCC),
              size: sw * 0.18,
            ),
            SizedBox(height: sh * 0.02),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sw * 0.038,
                color: const Color(0xFF888888),
              ),
            ),
            SizedBox(height: sh * 0.024),
            SizedBox(
              height: sh * 0.057,
              width: sw * 0.5,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPink,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(sw * 0.026),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sw * 0.038,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final double sw, sh;
  const _EmptyState({required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              color: const Color(0xFFCCCCCC),
              size: sw * 0.18,
            ),
            SizedBox(height: sh * 0.02),
            Text(
              'No vets found in this area',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sw * 0.042,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF555555),
              ),
            ),
            SizedBox(height: sh * 0.008),
            Text(
              'Try a different location or expand your search area.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sw * 0.034,
                color: const Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mock data (replace with API) ──────────────────────────────────────────────
final List<VetModel> _mockVets = [
  const VetModel(
    id: '1',
    name: 'Dr. Sarah Mitchell',
    imageUrl: '',
    specialization: 'General Veterinarian',
    rating: 4.8,
    reviewCount: 124,
    address: '12 Maple Ave',
    distance: '0.8 km',
    openStatus: 'Until 6 PM',
    phone: '+1 555 010 0101',
    isOpen: true,
  ),
  const VetModel(
    id: '2',
    name: 'Paws & Claws Animal Clinic',
    imageUrl: '',
    specialization: 'Small Animal Specialist',
    rating: 4.5,
    reviewCount: 89,
    address: '45 Birch St',
    distance: '1.4 km',
    openStatus: 'Until 8 PM',
    phone: '+1 555 020 0202',
    isOpen: true,
  ),
  const VetModel(
    id: '3',
    name: 'Dr. James Okafor',
    imageUrl: '',
    specialization: 'Exotic Animals & Surgery',
    rating: 4.9,
    reviewCount: 210,
    address: '7 Oak Blvd',
    distance: '2.1 km',
    openStatus: 'Opens 9 AM',
    phone: '+1 555 030 0303',
    isOpen: false,
  ),
  const VetModel(
    id: '4',
    name: 'CityPet Veterinary Centre',
    imageUrl: '',
    specialization: 'Emergency & General Care',
    rating: 4.3,
    reviewCount: 56,
    address: '99 Elm Road',
    distance: '3.0 km',
    openStatus: '24 Hours',
    phone: '+1 555 040 0404',
    isOpen: true,
  ),
];
