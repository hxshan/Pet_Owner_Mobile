import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class PetCard extends StatelessWidget {
  final double sw;
  final double sh;
  final String petName;
  final String animal;
  final String breed;
  final String lifeStatus;
  final String overallHealth;
  final bool isHighlighted;

  const PetCard({
    required this.sw,
    required this.sh,
    required this.petName,
    required this.animal,
    required this.breed,
    required this.lifeStatus,
    required this.overallHealth,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        border: Border.all(
          color: isHighlighted ? AppColors.mainColor : Color(0xFFE0E0E0),
          width: sw * 0.005,
        ),
        borderRadius: BorderRadius.circular(sw * 0.03),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Pet Avatar
              Container(
                width: sw * 0.25,
                height: sw * 0.25,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFD0D0D0), width: 1),
                  borderRadius: BorderRadius.circular(sw * 0.15),
                ),
                child: Center(
                  child: Icon(
                    Icons.pets,
                    size: sw * 0.12,
                    color: Color(0xFFBDBDBD),
                  ),
                ),
              ),

              SizedBox(width: sw * 0.04),

              // Pet Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animal and Life Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Animal: $animal',
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Life Status: ',
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          lifeStatus,
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: sh * 0.008),

                    // Breed
                    Row(
                      children: [
                        Text(
                          'Breed: ',
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          breed,
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: sh * 0.008),

                    // Overall Health
                    Row(
                      children: [
                        Text(
                          'Overall Health: ',
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          overallHealth,
                          style: TextStyle(
                            fontSize: sw * 0.032,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: sh * 0.012),
                  ],
                ),
              ),
            ],
          ),

          // Pet Name and Show More
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                petName,
                style: TextStyle(
                  fontSize: sw * 0.05,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                width: sw * 0.23,
                child: ElevatedButton(
                  onPressed: () {
                    context.pushNamed('PetProfileScreen');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.black, width: 1),
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.005,
                      vertical: sh * 0.005,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Show more',
                      style: TextStyle(fontSize: sw * 0.035),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
