import 'package:flutter/material.dart';
import 'package:pet_owner_mobile/theme/app_colors.dart';

class EcommerceSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final bool autoFocus;
  final String hintText;

  const EcommerceSearchBar({
    Key? key,
    required this.controller,
    this.onTap,
    this.onSubmitted,
    this.readOnly = false,
    this.autoFocus = false,
    this.hintText = 'Search products...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(sw * 0.03),
      ),
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.black54, size: sw * 0.06),
          SizedBox(width: sw * 0.02),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              autofocus: autoFocus,
              textInputAction: TextInputAction.search,
              onTap: onTap,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: sw * 0.035,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty && !readOnly)
            IconButton(
              onPressed: () => controller.clear(),
              icon: Icon(Icons.close, color: Colors.black54, size: sw * 0.055),
            ),
        ],
      ),
    );
  }
}