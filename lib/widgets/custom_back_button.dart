import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class CustomBackButton extends StatelessWidget {
  final Color backgroundColor;
  final Color iconColor;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool showPadding;

  const CustomBackButton({
    super.key,
    this.backgroundColor = AppColors.darkPink,
    this.iconColor = Colors.white,
    this.padding,
    this.onTap,
    this.showPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    Widget button = GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: Container(
        width: sw * 0.09,
        height: sw * 0.09,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(sw * 0.025),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: iconColor,
          size: sw * 0.042,
        ),
      ),
    );

    if (!showPadding) return button;

    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: button,
    );
  }
}