import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/vet/vet_model.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class VetDetailScreen extends StatelessWidget {
  final VetModel vet;

  const VetDetailScreen({super.key, required this.vet});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: Stack(
        children: [
          // Scrollable content 
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: sh * 0.12 + bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Header 
                _HeroHeader(vet: vet, sw: sw, sh: sh, topPadding: topPadding),

                SizedBox(height: sh * 0.018),

                // Contact chips 
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                  child: _ContactRow(vet: vet, sw: sw, sh: sh),
                ),

                SizedBox(height: sh * 0.022),

                // About 
                _SectionCard(
                  sw: sw,
                  sh: sh,
                  title: 'About',
                  child: Text(
                    // TODO: replace with vet.bio from your API
                    '${vet.name} is a dedicated veterinary professional with over '
                    '10 years of experience in ${vet.specialization.toLowerCase()}. '
                    'Committed to providing compassionate, high-quality care for pets '
                    'of all kinds. The clinic is equipped with modern diagnostic tools '
                    'and a caring, experienced team.',
                    style: TextStyle(
                      fontSize: sw * 0.036,
                      color: const Color(0xFF555555),
                      height: 1.65,
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.014),

                // Gallery 
                _SectionCard(
                  sw: sw,
                  sh: sh,
                  title: 'Gallery',
                  child: SizedBox(
                    height: sh * 0.155,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mockGallery.length,
                      separatorBuilder: (_, __) => SizedBox(width: sw * 0.03),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () =>
                              _showGalleryViewer(context, index, sw, sh),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                            child: Container(
                              width: sh * 0.155,
                              height: sh * 0.155,
                              color: AppColors.mainColor.withOpacity(
                                0.25 + index * 0.08,
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // TODO: replace with real Image.network(url)
                                  Icon(
                                    _mockGallery[index].icon,
                                    color: AppColors.darkPink.withOpacity(0.4),
                                    size: sw * 0.12,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: sh * 0.006,
                                        horizontal: sw * 0.02,
                                      ),
                                      color: Colors.black26,
                                      child: Text(
                                        _mockGallery[index].label,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: sw * 0.026,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.014),

                // Services 
                _SectionCard(
                  sw: sw,
                  sh: sh,
                  title: 'Services',
                  child: Wrap(
                    spacing: sw * 0.025,
                    runSpacing: sh * 0.01,
                    children: _mockServices
                        .map((s) => _ServiceChip(label: s, sw: sw, sh: sh))
                        .toList(),
                  ),
                ),

                SizedBox(height: sh * 0.014),

                // Opening Hours 
                _SectionCard(
                  sw: sw,
                  sh: sh,
                  title: 'Opening Hours',
                  child: Column(
                    children: _mockHours.entries
                        .map(
                          (e) => _HoursRow(
                            day: e.key,
                            hours: e.value,
                            isToday: e.key == _todayName(),
                            sw: sw,
                            sh: sh,
                          ),
                        )
                        .toList(),
                  ),
                ),

                SizedBox(height: sh * 0.014),

                // Reviews 
                _SectionCard(
                  sw: sw,
                  sh: sh,
                  title: 'Reviews',
                  trailing: _RatingBadge(rating: vet.rating, sw: sw),
                  child: Column(
                    children: _mockReviews
                        .map((r) => _ReviewTile(review: r, sw: sw, sh: sh))
                        .toList(),
                  ),
                ),

                SizedBox(height: sh * 0.014),

                // Location 
                _SectionCard(
                  sw: sw,
                  sh: sh,
                  title: 'Location',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Map placeholder
                      ClipRRect(
                        borderRadius: BorderRadius.circular(sw * 0.03),
                        child: Container(
                          width: double.infinity,
                          height: sh * 0.2,
                          color: AppColors.mainColor.withOpacity(0.18),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: sw * 0.2,
                                color: AppColors.darkPink.withOpacity(0.12),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_pin,
                                    color: AppColors.darkPink,
                                    size: sw * 0.1,
                                  ),
                                  SizedBox(height: sh * 0.006),
                                  Text(
                                    'Map Preview',
                                    style: TextStyle(
                                      color: AppColors.darkPink,
                                      fontSize: sw * 0.034,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Replace with flutter_map or google_maps_flutter',
                                    style: TextStyle(
                                      color: AppColors.darkPink.withOpacity(
                                        0.6,
                                      ),
                                      fontSize: sw * 0.026,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: sh * 0.014),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: AppColors.darkPink,
                            size: sw * 0.042,
                          ),
                          SizedBox(width: sw * 0.02),
                          Expanded(
                            child: Text(
                              vet.address,
                              style: TextStyle(
                                fontSize: sw * 0.036,
                                color: const Color(0xFF444444),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: launch maps with vet coordinates
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.032,
                                vertical: sh * 0.009,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.mainColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(sw * 0.02),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.directions_outlined,
                                    color: AppColors.darkPink,
                                    size: sw * 0.036,
                                  ),
                                  SizedBox(width: sw * 0.012),
                                  Text(
                                    'Directions',
                                    style: TextStyle(
                                      color: AppColors.darkPink,
                                      fontSize: sw * 0.032,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: sh * 0.014),
              ],
            ),
          ),

          // ── Sticky Book Now button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                sw * 0.04,
                sh * 0.014,
                sw * 0.04,
                bottomPadding + sh * 0.014,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: sh * 0.062,
                child: ElevatedButton(
                  onPressed: () {
                    context.pushNamed('VetBookingScreen', extra: vet);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.03),
                    ),
                  ),
                  child: Text(
                    'Book Now',
                    style: TextStyle(
                      fontSize: sw * 0.044,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGalleryViewer(
    BuildContext context,
    int initialIndex,
    double sw,
    double sh,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) =>
          _GalleryViewer(initialIndex: initialIndex, sw: sw, sh: sh),
    );
  }
}

// ── Gallery full-screen viewer ─────────────────────────────────────────────────
class _GalleryViewer extends StatefulWidget {
  final int initialIndex;
  final double sw, sh;
  const _GalleryViewer({
    required this.initialIndex,
    required this.sw,
    required this.sh,
  });

  @override
  State<_GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<_GalleryViewer> {
  late PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = widget.sw;
    final sh = widget.sh;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _mockGallery.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => Center(
              child: Container(
                width: sw * 0.85,
                height: sh * 0.5,
                decoration: BoxDecoration(
                  color: AppColors.mainColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(sw * 0.04),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _mockGallery[i].icon,
                      color: AppColors.darkPink,
                      size: sw * 0.2,
                    ),
                    SizedBox(height: sh * 0.02),
                    Text(
                      _mockGallery[i].label,
                      style: TextStyle(
                        color: AppColors.darkPink,
                        fontSize: sw * 0.042,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            top: sh * 0.05,
            right: sw * 0.04,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(sw * 0.02),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: sw * 0.05,
                ),
              ),
            ),
          ),
          // Dot indicators
          Positioned(
            bottom: sh * 0.08,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _mockGallery.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: sw * 0.01),
                  width: i == _current ? sw * 0.04 : sw * 0.02,
                  height: sw * 0.02,
                  decoration: BoxDecoration(
                    color: i == _current ? AppColors.darkPink : Colors.white54,
                    borderRadius: BorderRadius.circular(sw * 0.01),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Header ───────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final VetModel vet;
  final double sw, sh, topPadding;

  const _HeroHeader({
    required this.vet,
    required this.sw,
    required this.sh,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.darkPink,
      padding: EdgeInsets.only(
        top: topPadding + sh * 0.015,
        left: sw * 0.04,
        right: sw * 0.04,
        bottom: sh * 0.032,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back
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
          SizedBox(height: sh * 0.022),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: sw * 0.22,
                height: sw * 0.22,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(sw * 0.04),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: vet.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(sw * 0.04),
                        child: Image.network(vet.imageUrl, fit: BoxFit.cover),
                      )
                    : Icon(
                        Icons.local_hospital_outlined,
                        color: Colors.white,
                        size: sw * 0.1,
                      ),
              ),
              SizedBox(width: sw * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vet.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sw * 0.052,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: sh * 0.005),
                    Text(
                      vet.specialization,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: sw * 0.034,
                      ),
                    ),
                    SizedBox(height: sh * 0.01),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.025,
                            vertical: sh * 0.004,
                          ),
                          decoration: BoxDecoration(
                            color: vet.isOpen
                                ? Colors.green.shade400
                                : Colors.red.shade400,
                            borderRadius: BorderRadius.circular(sw * 0.02),
                          ),
                          child: Text(
                            vet.isOpen ? '● Open' : '● Closed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sw * 0.028,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: sw * 0.02),
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFFFC107),
                          size: sw * 0.038,
                        ),
                        SizedBox(width: sw * 0.008),
                        Text(
                          '${vet.rating.toStringAsFixed(1)} (${vet.reviewCount})',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sw * 0.032,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Contact row ───────────────────────────────────────────────────────────────
class _ContactRow extends StatelessWidget {
  final VetModel vet;
  final double sw, sh;

  const _ContactRow({required this.vet, required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ContactChip(
            icon: Icons.phone_outlined,
            label: 'Call',
            onTap: () {}, // TODO: url_launcher tel:
            sw: sw,
            sh: sh,
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: _ContactChip(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Message',
            onTap: () {}, // TODO: url_launcher sms:
            sw: sw,
            sh: sh,
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: _ContactChip(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () {}, // TODO: Share.share()
            sw: sw,
            sh: sh,
          ),
        ),
      ],
    );
  }
}

class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double sw, sh;

  const _ContactChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: sh * 0.014),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.darkPink, size: sw * 0.055),
            SizedBox(height: sh * 0.005),
            Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.031,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF444444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section card wrapper ──────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final double sw, sh;
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.sw,
    required this.sh,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(sw * 0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: sw * 0.042,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            SizedBox(height: sh * 0.014),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Service chip ──────────────────────────────────────────────────────────────
class _ServiceChip extends StatelessWidget {
  final String label;
  final double sw, sh;

  const _ServiceChip({required this.label, required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.033,
        vertical: sh * 0.008,
      ),
      decoration: BoxDecoration(
        color: AppColors.mainColor.withOpacity(0.25),
        borderRadius: BorderRadius.circular(sw * 0.05),
        border: Border.all(
          color: AppColors.darkPink.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: sw * 0.032,
          color: AppColors.darkPink,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Hours row ─────────────────────────────────────────────────────────────────
class _HoursRow extends StatelessWidget {
  final String day, hours;
  final bool isToday;
  final double sw, sh;

  const _HoursRow({
    required this.day,
    required this.hours,
    required this.isToday,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.009),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                day,
                style: TextStyle(
                  fontSize: sw * 0.035,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  color: isToday ? AppColors.darkPink : const Color(0xFF444444),
                ),
              ),
              if (isToday) ...[
                SizedBox(width: sw * 0.015),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.018,
                    vertical: sh * 0.002,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mainColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      fontSize: sw * 0.026,
                      color: AppColors.darkPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: sw * 0.035,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
              color: isToday ? AppColors.darkPink : const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rating badge ──────────────────────────────────────────────────────────────
class _RatingBadge extends StatelessWidget {
  final double rating, sw;

  const _RatingBadge({required this.rating, required this.sw});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          color: const Color(0xFFFFC107),
          size: sw * 0.042,
        ),
        SizedBox(width: sw * 0.01),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: sw * 0.038,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }
}

// ── Review tile ───────────────────────────────────────────────────────────────
class _ReviewTile extends StatelessWidget {
  final _Review review;
  final double sw, sh;

  const _ReviewTile({required this.review, required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.016),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: sw * 0.05,
                backgroundColor: AppColors.mainColor.withOpacity(0.4),
                child: Text(
                  review.author[0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.darkPink,
                    fontWeight: FontWeight.w700,
                    fontSize: sw * 0.038,
                  ),
                ),
              ),
              SizedBox(width: sw * 0.028),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author,
                      style: TextStyle(
                        fontSize: sw * 0.036,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFFFC107),
                          size: sw * 0.034,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                review.date,
                style: TextStyle(
                  fontSize: sw * 0.029,
                  color: const Color(0xFFAAAAAA),
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.008),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: sw * 0.034,
              color: const Color(0xFF555555),
              height: 1.5,
            ),
          ),
          if (review != _mockReviews.last)
            Padding(
              padding: EdgeInsets.only(top: sh * 0.014),
              child: const Divider(height: 1, color: Color(0xFFF0F0F0)),
            ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
String _todayName() {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return days[DateTime.now().weekday - 1];
}

// ── Mock data ─────────────────────────────────────────────────────────────────
class _GalleryItem {
  final IconData icon;
  final String label;
  const _GalleryItem({required this.icon, required this.label});
}

const List<_GalleryItem> _mockGallery = [
  _GalleryItem(icon: Icons.local_hospital_outlined, label: 'Reception'),
  _GalleryItem(icon: Icons.biotech_outlined, label: 'Lab'),
  _GalleryItem(icon: Icons.vaccines_outlined, label: 'Vaccine Room'),
  _GalleryItem(icon: Icons.monitor_heart_outlined, label: 'ICU'),
  _GalleryItem(icon: Icons.pets, label: 'Recovery'),
];

const List<String> _mockServices = [
  'General Check-up',
  'Vaccinations',
  'Dental Care',
  'Surgery',
  'X-Ray & Imaging',
  'Microchipping',
  'Nutrition Advice',
  'Emergency Care',
  'Grooming',
  'Lab Tests',
];

const Map<String, String> _mockHours = {
  'Monday': '9:00 AM – 6:00 PM',
  'Tuesday': '9:00 AM – 6:00 PM',
  'Wednesday': '9:00 AM – 6:00 PM',
  'Thursday': '9:00 AM – 8:00 PM',
  'Friday': '9:00 AM – 6:00 PM',
  'Saturday': '10:00 AM – 4:00 PM',
  'Sunday': 'Closed',
};

class _Review {
  final String author, comment, date;
  final int rating;
  const _Review({
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

const List<_Review> _mockReviews = [
  _Review(
    author: 'Emma R.',
    rating: 5,
    comment:
        'Absolutely wonderful experience. The staff was kind and my cat felt very comfortable. Highly recommend!',
    date: 'Jan 2025',
  ),
  _Review(
    author: 'James T.',
    rating: 4,
    comment:
        'Very professional and thorough. Wait time was a little long but the quality of care was excellent.',
    date: 'Dec 2024',
  ),
  _Review(
    author: 'Priya M.',
    rating: 5,
    comment:
        'Took my dog here for the first time and it was a great experience. Will definitely be coming back.',
    date: 'Nov 2024',
  ),
];
