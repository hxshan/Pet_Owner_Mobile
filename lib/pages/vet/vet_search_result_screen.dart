import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/vet/vet_model.dart';
import 'package:pet_owner_mobile/services/vet_service.dart';
import 'package:geolocator/geolocator.dart';
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
  String? _displayLocation;

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
      final service = VetService();
      // If caller passed the sentinel 'Current Location', acquire device GPS
      List<VetModel> results;
  if (widget.location == 'Current Location') {
        // Check permissions and get current position
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
          throw Exception('Location permission denied. Please enable location permissions and try again.');
        }

        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
        results = await service.searchVets(page: 1, limit: 20, lat: pos.latitude, lng: pos.longitude);
        // Update header to show coordinates instead of the sentinel
        _displayLocation = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      } else {
        // Try to detect if location is provided as 'lat,lng' (from other screens)
        final parts = widget.location.split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          if (lat != null && lng != null) {
            results = await service.searchVets(page: 1, limit: 20, lat: lat, lng: lng);
          } else {
            results = await service.searchVets(q: widget.location, page: 1, limit: 20);
          }
        } else {
          results = await service.searchVets(q: widget.location, page: 1, limit: 20);
        }
      }
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is Exception ? e.toString().replaceFirst('Exception: ', '') : 'Failed to load vets. Please try again.';
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
                                  _displayLocation ?? widget.location,
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
                          onCardTap: () async {
                            final service = VetService();
                            try {
                              final full = await service.getVetById(vet.id);
                              if (full != null) {
                                context.pushNamed('VetDetailsScreen', extra: full);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to load vet details')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.toString()}')),
                              );
                            }
                          },

                          onBookTap: () async {
                            final service = VetService();
                            try {
                              final full = await service.getVetById(vet.id);
                              if (full != null) {
                                context.pushNamed('VetBookingScreen', extra: full);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to load vet details')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.toString()}')),
                              );
                            }
                          },
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

// Note: mock data removed — real API is used via VetService.searchVets
