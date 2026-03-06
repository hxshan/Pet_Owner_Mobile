import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class AppointmentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailsPage({super.key, required this.appointment});

  // ── Status helpers ──────────────────────────────────────────────────────────
  Color _statusColor(String s) {
    switch (s.toUpperCase()) {
      case 'BOOKED':
        return const Color(0xFF1976D2);
      case 'COMPLETED':
        return const Color(0xFF2E7D32);
      case 'CANCELLED':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF757575);
    }
  }

  Color _confirmColor(String s) {
    switch (s.toUpperCase()) {
      case 'CONFIRMED':
        return const Color(0xFF2E7D32);
      case 'PENDING':
        return const Color(0xFFE65100);
      case 'REJECTED':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF757575);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    final vet = appointment['veterinarian'] as Map<String, dynamic>? ?? {};
    final pet = appointment['pet'] as Map<String, dynamic>? ?? {};
    final clinic = vet['clinic'] as Map<String, dynamic>? ?? {};

    final vetName = vet['firstname'] != null
        ? '${vet['firstname']} ${vet['lastname'] ?? ''}'.trim()
        : (vet['name'] ?? 'Veterinarian');
    final specialization = vet['specialization'] as String? ?? '';
    final clinicName = clinic['name'] ?? vet['clinicName'] ?? '';
    final clinicAddress = clinic['address'] ?? vet['clinicAddress'] ?? '';
    final clinicPhone = clinic['phone'] ?? '';

    final petName = pet['name'] ?? 'Unknown';
    final petSpecies = pet['species'] ?? '';
    final petBreed = pet['breed'] ?? '';

    final startRaw = appointment['startTime'] as String?;
    final endRaw = appointment['endTime'] as String?;
    DateTime? start;
    DateTime? end;
    try {
      if (startRaw != null && startRaw.length >= 19) {
        start = DateTime.parse(startRaw.substring(0, 19));
      }
      if (endRaw != null && endRaw.length >= 19) {
        end = DateTime.parse(endRaw.substring(0, 19));
      }
    } catch (_) {}

    final status = (appointment['status'] as String? ?? '').toUpperCase();
    final confirmStatus =
        (appointment['confirmationStatus'] as String? ?? '').toUpperCase();
    final reason = appointment['reason'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: Column(
        children: [
          // ── Branded header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.darkPink,
                  AppColors.darkPink.withOpacity(0.82),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.only(
              top: topPadding + sh * 0.015,
              left: sw * 0.04,
              right: sw * 0.04,
              bottom: sh * 0.028,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + status chips row
                Row(
                  children: [
                    CustomBackButton(
                      showPadding: false,
                      backgroundColor: Colors.white,
                      iconColor: AppColors.darkPink,
                    ),
                    const Spacer(),
                    if (status.isNotEmpty)
                      _HeaderChip(
                          label: status,
                          color: _statusColor(status)),
                    if (confirmStatus.isNotEmpty) ...[
                      SizedBox(width: sw * 0.02),
                      _HeaderChip(
                          label: confirmStatus,
                          color: _confirmColor(confirmStatus)),
                    ],
                  ],
                ),

                SizedBox(height: sh * 0.018),

                // Title
                Text(
                  'Appointment Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sw * 0.052,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: sh * 0.006),

                // Vet name sub-line
                Row(
                  children: [
                    Icon(Icons.local_hospital_outlined,
                        color: Colors.white70, size: sw * 0.036),
                    SizedBox(width: sw * 0.015),
                    Flexible(
                      child: Text(
                        'Dr. $vetName',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.88),
                          fontSize: sw * 0.036,
                          fontWeight: FontWeight.w500,
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

          // ── Body ───────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.04, vertical: sh * 0.022),
              children: [
                // ── Vet & clinic card ─────────────────────────────────────
                _SectionCard(
                  sw: sw,
                  sh: sh,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: sw * 0.15,
                        height: sw * 0.15,
                        decoration: BoxDecoration(
                          color: AppColors.mainColor.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                        child: Icon(Icons.local_hospital_outlined,
                            color: AppColors.darkPink, size: sw * 0.07),
                      ),
                      SizedBox(width: sw * 0.04),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. $vetName',
                              style: TextStyle(
                                fontSize: sw * 0.044,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            if (specialization.isNotEmpty) ...[
                              SizedBox(height: sh * 0.004),
                              _TagChip(
                                  label: specialization,
                                  color: AppColors.darkPink),
                            ],
                            SizedBox(height: sh * 0.01),
                            if (clinicName.isNotEmpty)
                              _DetailRow(
                                icon: Icons.business_outlined,
                                text: clinicName,
                                sw: sw,
                              ),
                            if (clinicAddress.isNotEmpty) ...[
                              SizedBox(height: sh * 0.006),
                              _DetailRow(
                                icon: Icons.location_on_outlined,
                                text: clinicAddress,
                                sw: sw,
                              ),
                            ],
                            if (clinicPhone.isNotEmpty) ...[
                              SizedBox(height: sh * 0.006),
                              _DetailRow(
                                icon: Icons.phone_outlined,
                                text: clinicPhone,
                                sw: sw,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: sh * 0.018),

                // ── Date & time card ──────────────────────────────────────
                if (start != null)
                  _SectionCard(
                    sw: sw,
                    sh: sh,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CardSectionTitle(title: 'Date & Time', sw: sw),
                        SizedBox(height: sh * 0.014),
                        // Timeline style
                        _TimelineRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date',
                          value:
                              '${_weekdayFull(start.weekday)}, ${start.day} ${_monthFull(start.month)} ${start.year}',
                          sw: sw,
                          sh: sh,
                        ),
                        _TimelineDivider(sw: sw),
                        _TimelineRow(
                          icon: Icons.access_time_outlined,
                          label: 'Start',
                          value: _formatTime(start),
                          sw: sw,
                          sh: sh,
                        ),
                        if (end != null) ...[
                          _TimelineDivider(sw: sw),
                          _TimelineRow(
                            icon: Icons.access_time_filled_outlined,
                            label: 'End',
                            value: _formatTime(end),
                            sw: sw,
                            sh: sh,
                          ),
                        ],
                      ],
                    ),
                  ),

                SizedBox(height: sh * 0.018),

                // ── Pet card ──────────────────────────────────────────────
                _SectionCard(
                  sw: sw,
                  sh: sh,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CardSectionTitle(title: 'Pet', sw: sw),
                      SizedBox(height: sh * 0.014),
                      Row(
                        children: [
                          Container(
                            width: sw * 0.12,
                            height: sw * 0.12,
                            decoration: BoxDecoration(
                              color: AppColors.mainColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(sw * 0.025),
                            ),
                            child: Icon(Icons.pets,
                                color: AppColors.darkPink, size: sw * 0.055),
                          ),
                          SizedBox(width: sw * 0.04),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                petName,
                                style: TextStyle(
                                  fontSize: sw * 0.042,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                              if (petSpecies.isNotEmpty || petBreed.isNotEmpty)
                                Text(
                                  [petSpecies, petBreed]
                                      .where((s) => s.isNotEmpty)
                                      .join(' • '),
                                  style: TextStyle(
                                    fontSize: sw * 0.033,
                                    color: const Color(0xFF888888),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Notes card (only if present) ──────────────────────────
                if (reason.isNotEmpty) ...[
                  SizedBox(height: sh * 0.018),
                  _SectionCard(
                    sw: sw,
                    sh: sh,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CardSectionTitle(title: 'Reason / Notes', sw: sw),
                        SizedBox(height: sh * 0.012),
                        Text(
                          reason,
                          style: TextStyle(
                            fontSize: sw * 0.036,
                            color: const Color(0xFF555555),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: sh * 0.02),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable sub-widgets ───────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  final double sw, sh;

  const _SectionCard({required this.child, required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.045),
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
      child: child,
    );
  }
}

class _CardSectionTitle extends StatelessWidget {
  final String title;
  final double sw;

  const _CardSectionTitle({required this.title, required this.sw});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: sw * 0.01,
          height: sw * 0.045,
          decoration: BoxDecoration(
            color: AppColors.darkPink,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: sw * 0.025),
        Text(
          title,
          style: TextStyle(
            fontSize: sw * 0.038,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final double sw;

  const _DetailRow(
      {required this.icon, required this.text, required this.sw});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: sw * 0.036, color: AppColors.darkPink),
        SizedBox(width: sw * 0.02),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: sw * 0.033,
              color: const Color(0xFF555555),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.025, vertical: sw * 0.01),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(sw * 0.015),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: sw * 0.028,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  final Color color;

  const _HeaderChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.03, vertical: sw * 0.012),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(sw * 0.02),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: sw * 0.028,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double sw, sh;

  const _TimelineRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: sw * 0.09,
          height: sw * 0.09,
          decoration: BoxDecoration(
            color: AppColors.mainColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(sw * 0.02),
          ),
          child: Icon(icon, color: AppColors.darkPink, size: sw * 0.042),
        ),
        SizedBox(width: sw * 0.035),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: sw * 0.028,
                color: const Color(0xFF999999),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: sh * 0.003),
            Text(
              value,
              style: TextStyle(
                fontSize: sw * 0.038,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineDivider extends StatelessWidget {
  final double sw;

  const _TimelineDivider({required this.sw});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: sw * 0.045, top: 4, bottom: 4),
      child: SizedBox(
        height: 16,
        child: VerticalDivider(
          width: 1,
          thickness: 1.5,
          color: AppColors.mainColor.withOpacity(0.5),
        ),
      ),
    );
  }
}

// ── Date helpers ────────────────────────────────────────────────────────────
String _weekdayFull(int w) => [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ][w - 1];

String _monthFull(int m) => [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ][m - 1];

String _formatTime(DateTime dt) {
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $ampm';
}
