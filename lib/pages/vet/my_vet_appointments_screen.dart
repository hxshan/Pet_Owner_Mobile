import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/services/appointment_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class MyVetAppointmentsScreen extends StatefulWidget {
  /// Set to [true] when navigating here immediately after a successful booking
  /// so the green confirmation banner is shown automatically.
  final bool showSuccessBanner;

  const MyVetAppointmentsScreen({super.key, this.showSuccessBanner = false});

  @override
  State<MyVetAppointmentsScreen> createState() =>
      _MyVetAppointmentsScreenState();
}

class _MyVetAppointmentsScreenState extends State<MyVetAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AppointmentService _appointmentService = AppointmentService();
  late List<Map<String, dynamic>> _upcoming;
  late List<Map<String, dynamic>> _past;
  bool _loading = true;
  bool _showSuccessBanner = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _showSuccessBanner = widget.showSuccessBanner;

  _upcoming = [];
  _past = [];
  _fetchAppointments();

    
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
          // Header
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
                      CustomBackButton(showPadding: false, backgroundColor: Colors.white, iconColor: AppColors.darkPink,),
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
                                vertical: sh * 0.002,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(sw * 0.02),
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
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: sw * 0.046,
                        ),
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
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                            size: sw * 0.042,
                          ),
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
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _upcoming.isEmpty
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
                              onCancel: () => setState(() => _upcoming.removeAt(i)),
                            ),
                          ),

                // Past tab
                _loading
                    ? const SizedBox.shrink()
                    : _past.isEmpty
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

  void _fetchAppointments() async {
    setState(() {
      _loading = true;
    });

    try {
      final List<Map<String, dynamic>> appts =
          await _appointmentService.getMyUpcomingAppointments();

      final now = DateTime.now();
      final upcoming = <Map<String, dynamic>>[];
      final past = <Map<String, dynamic>>[];

      for (final a in appts) {
        DateTime start;
        try {
          start = DateTime.parse(a['startTime'] ?? a['start_time']);
        } catch (_) {
          start = now;
        }

        if (start.isAfter(now)) {
          upcoming.add(a);
        } else {
          past.add(a);
        }
      }

      setState(() {
        _upcoming = upcoming;
        _past = past;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load appointments: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}

// ── Appointment Card ──────────────────────────────────────────────────────────
class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
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
  final vet = appointment['veterinarian'] as Map<String, dynamic>?;
  final clinic = (vet != null ? (vet['clinic'] as Map<String, dynamic>?) : null) ?? (appointment['clinic'] as Map<String, dynamic>?);

  final vetName = vet != null
    ? ((vet['firstname'] != null || vet['lastname'] != null)
      ? '${(vet['firstname'] ?? '')} ${(vet['lastname'] ?? '')}'.trim()
      : (vet['name'] ?? 'Vet'))
    : (appointment['vetName'] ?? 'Vet');

  final specialization = vet != null
    ? (vet['specialization'] ?? (vet['veterinarianData']?['specialization'] ?? appointment['specialization']))
    : (appointment['specialization'] ?? '');

    DateTime date;
    try {
      date = DateTime.parse(appointment['startTime'] ?? appointment['start_time']);
    } catch (_) {
      date = DateTime.now();
    }

    final time = _formatTime(date);
  final address = clinic?['address'] ?? clinic?['name'] ?? appointment['address'] ?? '';
    return InkWell(
      onTap: () => context.pushNamed('AppointmentDetailScreen', extra: appointment),
      child: Container(
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
                        vetName,
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
                        specialization,
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
                        '${_weekdayShort(date.weekday)}, ${date.day} ${_monthShort(date.month)}',
                    sw: sw,
                    sh: sh,
                  ),
                SizedBox(width: sw * 0.025),
                _InfoPill(
                  icon: Icons.access_time_outlined,
                  label: time,
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
                Icon(
                  Icons.location_on_outlined,
                  color: AppColors.darkPink,
                  size: sw * 0.036,
                ),
                SizedBox(width: sw * 0.018),
                Expanded(
                    child: Text(
                    address,
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
                sw * 0.042,
                0,
                sw * 0.042,
                sw * 0.042,
              ),
              child: SizedBox(
                width: double.infinity,
                height: sh * 0.052,
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkPink,
                    side: const BorderSide(
                      color: AppColors.darkPink,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.025),
                    ),
                  ),
                  child: Text(
                    'Cancel Appointment',
                    style: TextStyle(
                      fontSize: sw * 0.035,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          else
            // Past — just a "Book Again" button
            Padding(
              padding: EdgeInsets.fromLTRB(
                sw * 0.042,
                0,
                sw * 0.042,
                sw * 0.042,
              ),
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
                      color: AppColors.darkPink,
                      width: 1.5,
                    ),
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
    ));
  }

  void _showCancelDialog(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final vet = appointment['veterinarian'] as Map<String, dynamic>?;
    final vetDisplay = vet != null
        ? ((vet['firstname'] != null || vet['lastname'] != null)
            ? '${(vet['firstname'] ?? '')} ${(vet['lastname'] ?? '')}'.trim()
            : (vet['name'] ?? 'the vet'))
        : (appointment['vetName'] ?? 'the vet');

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        bool isLoading = false;
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: sw * 0.06),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(sw * 0.05),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Warning top band ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.06,
                        vertical: MediaQuery.of(context).size.height * 0.022),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3F3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(sw * 0.05),
                        topRight: Radius.circular(sw * 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(sw * 0.025),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE0E0),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.cancel_outlined,
                            color: const Color(0xFFC62828),
                            size: sw * 0.055,
                          ),
                        ),
                        SizedBox(width: sw * 0.035),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cancel Appointment?',
                                style: TextStyle(
                                  fontSize: sw * 0.042,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                              Text(
                                'This action cannot be undone',
                                style: TextStyle(
                                  fontSize: sw * 0.03,
                                  color: const Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Body ─────────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.06,
                        vertical:
                            MediaQuery.of(context).size.height * 0.02),
                    child: Text(
                      'Are you sure you want to cancel your appointment with $vetDisplay?',
                      style: TextStyle(
                        fontSize: sw * 0.036,
                        color: const Color(0xFF555555),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // ── Buttons ───────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(sw * 0.06, 0, sw * 0.06,
                        MediaQuery.of(context).size.height * 0.025),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                isLoading ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF888888),
                              side: const BorderSide(
                                  color: Color(0xFFDDDDDD), width: 1.5),
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.height *
                                          0.016),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(sw * 0.03),
                              ),
                            ),
                            child: Text(
                              'Keep',
                              style: TextStyle(
                                fontSize: sw * 0.036,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: sw * 0.03),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() => isLoading = true);
                                    final apptId = (appointment['id'] ??
                                            appointment['_id'] ??
                                            appointment['appointmentId'] ??
                                            '')
                                        .toString();
                                    if (apptId.isEmpty) {
                                      setState(() => isLoading = false);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Unable to cancel: missing appointment id')),
                                      );
                                      return;
                                    }
                                    try {
                                      await AppointmentService()
                                          .cancelAppointment(apptId);
                                      Navigator.pop(context);
                                      onCancel?.call();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              'Appointment cancelled'),
                                          backgroundColor:
                                              const Color(0xFF2E7D32),
                                          behavior:
                                              SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      setState(() => isLoading = false);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              'Failed to cancel appointment'),
                                          backgroundColor:
                                              AppColors.darkPink,
                                          behavior:
                                              SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC62828),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.height *
                                          0.016),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(sw * 0.03),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: sw * 0.05,
                                    height: sw * 0.05,
                                    child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : Text(
                                    'Yes, Cancel',
                                    style: TextStyle(
                                      fontSize: sw * 0.036,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

// ── Info pill chip ────────────────────────────────────────────────────────────
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final double sw, sh;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.sw,
    required this.sh,
  });

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
              child: Icon(icon, color: AppColors.darkPink, size: sw * 0.12),
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
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][m - 1];

String _formatTime(DateTime dt) {
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $ampm';
}
