import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_owner_mobile/models/pet_management/pet_card_model.dart';
import 'package:pet_owner_mobile/services/pet_service.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class PetCard extends StatelessWidget {
  final double sw;
  final double sh;
  final Pet pet;
  final VoidCallback onDeleted;
  final bool isHighlighted;

  const PetCard({
    required this.sw,
    required this.sh,
    required this.pet,
    required this.onDeleted,
    this.isHighlighted = false,
  });

  // Delete API call
  Future<void> _deletePet(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await PetService().deletePet(pet.id);

      if (!navigator.mounted) return;

      navigator.pop();
      onDeleted();

      messenger.showSnackBar(SnackBar(content: Text('${pet.name} deleted')));
    } catch (_) {
      if (!navigator.mounted) return;
      navigator.pop();

      messenger.showSnackBar(const SnackBar(content: Text('Delete failed')));
    }
  }

  void _editPet(BuildContext context) {
    // Have to implement edit functionality in the future
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon!')),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.darkPink),
                title: Text('Edit Pet'),
                onTap: () {
                  Navigator.pop(context);
                  _editPet(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.errorMessage),
                title: Text(
                  'Delete Pet',
                  style: TextStyle(color: AppColors.errorMessage),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
              SizedBox(height: sh * 0.01),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        border: Border.all(
          color: isHighlighted ? AppColors.darkPink : Color(0xFFE0E0E0),
          width: isHighlighted ? sw * 0.008 : sw * 0.005,
        ),
        borderRadius: BorderRadius.circular(sw * 0.03),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Avatar
              Container(
                width: sw * 0.2,
                height: sw * 0.2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.mainColor,
                      AppColors.darkPink.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(sw * 0.03),
                ),
                child: Center(
                  child: Icon(Icons.pets, size: sw * 0.1, color: Colors.white),
                ),
              ),

              SizedBox(width: sw * 0.04),

              // Pet Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pet Name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            pet.name,
                            style: TextStyle(
                              fontSize: sw * 0.045,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Three-dot menu
                        InkWell(
                          onTap: () => _showOptionsMenu(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: EdgeInsets.all(sw * 0.01),
                            child: Icon(
                              Icons.more_vert,
                              size: sw * 0.055,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: sh * 0.005),

                    // Animal & Breed
                    Text(
                      '${pet.breed} • ${pet.breed}',
                      style: TextStyle(
                        fontSize: sw * 0.035,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: sh * 0.012),

                    // Status badges
                    Row(
                      children: [
                        // Life Status Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.025,
                            vertical: sh * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF4CAF50).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(sw * 0.015),
                            border: Border.all(
                              color: Color(0xFF4CAF50).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            pet.lifeStatus ?? 'Unknown',
                            style: TextStyle(
                              fontSize: sw * 0.028,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: sw * 0.02),
                        // Health Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.025,
                            vertical: sh * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: _getHealthColor().withOpacity(0.15),
                            borderRadius: BorderRadius.circular(sw * 0.015),
                            border: Border.all(
                              color: _getHealthColor().withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite,
                                size: sw * 0.03,
                                color: _getHealthColor(),
                              ),
                              SizedBox(width: sw * 0.01),
                              Text(
                                pet.overallHealth ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: sw * 0.028,
                                  color: _getHealthColor(),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: sh * 0.015),

          // Show More Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.pushNamed(
                  'PetProfileScreen',
                  pathParameters: {'petId': pet.id},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPink,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: sh * 0.012),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sw * 0.02),
                ),
                elevation: 0,
              ),
              child: Text(
                'View Details',
                style: TextStyle(
                  fontSize: sw * 0.038,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getHealthColor() {
    switch (pet.overallHealth?.toLowerCase()) {
      case 'excellent':
      case 'good':
        return Color(0xFF2E7D32); // Darker green
      case 'fair':
        return Color(0xFFF57C00); // Darker orange
      case 'poor':
        return Color(0xFFC62828); // Darker red
      default:
        return Color(0xFF616161); // Dark gray
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text('Delete Pet'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete ${pet.name}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePet(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorMessage,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
