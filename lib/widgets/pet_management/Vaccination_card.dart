import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_owner_mobile/models/pet_management/vaccination_model.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class VaccinationCard extends StatelessWidget {
  final VaccinationModel vaccination;

  const VaccinationCard({super.key, required this.vaccination});

  // ── Status helpers ──────────────────────────────────────────────────────────
  Color get _statusColor {
    switch (vaccination.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF2E7D32);
      case 'overdue':
        return const Color(0xFFC62828);
      case 'upcoming':
      default:
        return const Color(0xFF1565C0);
    }
  }

  Color get _accentColor {
    switch (vaccination.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF2E7D32);
      case 'overdue':
        return const Color(0xFFC62828);
      case 'upcoming':
      default:
        return AppColors.darkPink;
    }
  }

  IconData get _statusIcon {
    switch (vaccination.status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'overdue':
        return Icons.error_outline_rounded;
      case 'upcoming':
      default:
        return Icons.schedule_rounded;
    }
  }

  String _formatDate(DateTime dt) =>
      DateFormat('dd MMM yyyy').format(dt);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    final accent = _accentColor;
    final statusColor = _statusColor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header band ─────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.045, vertical: sh * 0.015),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.07),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(sw * 0.04),
                topRight: Radius.circular(sw * 0.04),
              ),
            ),
            child: Row(
              children: [
                // Vaccine icon
                Container(
                  padding: EdgeInsets.all(sw * 0.028),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(sw * 0.025),
                  ),
                  child: Icon(Icons.vaccines_outlined,
                      color: accent, size: sw * 0.055),
                ),
                SizedBox(width: sw * 0.035),
                // Vaccine name + pet
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaccination.vaccineName,
                        style: TextStyle(
                          fontSize: sw * 0.042,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: sh * 0.003),
                      Row(
                        children: [
                          Icon(Icons.pets,
                              size: sw * 0.032,
                              color: const Color(0xFF888888)),
                          SizedBox(width: sw * 0.012),
                          Text(
                            '${vaccination.pet.name}'
                            '${vaccination.pet.species.isNotEmpty ? ' • ${vaccination.pet.species}' : ''}',
                            style: TextStyle(
                              fontSize: sw * 0.032,
                              color: const Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status chip
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.028, vertical: sh * 0.006),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: sw * 0.032, color: statusColor),
                      SizedBox(width: sw * 0.01),
                      Text(
                        vaccination.status,
                        style: TextStyle(
                          fontSize: sw * 0.028,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ─────────────────────────────────────────────────────
          Divider(height: 1, thickness: 1, color: const Color(0xFFF2F2F2)),

          // ── Detail grid ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(sw * 0.045),
            child: Column(
              children: [
                // Row 1: Administered — Next due
                Row(
                  children: [
                    Expanded(
                      child: _DetailCell(
                        icon: Icons.calendar_today_outlined,
                        label: 'Administered',
                        value: _formatDate(vaccination.administeredDate),
                        sw: sw,
                        sh: sh,
                        valueColor: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: _DetailCell(
                        icon: Icons.event_repeat_outlined,
                        label: 'Next Due',
                        value: vaccination.nextDueDate != null
                            ? _formatDate(vaccination.nextDueDate!)
                            : '—',
                        sw: sw,
                        sh: sh,
                        valueColor: vaccination.nextDueDate != null &&
                                vaccination.nextDueDate!
                                    .isBefore(DateTime.now())
                            ? const Color(0xFFC62828)
                            : const Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sh * 0.012),
                // Row 2: Dose — Route
                Row(
                  children: [
                    Expanded(
                      child: _DetailCell(
                        icon: Icons.medical_services_outlined,
                        label: 'Dose',
                        value: vaccination.dose.isNotEmpty
                            ? vaccination.dose
                            : '—',
                        sw: sw,
                        sh: sh,
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: _DetailCell(
                        icon: Icons.alt_route_outlined,
                        label: 'Route',
                        value: vaccination.route.isNotEmpty
                            ? vaccination.route
                            : '—',
                        sw: sw,
                        sh: sh,
                      ),
                    ),
                  ],
                ),
                // Row 3: Manufacturer — Batch (only if present)
                if (vaccination.manufacturer.isNotEmpty ||
                    vaccination.batchNumber.isNotEmpty) ...[
                  SizedBox(height: sh * 0.012),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailCell(
                          icon: Icons.business_outlined,
                          label: 'Manufacturer',
                          value: vaccination.manufacturer.isNotEmpty
                              ? vaccination.manufacturer
                              : '—',
                          sw: sw,
                          sh: sh,
                        ),
                      ),
                      SizedBox(width: sw * 0.03),
                      Expanded(
                        child: _DetailCell(
                          icon: Icons.tag_outlined,
                          label: 'Batch No.',
                          value: vaccination.batchNumber.isNotEmpty
                              ? vaccination.batchNumber
                              : '—',
                          sw: sw,
                          sh: sh,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail cell ─────────────────────────────────────────────────────────────

class _DetailCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double sw, sh;
  final Color valueColor;

  const _DetailCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.sw,
    required this.sh,
    this.valueColor = const Color(0xFF1A1A1A),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.03, vertical: sh * 0.01),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.025),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: sw * 0.036, color: AppColors.darkPink),
          SizedBox(width: sw * 0.018),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: sw * 0.026,
                    color: const Color(0xFF999999),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: sh * 0.002),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: sw * 0.032,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legacy function wrapper (keeps old call-sites compiling) ─────────────────
/// Prefer using [VaccinationCard] widget directly with a [VaccinationModel].
Widget vaccinationCard(
  double sw,
  double sh,
  String name,
  String givenDate,
  String nextDue,
  bool isUpToDate,
) {
  final accent = isUpToDate ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
  return Container(
    padding: EdgeInsets.all(sw * 0.04),
    decoration: BoxDecoration(
      color: accent.withOpacity(0.05),
      borderRadius: BorderRadius.circular(sw * 0.03),
      border: Border.all(color: accent.withOpacity(0.3), width: 1.5),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(sw * 0.025),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUpToDate ? Icons.check_circle : Icons.warning,
            color: accent,
            size: sw * 0.05,
          ),
        ),
        SizedBox(width: sw * 0.035),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: TextStyle(
                      fontSize: sw * 0.04, fontWeight: FontWeight.w600)),
              SizedBox(height: sh * 0.004),
              Text('Given: $givenDate',
                  style: TextStyle(
                      fontSize: sw * 0.03,
                      color: Colors.grey.shade600)),
              SizedBox(height: sh * 0.002),
              Text(nextDue,
                  style: TextStyle(
                      fontSize: sw * 0.03,
                      color: accent,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  );
}
