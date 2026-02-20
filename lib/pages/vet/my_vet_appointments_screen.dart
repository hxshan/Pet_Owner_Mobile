import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/models/vet/appointment_model.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class MyVetAppointmentsScreen extends StatefulWidget {
  /// Newly booked appointment injected from the booking flow.
  /// Pass null when navigating here from the home Quick Actions button.
  final AppointmentModel? newAppointment;

  const MyVetAppointmentsScreen({super.key, this.newAppointment});

  @override
  State<MyVetAppointmentsScreen> createState() => _MyVetAppointmentsScreenState();
}

class _MyVetAppointmentsScreenState extends State<MyVetAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late List<AppointmentModel> _upcoming;
  late List<AppointmentModel> _past;
  bool _showSuccessBanner = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Seed mock data
    _upcoming = [..._mockUpcoming];
    _past = [..._mockPast];

    // Prepend new appointment if coming from booking
    if (widget.newAppointment != null) {
      _upcoming.insert(0, widget.newAppointment!);
      _showSuccessBanner = true;

      // Auto-hide banner after 4 seconds
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showSuccessBanner = false);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: AppColors.darkPink,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: topPadding + sh * 0.015,
                    left: sw * 0.04,
                    right: sw * 0.04,
                    bottom: sh * 0.01,
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
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: sw * 0.042),
                        ),
                      ),
                      SizedBox(width: sw * 0.035),
                      Text(
                        'My Appointments',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // TabBar
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: TextStyle(
                    fontSize: sw * 0.038,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: sw * 0.036,
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Upcoming'),
                          SizedBox(width: sw * 0.02),
                          if (_upcoming.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: sw * 0.018,
                                  vertical: sh * 0.002),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(sw * 0.02),
                              ),
                              child: Text(
                                '${_upcoming.length}',
                                style: TextStyle(
                                  fontSize: sw * 0.026,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkPink,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Tab(text: 'Past'),
                  ],
                ),
              ],
            ),
          ),

          // ── Success banner ───────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            height: _showSuccessBanner ? sh * 0.065 : 0,
            child: _showSuccessBanner
                ? Container(
                    width: double.infinity,
                    color: const Color(0xFF2E7D32),
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: sw * 0.046),
                        SizedBox(width: sw * 0.03),
                        Expanded(
                          child: Text(
                            'Appointment booked! Awaiting clinic confirmation.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: sw * 0.034,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _showSuccessBanner = false),
                          child: Icon(Icons.close_rounded,
                              color: Colors.white70, size: sw * 0.042),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // ── Tab content ──────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Upcoming tab
                _upcoming.isEmpty
                    ? _EmptyState(
                        icon: Icons.event_available_outlined,
                        message: 'No upcoming appointments',
                        sub: 'Book a vet to get started.',
                        sw: sw,
                        sh: sh,
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.04,
                          vertical: sh * 0.02,
                        ),
                        itemCount: _upcoming.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: sh * 0.014),
                        itemBuilder: (_, i) => _AppointmentCard(
                          appointment: _upcoming[i],
                          isUpcoming: true,
                          sw: sw,
                          sh: sh,
                          onCancel: () => setState(
                              () => _upcoming.removeAt(i)),
                        ),
                      ),

                // Past tab
                _past.isEmpty
                    ? _EmptyState(
                        icon: Icons.history_outlined,
                        message: 'No past visits yet',
                        sub: 'Your completed appointments will appear here.',
                        sw: sw,
                        sh: sh,
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.04,
                          vertical: sh * 0.02,
                        ),
                        itemCount: _past.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: sh * 0.014),
                        itemBuilder: (_, i) => _AppointmentCard(
                          appointment: _past[i],
                          isUpcoming: false,
                          sw: sw,
                          sh: sh,
                          onCancel: null,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Appointment Card ──────────────────────────────────────────────────────────
class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isUpcoming;
  final double sw, sh;
  final VoidCallback? onCancel;

  const _AppointmentCard({
    required this.appointment,
    required this.isUpcoming,
    required this.sw,
    required this.sh,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          // ── Top: vet info ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(sw * 0.042),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: sw * 0.14,
                  height: sw * 0.14,
                  decoration: BoxDecoration(
                    color: AppColors.mainColor.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(sw * 0.03),
                  ),
                  child: Icon(
                    Icons.local_hospital_outlined,
                    color: AppColors.darkPink,
                    size: sw * 0.065,
                  ),
                ),
                SizedBox(width: sw * 0.035),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.vetName,
                        style: TextStyle(
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E1E1E),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: sh * 0.004),
                      Text(
                        appointment.specialization,
                        style: TextStyle(
                          fontSize: sw * 0.032,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.025,
                    vertical: sh * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: isUpcoming
                        ? AppColors.mainColor.withOpacity(0.3)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Text(
                    isUpcoming ? 'Upcoming' : 'Completed',
                    style: TextStyle(
                      fontSize: sw * 0.028,
                      fontWeight: FontWeight.w600,
                      color: isUpcoming
                          ? AppColors.darkPink
                          : const Color(0xFF888888),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: const Color(0xFFF2F2F2),
            indent: sw * 0.042,
            endIndent: sw * 0.042,
          ),

          // ── Middle: date/time/address chips ─────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.042,
              vertical: sh * 0.014,
            ),
            child: Row(
              children: [
                _InfoPill(
                  icon: Icons.calendar_today_outlined,
                  label:
                      '${_weekdayShort(appointment.date.weekday)}, '
                      '${appointment.date.day} '
                      '${_monthShort(appointment.date.month)}',
                  sw: sw,
                  sh: sh,
                ),
                SizedBox(width: sw * 0.025),
                _InfoPill(
                  icon: Icons.access_time_outlined,
                  label: appointment.time,
                  sw: sw,
                  sh: sh,
                ),
              ],
            ),
          ),

          // Address row
          Padding(
            padding: EdgeInsets.only(
              left: sw * 0.042,
              right: sw * 0.042,
              bottom: sh * 0.014,
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined,
                    color: AppColors.darkPink, size: sw * 0.036),
                SizedBox(width: sw * 0.018),
                Expanded(
                  child: Text(
                    appointment.address,
                    style: TextStyle(
                      fontSize: sw * 0.032,
                      color: const Color(0xFF777777),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom: action buttons ───────────────────────────────────────
          if (isUpcoming)
            Padding(
              padding: EdgeInsets.fromLTRB(
                  sw * 0.042, 0, sw * 0.042, sw * 0.042),
              child: Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: SizedBox(
                      height: sh * 0.052,
                      child: OutlinedButton(
                        onPressed: () => _showCancelDialog(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkPink,
                          side: const BorderSide(
                              color: AppColors.darkPink, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.025),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: sw * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.03),
                  // Reschedule button
                  Expanded(
                    child: SizedBox(
                      height: sh * 0.052,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: navigate to booking screen to reschedule
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPink,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.025),
                          ),
                        ),
                        child: Text(
                          'Reschedule',
                          style: TextStyle(
                            fontSize: sw * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Past — just a "Book Again" button
            Padding(
              padding: EdgeInsets.fromLTRB(
                  sw * 0.042, 0, sw * 0.042, sw * 0.042),
              child: SizedBox(
                width: double.infinity,
                height: sh * 0.052,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: navigate to booking screen for this vet
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkPink,
                    side: const BorderSide(
                        color: AppColors.darkPink, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.025),
                    ),
                  ),
                  child: Text(
                    'Book Again',
                    style: TextStyle(
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(sw * 0.04)),
        title: Text(
          'Cancel Appointment?',
          style: TextStyle(
              fontSize: sw * 0.042, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to cancel your appointment with ${appointment.vetName}?',
          style: TextStyle(
              fontSize: sw * 0.036, color: const Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep',
                style: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: sw * 0.036)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel?.call();
            },
            child: Text('Yes, Cancel',
                style: TextStyle(
                    color: AppColors.darkPink,
                    fontWeight: FontWeight.w700,
                    fontSize: sw * 0.036)),
          ),
        ],
      ),
    );
  }
}

// ── Info pill chip ────────────────────────────────────────────────────────────
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final double sw, sh;

  const _InfoPill(
      {required this.icon,
      required this.label,
      required this.sw,
      required this.sh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.03,
        vertical: sh * 0.007,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.02),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.darkPink, size: sw * 0.036),
          SizedBox(width: sw * 0.015),
          Text(
            label,
            style: TextStyle(
              fontSize: sw * 0.032,
              color: const Color(0xFF444444),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message, sub;
  final double sw, sh;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.sub,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: sw * 0.24,
              height: sw * 0.24,
              decoration: BoxDecoration(
                color: AppColors.mainColor.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: AppColors.darkPink, size: sw * 0.12),
            ),
            SizedBox(height: sh * 0.024),
            Text(
              message,
              style: TextStyle(
                fontSize: sw * 0.042,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: sh * 0.008),
            Text(
              sub,
              style: TextStyle(
                fontSize: sw * 0.034,
                color: const Color(0xFF999999),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Date helpers ──────────────────────────────────────────────────────────────
String _weekdayShort(int w) =>
    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];

String _monthShort(int m) => [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][m - 1];

// ── Mock data ─────────────────────────────────────────────────────────────────
final List<AppointmentModel> _mockUpcoming = [
  AppointmentModel(
    vetName: 'Dr. Sarah Mitchell',
    specialization: 'General Veterinarian',
    date: DateTime.now().add(const Duration(days: 3)),
    time: '10:00 AM',
    address: '12 Maple Ave',
    isUpcoming: true,
  ),
  AppointmentModel(
    vetName: 'Paws & Claws Animal Clinic',
    specialization: 'Small Animal Specialist',
    date: DateTime.now().add(const Duration(days: 8)),
    time: '2:30 PM',
    address: '45 Birch St',
    isUpcoming: true,
  ),
];

final List<AppointmentModel> _mockPast = [
  AppointmentModel(
    vetName: 'CityPet Veterinary Centre',
    specialization: 'Emergency & General Care',
    date: DateTime.now().subtract(const Duration(days: 12)),
    time: '11:00 AM',
    address: '99 Elm Road',
    isUpcoming: false,
  ),
  AppointmentModel(
    vetName: 'Dr. James Okafor',
    specialization: 'Exotic Animals & Surgery',
    date: DateTime.now().subtract(const Duration(days: 30)),
    time: '3:00 PM',
    address: '7 Oak Blvd',
    isUpcoming: false,
  ),
];