import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/models/vet/vet_model.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class VetSearchCard extends StatelessWidget {
  final VetModel vet;
  final VoidCallback? onBookTap;
  final VoidCallback? onCardTap;

  const VetSearchCard({
    super.key,
    required this.vet,
    this.onBookTap,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onCardTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row: Avatar + Info ───────────────────────────────────
            Padding(
              padding: EdgeInsets.all(sw * 0.04),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(sw * 0.03),
                    child: vet.imageUrl.isNotEmpty
                        ? Image.network(
                            vet.imageUrl,
                            width: sw * 0.18,
                            height: sw * 0.18,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _PlaceholderAvatar(sw: sw),
                          )
                        : _PlaceholderAvatar(sw: sw),
                  ),

                  SizedBox(width: sw * 0.036),

                  // Name, specialization, rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vet.name,
                          style: TextStyle(
                            fontSize: sw * 0.042,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E1E1E),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: sh * 0.004),
                        Text(
                          vet.specialization,
                          style: TextStyle(
                            fontSize: sw * 0.033,
                            color: const Color(0xFF888888),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: sh * 0.008),

                        // Rating row
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: const Color(0xFFFFC107),
                              size: sw * 0.042,
                            ),
                            SizedBox(width: sw * 0.01),
                            Text(
                              vet.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: sw * 0.035,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                            SizedBox(width: sw * 0.01),
                            Text(
                              '(${vet.reviewCount} reviews)',
                              style: TextStyle(
                                fontSize: sw * 0.031,
                                color: const Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Open / Closed badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.025,
                      vertical: sh * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: vet.isOpen
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFCE4E4),
                      borderRadius: BorderRadius.circular(sw * 0.02),
                    ),
                    child: Text(
                      vet.isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        fontSize: sw * 0.03,
                        fontWeight: FontWeight.w600,
                        color: vet.isOpen
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Divider ──────────────────────────────────────────────────
            Divider(
              height: 1,
              thickness: 1,
              color: const Color(0xFFF0F0F0),
              indent: sw * 0.04,
              endIndent: sw * 0.04,
            ),

            // ── Bottom info row ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: sh * 0.014,
              ),
              child: Row(
                children: [
                  // Address
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.location_on_outlined,
                      label: vet.address,
                      sw: sw,
                    ),
                  ),
                  SizedBox(width: sw * 0.02),
                  // Distance
                  _InfoChip(
                    icon: Icons.directions_walk_outlined,
                    label: vet.distance,
                    sw: sw,
                  ),
                  SizedBox(width: sw * 0.02),
                  // Hours
                  _InfoChip(
                    icon: Icons.access_time_outlined,
                    label: vet.openStatus,
                    sw: sw,
                  ),
                ],
              ),
            ),

            // ── Book Appointment Button ──────────────────────────────────
            Padding(
              padding: EdgeInsets.only(
                left: sw * 0.04,
                right: sw * 0.04,
                bottom: sw * 0.04,
              ),
              child: SizedBox(
                width: double.infinity,
                height: sh * 0.057,
                child: ElevatedButton(
                  onPressed: onBookTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.026),
                    ),
                  ),
                  child: Text(
                    'Book Appointment',
                    style: TextStyle(
                      fontSize: sw * 0.038,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
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

// ── Placeholder avatar when no image ─────────────────────────────────────────
class _PlaceholderAvatar extends StatelessWidget {
  final double sw;
  const _PlaceholderAvatar({required this.sw});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sw * 0.18,
      height: sw * 0.18,
      decoration: BoxDecoration(
        color: AppColors.mainColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(sw * 0.03),
      ),
      child: Icon(
        Icons.local_hospital_outlined,
        color: AppColors.darkPink,
        size: sw * 0.08,
      ),
    );
  }
}

// ── Small icon + label chip ───────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double sw;

  const _InfoChip({required this.icon, required this.label, required this.sw});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: sw * 0.036, color: AppColors.darkPink),
        SizedBox(width: sw * 0.01),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.03,
              color: const Color(0xFF666666),
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
