import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/store/pet_scope.dart';
import 'package:pet_owner_mobile/widgets/custom_back_button.dart';
import 'package:pet_owner_mobile/widgets/pet_card_widget.dart';

class ViewAllPetsScreen extends StatefulWidget {
  const ViewAllPetsScreen({super.key});

  @override
  State<ViewAllPetsScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ViewAllPetsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) PetScope.of(context).loadOnce();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final store = PetScope.of(context);
    final isLoading = store.isLoading || !store.isLoaded;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CustomBackButton(),
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
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : store.pets.isEmpty
              ? const Center(child: Text('No pets found'))
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: store.pets.length,
                  separatorBuilder: (_, __) => SizedBox(height: sh * 0.015),
                  itemBuilder: (context, index) {
                    final pet = store.pets[index];
                    return PetCard(
                      sw: sw,
                      sh: sh,
                      pet: pet,
                      onDeleted: () => PetScope.of(context).refresh(),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
