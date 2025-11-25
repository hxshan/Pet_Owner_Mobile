import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';
import 'package:pet_owner_mobile/theme/button_styles.dart';
import 'package:pet_owner_mobile/widgets/pet_card_widget.dart';
import 'package:pet_owner_mobile/widgets/pet_updates_card_widget.dart';

class MyPetsScreen extends StatelessWidget {
  const MyPetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

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
                      onTap: () {
                        context.pushNamed('AddPetScreen');
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
                PetCard(
                  sw: sw,
                  sh: sh,
                  petName: 'Suddu Putha',
                  animal: 'Dog',
                  breed: 'German Shepard',
                  lifeStatus: 'Alive',
                  overallHealth: 'Good',
                ),

                SizedBox(height: sh * 0.02),

                PetCard(
                  sw: sw,
                  sh: sh,
                  petName: 'Suddu Putha',
                  animal: 'Dog',
                  breed: 'German Shepard',
                  lifeStatus: 'Alive',
                  overallHealth: 'Good',
                  isHighlighted: true,
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
                  backgroundColor: Color(0xFFE3F2FD),
                  borderColor: Color(0xFF2196F3),
                  title: 'Due Date Nearing',
                  date: '15/02/2025',
                  description: 'Vaccination for Suddu Putha is due in 3 days',
                  titleColor: Color(0xFF2196F3),
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
