import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/pet_management/Appointment_card.dart';

class UpcomingAppointmentsScreen extends StatefulWidget {
  const UpcomingAppointmentsScreen({super.key});

  @override
  State<UpcomingAppointmentsScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<UpcomingAppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 0.03),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 10,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  appointmentCard(
                    sw,
                    sh,
                    'Annual Checkup',
                    'Dr. Sarah Johnson',
                    '25/03/2025',
                    '10:30 AM',
                    Colors.blue,
                  ),

                  SizedBox(height: sh * 0.015),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
