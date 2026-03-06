import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_owner_mobile/models/vet/appointment_model.dart';
import 'package:pet_owner_mobile/services/vet_service.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/pet_management/Appointment_card.dart';

class UpcomingAppointmentsScreen extends StatefulWidget {
  const UpcomingAppointmentsScreen({super.key});

  @override
  State<UpcomingAppointmentsScreen> createState() => _UpcomingAppointmentsScreenState();
}

class _UpcomingAppointmentsScreenState extends State<UpcomingAppointmentsScreen> {
  final VetService _vetService = VetService();
  late Future<List<AppointmentModel>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _vetService.fetchUpcomingAppointments();
  }

  void _refresh() {
    setState(() {
      _appointmentsFuture = _vetService.fetchUpcomingAppointments();
    });
  }

  /// Picks a consistent accent colour based on the appointment status.
  Color _accentColor(String status) {
    switch (status.toUpperCase()) {
      case 'BOOKED':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: CustomBackButton(),
        title: Text(
          'Upcoming Appointments',
          style: TextStyle(
            fontSize: sw * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: FutureBuilder<List<AppointmentModel>>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            // ── Loading ──────────────────────────────────────────────────
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ── Error ────────────────────────────────────────────────────
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: sw * 0.15, color: Colors.red.shade300),
                      SizedBox(height: sh * 0.02),
                      Text(
                        'Failed to load appointments.\nPlease try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sw * 0.038,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: sh * 0.025),
                      ElevatedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(sw * 0.03),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final appointments = snapshot.data ?? [];

            // ── Empty state ──────────────────────────────────────────────
            if (appointments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: sw * 0.18, color: Colors.grey.shade300),
                    SizedBox(height: sh * 0.02),
                    Text(
                      'No upcoming appointments',
                      style: TextStyle(
                        fontSize: sw * 0.042,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: sh * 0.008),
                    Text(
                      'Book an appointment with a vet to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: sw * 0.033,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              );
            }

            // ── List ─────────────────────────────────────────────────────
            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.05, vertical: sh * 0.02),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appt = appointments[index];

                  final dateStr =
                      DateFormat('dd/MM/yyyy').format(appt.startTime.toLocal());
                  final timeStr =
                      DateFormat('hh:mm a').format(appt.startTime.toLocal());
                  final vetName = 'Dr. ${appt.veterinarian.fullName}';
                  final title =
                      appt.veterinarian.specialization.isNotEmpty
                          ? appt.veterinarian.specialization
                          : 'Appointment';

                  return Padding(
                    padding: EdgeInsets.only(bottom: sh * 0.015),
                    child: appointmentCard(
                      sw,
                      sh,
                      title,
                      vetName,
                      dateStr,
                      timeStr,
                      _accentColor(appt.status),
                      status: appt.status,
                      confirmationStatus: appt.confirmationStatus,
                      petName: '${appt.pet.name} (${appt.pet.species})',
                      clinicName: appt.veterinarian.clinic.name,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

