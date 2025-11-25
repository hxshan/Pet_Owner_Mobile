import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/widgets/pet_card_widget.dart';

class ViewAllPetsScreen extends StatefulWidget {
  const ViewAllPetsScreen({super.key});

  @override
  State<ViewAllPetsScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ViewAllPetsScreen> {
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
          child: Icon(Icons.arrow_back_ios, color: Colors.black, size: sw * 0.06),
        ),
        title: Text(
          'My Pets',
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
                  PetCard(
                    sw: sw,
                    sh: sh,
                    petName: 'Pet $index',
                    animal: 'Dog',
                    breed: 'German Shepherd',
                    lifeStatus: 'Alive',
                    overallHealth: 'Good',
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
