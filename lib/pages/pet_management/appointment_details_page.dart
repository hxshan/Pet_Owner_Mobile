import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';

class AppointmentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailsPage({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final vet = appointment['veterinarian'] as Map<String, dynamic>? ?? {};
    final pet = appointment['pet'] as Map<String, dynamic>? ?? {};
    final startRaw = appointment['startTime'] as String?;
    final endRaw = appointment['endTime'] as String?;
    // Parse the server-provided local components without converting to device timezone.
    DateTime? start;
    DateTime? end;
    try {
      if (startRaw != null && startRaw.length >= 19) start = DateTime.parse(startRaw.substring(0, 19));
      if (endRaw != null && endRaw.length >= 19) end = DateTime.parse(endRaw.substring(0, 19));
    } catch (_) {
      start = null;
      end = null;
    }

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            color: AppColors.darkPink,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + sh * 0.015, left: sw * 0.04, right: sw * 0.04, bottom: sh * 0.02),
            child: Row(
              children: [
                CustomBackButton(showPadding: false, backgroundColor: Colors.white, iconColor: AppColors.darkPink),
                SizedBox(width: sw * 0.035),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Appointment Details', style: TextStyle(color: Colors.white, fontSize: sw * 0.048, fontWeight: FontWeight.bold)),
                      SizedBox(height: sh * 0.006),
                      Text(
                        vet['firstname'] != null ? '${vet['firstname']} ${vet['lastname'] ?? ''}' : (vet['name'] ?? ''),
                        style: TextStyle(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.all(sw * 0.04),
              children: [
                // Vet & Clinic card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(sw * 0.04),
                    child: Row(
                      children: [
                        Container(
                          width: sw * 0.16,
                          height: sw * 0.16,
                          decoration: BoxDecoration(
                            color: AppColors.mainColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.local_hospital_outlined, color: AppColors.darkPink, size: sw * 0.07),
                        ),
                        SizedBox(width: sw * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vet['firstname'] != null ? '${vet['firstname']} ${vet['lastname'] ?? ''}' : (vet['name'] ?? 'Veterinarian'),
                                style: TextStyle(fontSize: sw * 0.044, fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: sh * 0.006),
                              Text(
                                vet['clinic'] != null ? (vet['clinic']['name'] ?? '') : (vet['clinicName'] ?? ''),
                                style: TextStyle(color: const Color(0xFF666666)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: sh * 0.004),
                              Text(
                                vet['clinic'] != null ? (vet['clinic']['address'] ?? '') : (vet['clinicAddress'] ?? ''),
                                style: TextStyle(color: const Color(0xFF888888), fontSize: sw * 0.032),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.02),

                // Details card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(sw * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pet
                        Text('Pet', style: TextStyle(fontWeight: FontWeight.w700)),
                        SizedBox(height: sh * 0.01),
                        Text(pet['name'] ?? 'Unknown', style: TextStyle(fontSize: sw * 0.04)),
                        SizedBox(height: sh * 0.02),

                        // When
                        Text('When', style: TextStyle(fontWeight: FontWeight.w700)),
                        SizedBox(height: sh * 0.01),
                        if (start != null)
                          Text('${_weekdayShort(start.weekday)}, ${start.day} ${_monthShort(start.month)} • ${_formatTime(start)}', style: TextStyle(fontSize: sw * 0.038)),
                        if (end != null) SizedBox(height: sh * 0.004),
                        if (end != null) Text('Ends: ${_formatTime(end)}', style: TextStyle(color: const Color(0xFF666666))),
                        SizedBox(height: sh * 0.02),

                        // Notes
                        Text('Notes', style: TextStyle(fontWeight: FontWeight.w700)),
                        SizedBox(height: sh * 0.01),
                        Text(appointment['reason'] ?? 'No notes', style: TextStyle(color: const Color(0xFF666666))),
                      ],
                    ),
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

// ── Date helpers (local copy) ─────────────────────────────────────
String _weekdayShort(int w) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];

String _monthShort(int m) => [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
][m - 1];

String _formatTime(DateTime dt) {
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $ampm';
}
