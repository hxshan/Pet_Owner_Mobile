import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/models/pet_management/pet_card_model.dart';
import 'package:pet_owner_mobile/services/pet_service.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/pet_card_widget.dart';

class ViewAllPetsScreen extends StatefulWidget {
  const ViewAllPetsScreen({super.key});

  @override
  State<ViewAllPetsScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ViewAllPetsScreen> {
  late Future<List<dynamic>> _petsFuture;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  void _loadPets() {
    _petsFuture = PetService().getMyPets().then(
      (list) => list.map(Pet.fromJson).toList(),
    );
  }

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
          child: FutureBuilder<List<dynamic>>(
            future: _petsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading pets: ${snapshot.error}'),
                );
              }

              final pets = snapshot.data ?? [];

              if (pets.isEmpty) {
                return const Center(child: Text('No pets found'));
              }

              return ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: pets.length,
                separatorBuilder: (_, __) => SizedBox(height: sh * 0.015),
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return PetCard(
                    sw: sw,
                    sh: sh,
                    pet: pet,
                    onDeleted: _loadPets,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
