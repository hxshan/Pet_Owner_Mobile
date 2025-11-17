import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class AppButtonStyles {
  static ButtonStyle blackButton(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.blackButtonBg,
      foregroundColor: AppColors.blackButtonText,
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.06, 
        vertical: sh * 0.008, 
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    );
  }
}
