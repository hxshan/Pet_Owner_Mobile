import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/vet/appointment_model.dart';
import 'package:pet_owner_mobile/models/vet/vet_model.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class VetBookingScreen extends StatefulWidget {
  final VetModel vet;

  const VetBookingScreen({super.key, required this.vet});

  @override
  State<VetBookingScreen> createState() => _VetBookingScreenState();
}

class _VetBookingScreenState extends State<VetBookingScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  bool _isLoading = false;

  List<DateTime> get _dateList =>
      List.generate(14, (i) => DateTime.now().add(Duration(days: i + 1)));

  // Morning, afternoon, evening slots
  static const List<_SlotGroup> _slotGroups = [
    _SlotGroup(
      label: 'Morning',
      slots: [
        '9:00 AM',
        '9:30 AM',
        '10:00 AM',
        '10:30 AM',
        '11:00 AM',
        '11:30 AM',
      ],
    ),
    _SlotGroup(
      label: 'Afternoon',
      slots: [
        '12:00 PM',
        '12:30 PM',
        '1:00 PM',
        '1:30 PM',
        '2:00 PM',
        '2:30 PM',
      ],
    ),
    _SlotGroup(
      label: 'Evening',
      slots: ['3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM', '5:00 PM', '5:30 PM'],
    ),
  ];

  // Pretend some slots are taken
  static const Set<String> _unavailableSlots = {
    '9:30 AM',
    '10:30 AM',
    '1:00 PM',
    '3:30 PM',
    '5:00 PM',
  };

  void _onBook() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a time slot.',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.036,
            ),
          ),
          backgroundColor: AppColors.darkPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: call your booking API here
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Navigate to My Appointments, clearing the booking stack

    context.goNamed(
      'MyVetAppointmentScreen',
      extra: AppointmentModel(
        vetName: widget.vet.name,
        specialization: widget.vet.specialization,
        date: _selectedDate,
        time: _selectedTime!,
        address: widget.vet.address,
        isUpcoming: true,
      ),
    );
  }

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
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: sh * 0.13 + bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  color: AppColors.darkPink,
                  padding: EdgeInsets.only(
                    top: topPadding + sh * 0.015,
                    left: sw * 0.04,
                    right: sw * 0.04,
                    bottom: sh * 0.028,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      CustomBackButton(
                        showPadding: false,
                        backgroundColor: Colors.white,
                        iconColor: AppColors.darkPink,
                      ),

                      SizedBox(height: sh * 0.02),

                      Text(
                        'Book Appointment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.056,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: sh * 0.006),

                      // Vet name + address pill
                      Row(
                        children: [
                          Icon(
                            Icons.local_hospital_outlined,
                            color: Colors.white70,
                            size: sw * 0.036,
                          ),
                          SizedBox(width: sw * 0.015),
                          Flexible(
                            child: Text(
                              widget.vet.name,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.88),
                                fontSize: sw * 0.034,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sh * 0.005),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.white60,
                            size: sw * 0.032,
                          ),
                          SizedBox(width: sw * 0.015),
                          Flexible(
                            child: Text(
                              widget.vet.address,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: sw * 0.031,
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

                SizedBox(height: sh * 0.024),

                // ── Date Picker ──────────────────────────────────────────
                _Section(
                  sw: sw,
                  sh: sh,
                  title: 'Select Date',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month + year label
                      Text(
                        '${_monthFull(_selectedDate.month)} ${_selectedDate.year}',
                        style: TextStyle(
                          fontSize: sw * 0.033,
                          color: const Color(0xFF999999),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: sh * 0.012),

                      // Horizontal date strip
                      SizedBox(
                        height: sh * 0.115,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _dateList.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(width: sw * 0.025),
                          itemBuilder: (_, i) {
                            final date = _dateList[i];
                            final isSelected =
                                date.day == _selectedDate.day &&
                                date.month == _selectedDate.month;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedDate = date;
                                _selectedTime = null;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                width: sw * 0.155,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.darkPink
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    sw * 0.03,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.darkPink
                                        : const Color(0xFFEAEAEA),
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.darkPink
                                                .withOpacity(0.28),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _weekdayShort(date.weekday),
                                      style: TextStyle(
                                        fontSize: sw * 0.03,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white70
                                            : const Color(0xFF999999),
                                      ),
                                    ),
                                    SizedBox(height: sh * 0.006),
                                    Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        fontSize: sw * 0.048,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF1E1E1E),
                                      ),
                                    ),
                                    SizedBox(height: sh * 0.003),
                                    Text(
                                      _monthShort(date.month),
                                      style: TextStyle(
                                        fontSize: sw * 0.028,
                                        color: isSelected
                                            ? Colors.white70
                                            : const Color(0xFF999999),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: sh * 0.016),

                // ── Time Slots ───────────────────────────────────────────
                _Section(
                  sw: sw,
                  sh: sh,
                  title: 'Select Time',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Legend row
                      Row(
                        children: [
                          _Legend(
                            color: Colors.white,
                            border: const Color(0xFFEAEAEA),
                            label: 'Available',
                            sw: sw,
                            sh: sh,
                          ),
                          SizedBox(width: sw * 0.04),
                          _Legend(
                            color: AppColors.darkPink,
                            border: AppColors.darkPink,
                            label: 'Selected',
                            sw: sw,
                            sh: sh,
                          ),
                          SizedBox(width: sw * 0.04),
                          _Legend(
                            color: const Color(0xFFF5F5F5),
                            border: const Color(0xFFE0E0E0),
                            label: 'Unavailable',
                            sw: sw,
                            sh: sh,
                            textColor: const Color(0xFFCCCCCC),
                          ),
                        ],
                      ),
                      SizedBox(height: sh * 0.018),

                      // Slot groups
                      ..._slotGroups.map(
                        (group) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Group label
                            Row(
                              children: [
                                Icon(
                                  _groupIcon(group.label),
                                  size: sw * 0.034,
                                  color: const Color(0xFF999999),
                                ),
                                SizedBox(width: sw * 0.015),
                                Text(
                                  group.label,
                                  style: TextStyle(
                                    fontSize: sw * 0.032,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF888888),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: sh * 0.01),

                            // Slots grid
                            Wrap(
                              spacing: sw * 0.025,
                              runSpacing: sh * 0.01,
                              children: group.slots.map((slot) {
                                final unavailable = _unavailableSlots.contains(
                                  slot,
                                );
                                final isSelected = slot == _selectedTime;
                                return GestureDetector(
                                  onTap: unavailable
                                      ? null
                                      : () => setState(
                                          () => _selectedTime = slot,
                                        ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOut,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: sw * 0.038,
                                      vertical: sh * 0.011,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.darkPink
                                          : unavailable
                                          ? const Color(0xFFF5F5F5)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        sw * 0.025,
                                      ),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.darkPink
                                            : unavailable
                                            ? const Color(0xFFE0E0E0)
                                            : const Color(0xFFE0E0E0),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.darkPink
                                                    .withOpacity(0.22),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Text(
                                      slot,
                                      style: TextStyle(
                                        fontSize: sw * 0.034,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isSelected
                                            ? Colors.white
                                            : unavailable
                                            ? const Color(0xFFCCCCCC)
                                            : const Color(0xFF444444),
                                        decoration: unavailable
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: sh * 0.018),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: sh * 0.014),
              ],
            ),
          ),

          // ── Sticky bottom bar ────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                sw * 0.04,
                sh * 0.014,
                sw * 0.04,
                bottomPadding + sh * 0.014,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selected summary pill
                  if (_selectedTime != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(bottom: sh * 0.012),
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.04,
                        vertical: sh * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mainColor.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(sw * 0.025),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.darkPink,
                            size: sw * 0.04,
                          ),
                          SizedBox(width: sw * 0.02),
                          Text(
                            '${_weekdayShort(_selectedDate.weekday)}, '
                            '${_selectedDate.day} ${_monthShort(_selectedDate.month)}'
                            '  ·  $_selectedTime',
                            style: TextStyle(
                              fontSize: sw * 0.034,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkPink,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: sh * 0.062,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPink,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.darkPink.withOpacity(
                          0.6,
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.03),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: sw * 0.055,
                              height: sw * 0.055,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Confirm Booking',
                              style: TextStyle(
                                fontSize: sw * 0.042,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section wrapper ───────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final double sw, sh;
  final String title;
  final Widget child;

  const _Section({
    required this.sw,
    required this.sh,
    required this.title,
    required this.child,
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
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(sw * 0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: sw * 0.042,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1E1E),
              ),
            ),
            SizedBox(height: sh * 0.016),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Legend dot ────────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  final Color color, border;
  final String label;
  final double sw, sh;
  final Color textColor;

  const _Legend({
    required this.color,
    required this.border,
    required this.label,
    required this.sw,
    required this.sh,
    this.textColor = const Color(0xFF777777),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: sw * 0.032,
          height: sw * 0.032,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(sw * 0.008),
            border: Border.all(color: border, width: 1.2),
          ),
        ),
        SizedBox(width: sw * 0.015),
        Text(
          label,
          style: TextStyle(fontSize: sw * 0.029, color: textColor),
        ),
      ],
    );
  }
}

// ── Slot group model ──────────────────────────────────────────────────────────
class _SlotGroup {
  final String label;
  final List<String> slots;
  const _SlotGroup({required this.label, required this.slots});
}

IconData _groupIcon(String label) {
  switch (label) {
    case 'Morning':
      return Icons.wb_sunny_outlined;
    case 'Afternoon':
      return Icons.wb_cloudy_outlined;
    case 'Evening':
      return Icons.nights_stay_outlined;
    default:
      return Icons.access_time_outlined;
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

String _monthFull(int m) => [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
][m - 1];
