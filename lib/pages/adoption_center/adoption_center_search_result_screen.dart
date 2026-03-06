import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/adoption/adoption_center_model.dart';
import 'package:pet_owner_mobile/services/adoption_center_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/adoption/adoption_center_card.dart';

class AdoptionCenterSearchResultScreen extends StatefulWidget {
  final String location;

  const AdoptionCenterSearchResultScreen({super.key, required this.location});

  @override
  State<AdoptionCenterSearchResultScreen> createState() =>
      _AdoptionCenterSearchResultScreenState();
}

class _AdoptionCenterSearchResultScreenState
    extends State<AdoptionCenterSearchResultScreen> {
  bool _isLoading = true;
  List<AdoptionCenter> _results = [];
  String? _error;
  String? _displayLocation;

  @override
  void initState() {
    super.initState();
    _fetchCenters();
  }

  Future<void> _fetchCenters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = AdoptionCenterService();
      List<AdoptionCenter> results;

      if (widget.location == 'Current Location') {
        // Check permissions and get current position
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.deniedForever ||
            permission == LocationPermission.denied) {
          throw Exception(
              'Location permission denied. Please enable location permissions and try again.');
        }

        final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        results = await service.searchCenters(
          lat: pos.latitude,
          lng: pos.longitude,
          page: 1,
          limit: 20,
        );
        _displayLocation =
            '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      } else {
        // Try to detect if location is provided as 'lat,lng'
        final parts = widget.location.split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          if (lat != null && lng != null) {
            results = await service.searchCenters(
              lat: lat,
              lng: lng,
              page: 1,
              limit: 20,
            );
          } else {
            results = await service.searchCenters(
              q: widget.location,
              page: 1,
              limit: 20,
            );
          }
        } else {
          results = await service.searchCenters(
            q: widget.location,
            page: 1,
            limit: 20,
          );
        }
      }

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : 'Failed to load adoption centers. Please try again.';
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
            decoration: BoxDecoration(
              color: AppColors.darkPink,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(sw * 0.06),
                bottomRight: Radius.circular(sw * 0.06),
              ),
            ),
            padding: EdgeInsets.only(
              top: topPadding + sh * 0.015,
              bottom: sh * 0.025,
              left: sw * 0.04,
              right: sw * 0.04,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: EdgeInsets.all(sw * 0.022),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(sw * 0.025),
                    ),
                    child: Icon(
                      Icons.arrow_back,
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
                        'Centers near you',
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

          // Results
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.darkPink,
                    ),
                  )
                : _error != null
                    ? _buildErrorState(sw, sh)
                    : _results.isEmpty
                        ? _buildEmptyState(sw, sh)
                        : RefreshIndicator(
                            color: AppColors.darkPink,
                            onRefresh: _fetchCenters,
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.04,
                                vertical: sh * 0.02,
                              ),
                              itemCount: _results.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: sh * 0.016),
                              itemBuilder: (context, index) {
                                final center = _results[index];
                                return AdoptionCenterCard(
                                  center: center,
                                  onTap: () {
                                    context.pushNamed(
                                      'AdoptionCenterDetailScreen',
                                      extra: center,
                                    );
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

  Widget _buildErrorState(double sw, double sh) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: const Color(0xFFCCCCCC),
              size: sw * 0.18,
            ),
            SizedBox(height: sh * 0.02),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: sw * 0.042,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF555555),
              ),
            ),
            SizedBox(height: sh * 0.015),
            ElevatedButton(
              onPressed: _fetchCenters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sw * 0.02),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(double sw, double sh) {
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
              'No adoption centers found',
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
