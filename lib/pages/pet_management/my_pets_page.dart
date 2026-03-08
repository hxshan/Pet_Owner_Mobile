import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/store/pet_scope.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/theme/button_styles.dart';
import 'package:pet_owner_mobile/widgets/pet_card_widget.dart';
import 'package:pet_owner_mobile/widgets/pet_updates_card_widget.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({Key? key}) : super(key: key);

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
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
    final pets = store.pets.length > 2 ? store.pets.sublist(0, 2) : store.pets;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.05,
              vertical: sh * 0.01,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Pets',
                      style: TextStyle(
                        fontSize: sw * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await context.pushNamed('AddPetScreen');
                        if (mounted) PetScope.of(context).refresh();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.04,
                          vertical: sh * 0.012,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.mainColor,
                          borderRadius: BorderRadius.circular(sw * 0.02),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.white,
                              size: sw * 0.045,
                            ),
                            SizedBox(width: sw * 0.01),
                            Text(
                              'New Pet',
                              style: TextStyle(
                                fontSize: sw * 0.032,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: sh * 0.025),

                // Pet Cards
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (store.pets.isEmpty)
                  const Center(child: Text('No pets found'))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pets.length,
                    separatorBuilder: (_, __) => SizedBox(height: sh * 0.02),
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      return PetCard(
                        sw: sw,
                        sh: sh,
                        pet: pet,
                        onDeleted: () => PetScope.of(context).refresh(),
                      );
                    },
                  ),

                SizedBox(height: sh * 0.02),

                // View All Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      context.pushNamed('ViewAllPetsScreen');
                    },
                    style: AppButtonStyles.blackButton(context),
                    child: Text(
                      'View All',
                      style: TextStyle(fontSize: sw * 0.032),
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.03),

                // Important Updates Section
                Text(
                  'Important Updates',
                  style: TextStyle(
                    fontSize: sw * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: sh * 0.02),

                // Missed Due Date Card
                UpdateCard(
                  sw: sw,
                  sh: sh,
                  backgroundColor: AppColors.errorMessage.withOpacity(0.1),
                  borderColor: AppColors.errorMessage,
                  title: 'DUE DATE MISSED',
                  date: '12/02/2025',
                  description: 'Vaccination for Suddu Putha has been missed',
                  titleColor: AppColors.errorMessage,
                ),

                SizedBox(height: sh * 0.02),

                // Due Date Nearing Card
                UpdateCard(
                  sw: sw,
                  sh: sh,
                  backgroundColor: const Color(0xFFE3F2FD),
                  borderColor: const Color(0xFF2196F3),
                  title: 'Due Date Nearing',
                  date: '15/02/2025',
                  description: 'Vaccination for Suddu Putha is due in 3 days',
                  titleColor: const Color(0xFF2196F3),
                ),

                SizedBox(height: sh * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
