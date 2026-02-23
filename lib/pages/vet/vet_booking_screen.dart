import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/vet/appointment_model.dart';
import 'package:pet_owner_mobile/models/vet/vet_model.dart';
import 'package:pet_owner_mobile/services/appointment_service.dart';
import 'package:pet_owner_mobile/services/pet_service.dart';
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
  bool _loadingSlots = true;
  List<Map<String, dynamic>> _slots = [];

  List<Map<String, dynamic>> _myPets = [];
  String? _selectedPetId;

  final AppointmentService _appointmentService = AppointmentService();
  final PetService _petService = PetService();

  @override
  void initState() {
    super.initState();
    _fetchPets();
    _fetchSlotsForSelectedDate();
  }

  Future<void> _fetchPets() async {
    try {
      final pets = await _petService.getMyPets();
      setState(() {
        _myPets = pets.cast<Map<String, dynamic>>();
        if (_myPets.isNotEmpty) _selectedPetId = _myPets.first['_id'] ?? _myPets.first['id'];
      });
    } catch (e) {
      // ignore
    }
  }

  Future<void> _fetchSlotsForSelectedDate() async {
    setState(() {
      _loadingSlots = true;
      _slots = [];
      _selectedTime = null;
    });

    try {
      final dateStr = _selectedDate.toIso8601String().substring(0, 10);
      final slots = await _appointmentService.getAvailableSlots(widget.vet.id, dateStr);
      setState(() {
        _slots = slots.map((s) => Map<String, dynamic>.from(s)).toList();
      });
    } catch (e) {
      // ignore errors
    } finally {
      setState(() {
        _loadingSlots = false;
      });
    }
  }

  List<Widget> _buildSlotGroups(double sw, double sh) {
    // Group slots into Morning / Afternoon / Evening
    final Map<String, List<String>> groups = {
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
    };

    for (final s in _slots) {
      try {
        final dt = DateTime.parse(s['start'].toString()).toLocal();
        final label = _formatTimeLabel(dt);
        if (dt.hour < 12) {
          groups['Morning']!.add(label);
        } else if (dt.hour < 17) {
          groups['Afternoon']!.add(label);
        } else {
          groups['Evening']!.add(label);
        }
      } catch (_) {}
    }

    final widgets = <Widget>[];
    groups.forEach((label, list) {
      if (list.isEmpty) return;
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: sw * 0.034,
                  color: const Color(0xFF999999),
                ),
                SizedBox(width: sw * 0.015),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: sw * 0.032,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF888888),
                  ),
                ),
              ],
            ),
            SizedBox(height: sh * 0.01),
            Wrap(
              spacing: sw * 0.025,
              runSpacing: sh * 0.01,
              children: list.map((slot) {
                final isSelected = slot == _selectedTime;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = slot),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.038,
                      vertical: sh * 0.011,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.darkPink : Colors.white,
                      borderRadius: BorderRadius.circular(sw * 0.025),
                      border: Border.all(
                        color: isSelected ? AppColors.darkPink : const Color(0xFFE0E0E0),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.darkPink.withOpacity(0.22),
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
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : const Color(0xFF444444),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: sh * 0.018),
          ],
        ),
      );
    });

    return widgets;
  }

  String _formatTimeLabel(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $ampm';
  }

  TimeOfDay? _parseTimeLabel(String label) {
    try {
      final parts = label.split(' ');
      if (parts.length != 2) return null;
      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final ampm = parts[1].toUpperCase();
      if (ampm == 'PM' && hour != 12) hour += 12;
      if (ampm == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  List<DateTime> get _dateList =>
      List.generate(14, (i) => DateTime.now().add(Duration(days: i + 1)));

  // Slots will be fetched from the backend via AppointmentService

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

    if (_selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a pet to book with.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Prefer using the slot object returned by the API
      String startIso = '';
      if (_slots.isNotEmpty) {
        // find a slot whose time string matches the selected label
        Map<String, dynamic>? found;
        try {
          found = _slots.firstWhere((s) {
            try {
              final dt = DateTime.parse(s['start'].toString()).toLocal();
              final label = _formatTimeLabel(dt);
              return label == _selectedTime;
            } catch (_) {
              return false;
            }
          });
        } catch (_) {
          found = null;
        }

        if (found != null && found.containsKey('start')) {
          startIso = found['start'];
        }
      }

      if (startIso.isEmpty) {
        // Fallback: try to parse selected time as a time and build an ISO from selected date
        final parsed = _parseTimeLabel(_selectedTime!);
        if (parsed == null) throw Exception('Unable to resolve selected slot');
        final dt = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, parsed.hour, parsed.minute);
        startIso = dt.toUtc().toIso8601String();
      }

      await _appointmentService.bookAppointment(
        vetId: widget.vet.id,
        petId: _selectedPetId!,
        startTimeIso: startIso,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

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
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: ${e.toString()}')),
      );
    }
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
                              onTap: () {
                                setState(() {
                                  _selectedDate = date;
                                  _selectedTime = null;
                                });
                                _fetchSlotsForSelectedDate();
                              },
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

                      // Slot groups (fetched from API)
                      if (_loadingSlots)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                            child: CircularProgressIndicator(
                              color: AppColors.darkPink,
                            ),
                          ),
                        )
                      else if (_slots.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                          child: Text(
                            'No available slots for the selected date.',
                            style: TextStyle(color: const Color(0xFF777777)),
                          ),
                        )
                      else ..._buildSlotGroups(sw, sh),
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
                  // Pet selector
                  if (_myPets.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: sh * 0.01),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedPetId,
                              items: _myPets.map((p) {
                                final id = (p['_id'] ?? p['id'] ?? '').toString();
                                final name = (p['name'] ?? p['petName'] ?? 'My Pet').toString();
                                return DropdownMenuItem<String>(value: id, child: Text(name));
                              }).toList(),
                              onChanged: (v) => setState(() => _selectedPetId = v),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.014),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.only(bottom: sh * 0.01),
                      child: Text(
                        'You have no pets. Please add a pet before booking.',
                        style: TextStyle(color: const Color(0xFF777777)),
                      ),
                    ),

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
