import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/widgets/pet_management/medical_report_card.dart';

class MedicalReportsScreen extends StatefulWidget {
  const MedicalReportsScreen({super.key});

  @override
  State<MedicalReportsScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MedicalReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: sw * 0.06,
          ),
        ),
        title: Text(
          'Medical History',
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
                  medicalReportCard(
                    sw,
                    sh,
                    'X-Ray Report',
                    '22/01/2025',
                    'Dr. Mike Smith',
                    Icons.assessment,
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
