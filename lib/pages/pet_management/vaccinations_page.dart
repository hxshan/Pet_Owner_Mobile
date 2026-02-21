import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/pet_management/Vaccination_card.dart';

class VaccinationsScreen extends StatefulWidget {
  const VaccinationsScreen({super.key});

  @override
  State<VaccinationsScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<VaccinationsScreen> {
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading:CustomBackButton(),
        title: Text(
          'Vaccinations',
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
                  vaccinationCard(
                    sw,
                    sh,
                    'Rabies Vaccine',
                    '12/02/2025',
                    'Next Due: 12/02/2026',
                    true,
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
